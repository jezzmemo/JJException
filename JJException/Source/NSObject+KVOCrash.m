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

static const char DeallocKVOKey;

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

@property(nonatomic,readwrite,retain)NSMutableSet* kvoObjectSet;

@property(nonatomic,readwrite,unsafe_unretained)NSObject* whichObject;

- (void)addKVOObjectItem:(KVOObjectItem*)item;

@end

@implementation KVOObjectContainer

- (void)addKVOObjectItem:(KVOObjectItem*)item{
    if (item) {
        @synchronized(self){
            [self.kvoObjectSet addObject:item];
        }
    }
}

- (void)removeKVOObjectItem:(KVOObjectItem*)item{
    if (item) {
        @synchronized(self){
            [self.kvoObjectSet removeObject:item];
        }
    }
}

- (void)dealloc{
    [self clearKVOData];
    [self.kvoObjectSet release];
    self.whichObject = nil;
    [super dealloc];
}

- (void)clearKVOData{
    for (KVOObjectItem* item in self.kvoObjectSet) {
        [self.whichObject removeObserver:item.observer forKeyPath:item.keyPath context:item.context];
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

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod([self class], @selector(addObserver:forKeyPath:options:context:), @selector(hookAddObserver:forKeyPath:options:context:));
        swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:context:), @selector(hookRemoveObserver:forKeyPath:context:));
        swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:), @selector(hookRemoveObserver:forKeyPath:));
    });
}


- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    
    if (!observer || keyPath.length == 0) {
        return;
    }
    
    [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    
    KVOObjectContainer* object = objc_getAssociatedObject(self, &DeallocKVOKey);

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
    }else{
        if (![object.kvoObjectSet containsObject:item]) {
            [object addKVOObjectItem:item];
        }
    }
    [item release];
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context{
    [self hookRemoveObserver:observer forKeyPath:keyPath context:context];
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    KVOObjectContainer* object = objc_getAssociatedObject(self, &DeallocKVOKey);
    
    KVOObjectItem* item = [[KVOObjectItem alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    
    if ([object.kvoObjectSet containsObject:item]) {
        [self hookRemoveObserver:observer forKeyPath:keyPath];
        [object removeKVOObjectItem:item];
    }
    
    [item release];
}

@end
