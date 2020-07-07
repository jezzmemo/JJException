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

/**
 Record the kvo object
 Override the isEqual and hash method
 */
@interface KVOObjectItem : NSObject

/// KVO observer
@property(nonatomic,readwrite,weak)NSObject* observer;
/// KVO which object
@property(nonatomic,readwrite,weak)NSObject* whichObject;

@property(nonatomic,readwrite,copy)NSString* keyPath;
@property(nonatomic,readwrite,assign)NSKeyValueObservingOptions options;
@property(nonatomic,readwrite,assign)void* context;

@end

@implementation KVOObjectItem

- (BOOL)isEqual:(KVOObjectItem *)object {
    return self.hash == object.hash;
}

- (NSUInteger)hash {
    return [self.observer hash] ^ [self.whichObject hash] ^ [self.keyPath hash];
}
@end

@interface NSObject ()
/**
 NSMutableSet safe-thread
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property(nonatomic,readwrite,retain)NSRecursiveLock *kvoLock;
#else
@property(nonatomic,readwrite,assign)NSRecursiveLock *kvoLock;
#endif

@end

@implementation NSObject (KVOCrash)

+ (void)jj_swizzleKVOCrash{
    swizzleInstanceMethod([self class], @selector(addObserver:forKeyPath:options:context:), @selector(hookAddObserver:forKeyPath:options:context:));
    swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:), @selector(hookRemoveObserver:forKeyPath:));
    swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:context:), @selector(hookRemoveObserver:forKeyPath:context:));
    swizzleInstanceMethod([self class], @selector(observeValueForKeyPath:ofObject:change:context:), @selector(hookObserveValueForKeyPath:ofObject:change:context:));
}

- (NSRecursiveLock *)kvoLock {
    NSRecursiveLock *lock = objc_getAssociatedObject(self,@selector(kvoLock));
    if (!lock) {
        lock = [[NSRecursiveLock alloc] init];
        objc_setAssociatedObject(self, @selector(kvoLock), lock, OBJC_ASSOCIATION_RETAIN);
    }
    return lock;
}

- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if ([self deallocating]) {
        return;
    }

    [self.kvoLock lock];
    if (!observer || keyPath.length == 0) {
        [self.kvoLock unlock];
        return;
    }

    if ([self ignoreKVOInstanceClass:observer]) {
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
        [self.kvoLock unlock];
        return;
    }
                
    // Record the kvo relation
    KVOObjectItem* item = [[KVOObjectItem alloc] init];
    item.observer = observer;
    item.whichObject = self;
    item.keyPath = keyPath;
    item.options = options;
    item.context = context;
    // Observer current self
    if ([self addKVOItem:item]) {
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    };
    // Observer observer
    [observer addKVOItem:item];
    
    // clean the self and observer
    jj_swizzleDeallocIfNeeded(self.class);
    jj_swizzleDeallocIfNeeded(observer.class);

    [self.kvoLock unlock];

}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void*)context{
    if ([self deallocating]) {
        return;
    }
    [self.kvoLock lock];
    if ([self ignoreKVOInstanceClass:observer]) {
        [self hookRemoveObserver:observer forKeyPath:keyPath context:context];
    } else {
        [self removeObserver:observer forKeyPath:keyPath];
    }
    [self.kvoLock unlock];
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if ([self deallocating]) {
        return;
    }
    [self.kvoLock lock];
    if (!observer) {
        [self.kvoLock unlock];
        return;
    }
    
    if ([self ignoreKVOInstanceClass:observer]) {
        [self hookRemoveObserver:observer forKeyPath:keyPath];
        [self.kvoLock unlock];
        return;
    }

    if ([self removeItemWithObject:self observer:observer forKeyPath:keyPath]) {
        @try {
            [self hookRemoveObserver:observer forKeyPath:keyPath];
        }@catch (NSException *exception) {
            
        }
    }
    [observer removeItemWithObject:self observer:observer forKeyPath:keyPath];
    [self.kvoLock unlock];
}

- (void)hookObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([self deallocating]) {
        return;
    }
    [self.kvoLock unlock];
    if ([self ignoreKVOInstanceClass:object]) {
        [self hookObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    @try {
        [self hookObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    } @catch (NSException *exception) {
        handleCrashException(JJExceptionGuardKVOCrash, exception.description);
    }
    [self.kvoLock unlock];
}


- (BOOL)addKVOItem:(KVOObjectItem *)item {
    if ([self deallocating]) {
        return NO;
    }
    NSMutableSet *set = self.kvoObjectSet;
    if ([set containsObject:item]) {
        return NO;
    }
    
    [self.kvoLock lock];
    [set addObject:item];
    [self.kvoLock unlock];
    return YES;
}

- (BOOL)removeItemWithObject:(NSObject *)object observer:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    if ([self deallocating]) {
        return NO;
    }
    BOOL success = NO;
    NSMutableSet* kvoObjectSet = self.kvoObjectSet;
    if (!kvoObjectSet.count) {
        return success;
    }
    
    [self.kvoLock lock];

    // Clean the reference
    NSMutableSet *tmpSet = [[NSMutableSet alloc] init];
    for (KVOObjectItem* objc in kvoObjectSet) {
        if ([objc.observer isEqual:observer] && [objc.whichObject isEqual:object] && [objc.keyPath isEqualToString:keyPath]) {
            [tmpSet addObject:objc];
            success = YES;
        } else if (!objc.observer || !objc.whichObject) {
            [tmpSet addObject:objc];
        }
    }
    
    [tmpSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        [kvoObjectSet removeObject:obj];
    }];

    [self.kvoLock unlock];
    return success;
}

/**
 Ignore Special Library
 
 @param object Instance Class
 @return YES or NO
 */
- (BOOL)ignoreKVOInstanceClass:(id)object{
    
    if (!object) {
        return NO;
    }
    
    //Ignore ReactiveCocoa
    if (object_getClass(object) == objc_getClass("RACKVOProxy")) {
        return YES;
    }
    
    //Ignore AMAP
    NSString* className = NSStringFromClass(object_getClass(object));
    if ([className hasPrefix:@"AMap"]) {
        return YES;
    }
    
    return NO;
}

/**
 * Hook the kvo object dealloc and to clean the kvo array
 */
- (BOOL)deallocating {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    return [objc_getAssociatedObject(self, @selector(Deallocating)) boolValue];
    #pragma clang diagnostic pop
}

- (NSMutableSet *)kvoObjectSet {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    NSMutableSet* set = objc_getAssociatedObject(self,@selector(kvoObjectSet));
        if (!set) {
            set = [NSMutableSet new];
            objc_setAssociatedObject(self, @selector(kvoObjectSet), set, OBJC_ASSOCIATION_RETAIN);
        }
    return set;
    #pragma clang diagnostic pop
}

- (void)jj_cleanKVO {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    objc_setAssociatedObject(self, @selector(Deallocating), @YES, OBJC_ASSOCIATION_ASSIGN);
    #pragma clang diagnostic pop
    [self.kvoLock lock];
    for (KVOObjectItem* item in self.kvoObjectSet) {
        if (item.observer) {
            [self hookRemoveObserver:item.observer forKeyPath:item.keyPath];
            [item.observer removeItemWithObject:item.whichObject observer:item.observer forKeyPath:item.keyPath];
        } else {
            [item.whichObject hookRemoveObserver:self forKeyPath:item.keyPath];
            [item.whichObject removeItemWithObject:item.whichObject observer:item.observer forKeyPath:item.keyPath];
        }
    }
    [self.kvoObjectSet removeAllObjects];

    [self.kvoLock unlock];
}

@end
