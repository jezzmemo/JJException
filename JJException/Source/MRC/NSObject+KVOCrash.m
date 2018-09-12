//
//  NSObject+KVOCrash.m
//  JJException
//
//  Created by Jezz on 2018/8/29.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSObject+KVOCrash.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import "JJExceptionProxy.h"

static const char DeallocKVOKey;

/**
 Record the kvo object
 Override the isEqual and hash method
 */
@interface KVOObjectItem : NSObject

@property(nonatomic,readwrite,unsafe_unretained)NSObject* observer;
@property(nonatomic,readwrite,copy)NSString* keyPath;
@property(nonatomic,readwrite,assign)NSKeyValueObservingOptions options;
@property(nonatomic,readwrite,assign)void* context;

@end

@implementation KVOObjectItem

- (BOOL)isEqual:(KVOObjectItem*)object{
    if ([self.observer isEqual:object.observer] && [self.keyPath isEqualToString:object.keyPath]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash{
    return [self.observer hash] ^ [self.keyPath hash];
}

@end

@interface KVOObjectContainer : NSObject

/**
 KVO object array set
 */
@property(nonatomic,readwrite,retain)NSMutableSet* kvoObjectSet;

/**
 Associated owner object
 */
@property(nonatomic,readwrite,unsafe_unretained)NSObject* whichObject;

/**
 NSMutableSet safe-thread
 */
@property(nonatomic,readwrite,retain)dispatch_semaphore_t kvoLock;

- (void)addKVOObjectItem:(KVOObjectItem*)item;

- (void)removeKVOObjectItem:(KVOObjectItem*)item;

@end

@implementation KVOObjectContainer

- (void)addKVOObjectItem:(KVOObjectItem*)item{
    if (item) {
        dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
        [self.kvoObjectSet addObject:item];
        dispatch_semaphore_signal(self.kvoLock);
    }
}

- (void)removeKVOObjectItem:(KVOObjectItem*)item{
    if (item) {
        dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
        [self.kvoObjectSet removeObject:item];
        dispatch_semaphore_signal(self.kvoLock);
    }
}

- (dispatch_semaphore_t)kvoLock{
    if (!_kvoLock) {
        _kvoLock = dispatch_semaphore_create(1);
        return _kvoLock;
    }
    return _kvoLock;
}

/**
 Clean the kvo object array and temp var
 release the dispatch_semaphore
 */
- (void)dealloc{
    [self clearKVOData];
    [self.kvoObjectSet release];
    self.whichObject = nil;
    dispatch_release(self.kvoLock);
    [super dealloc];
}

- (void)clearKVOData{
    for (KVOObjectItem* item in self.kvoObjectSet) {
        //Invoke the origin removeObserver,do not check array
        handleCrashException(JJExceptionGuardKVOCrash,[NSString stringWithFormat:@"KVO forget remove keyPath:%@ observer:%@",item.keyPath,item.observer]);
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        [self.whichObject performSelector:@selector(hookRemoveObserver:forKeyPath:) withObject:item.observer withObject:item.keyPath];
        #pragma clang diagnostic pop
    }
}

- (NSMutableSet*)kvoObjectSet{
    if(_kvoObjectSet){
        return _kvoObjectSet;
    }
    _kvoObjectSet = [[NSMutableSet alloc] init];
    return _kvoObjectSet;
}

@end

@implementation NSObject (KVOCrash)

+ (void)jj_swizzleKVOCrash{
    swizzleInstanceMethod([self class], @selector(addObserver:forKeyPath:options:context:), @selector(hookAddObserver:forKeyPath:options:context:));
    swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:), @selector(hookRemoveObserver:forKeyPath:));
}

- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    
    if (!observer || keyPath.length == 0) {
        return;
    }
    
    KVOObjectContainer* object = objc_getAssociatedObject(self,&DeallocKVOKey);

    KVOObjectItem* item = [[KVOObjectItem alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    item.options = options;
    item.context = context;

    if (!object) {
        KVOObjectContainer* objectContainer = [KVOObjectContainer new];
        [objectContainer setWhichObject:self];
        [objectContainer addKVOObjectItem:item];
        objc_setAssociatedObject(self, &DeallocKVOKey, objectContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [objectContainer release];
        
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    }else{
        if (![object.kvoObjectSet containsObject:item]) {
            [object addKVOObjectItem:item];
            
            [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
        }else{
            handleCrashException(JJExceptionGuardKVOCrash,[NSString stringWithFormat:@"KVO duplicate key:%@ observer:%@",keyPath,observer]);
        }
    }
    [item release];
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    KVOObjectContainer* object = objc_getAssociatedObject(self, &DeallocKVOKey);
    
    KVOObjectItem* item = [[KVOObjectItem alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    
    if ([object.kvoObjectSet containsObject:item]) {
        [self hookRemoveObserver:observer forKeyPath:keyPath];
        [object removeKVOObjectItem:item];
    }else{
        handleCrashException(JJExceptionGuardKVOCrash,[NSString stringWithFormat:@"KVO removeObserver did not exist key:%@ observer:%@",keyPath,observer]);
    }
    
    [item release];
}

@end
