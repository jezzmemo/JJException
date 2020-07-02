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
#import "KVOObjectContainer.h"



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
        NSLog(@"0🌲🌲🌲🌲");
//        lock = dispatch_semaphore_create(1);
        lock = [[NSRecursiveLock alloc] init];

        objc_setAssociatedObject(self, @selector(kvoLock), lock, OBJC_ASSOCIATION_RETAIN);
    }
    return lock;
}

- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
        [self.kvoLock lock];
        NSLog(@"1🔥wait");
        if ([self ignoreKVOInstanceClass:observer]) {
            [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
            NSLog(@"1🔥signal💦");
            [self.kvoLock unlock];
            return;
        }
        
        if (!observer || keyPath.length == 0) {
            NSLog(@"1🔥signal💦");
            [self.kvoLock unlock];
            return;
        }
        
        // item记录关系
        KVOObjectItem* item = [[KVOObjectItem alloc] init];
        item.observer = observer;
        item.keyPath = keyPath;
        item.options = options;
        item.context = context;
        item.whichObject = self;
        
        // 被观察者self：记录谁观察了自己
        KVOObjectContainer* objectContainer = objc_getAssociatedObject(self,&DeallocKVOKey);
        if (!objectContainer) {
            objectContainer = [KVOObjectContainer new];
            objc_setAssociatedObject(self, &DeallocKVOKey, objectContainer, OBJC_ASSOCIATION_RETAIN);
            [objectContainer release];
        }
        [objectContainer.kvoObjectSet addObject:item];
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
        
        // 观察者observer：记录自己观察了谁
        KVOObjectContainer* observerContainer = objc_getAssociatedObject(observer,&DeallocKVOKey);
        if (!observerContainer) {
            @autoreleasepool {
                observerContainer = [KVOObjectContainer new];
                objc_setAssociatedObject(observer, &DeallocKVOKey, observerContainer, OBJC_ASSOCIATION_RETAIN);
                [observerContainer release];
            }
        }
        [observerContainer.kvoObjectSet addObject:item];
        [item release];
        
        // 观察者和被观察者都需要：要在dealloc之前清理和自己相关的观察关系jj_cleanKVO
        jj_swizzleDeallocIfNeeded(self.class);
        jj_swizzleDeallocIfNeeded(observer.class);
        NSLog(@"1🔥signal💦");
        [self.kvoLock unlock];
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void*)context{
        [self.kvoLock lock];
        NSLog(@"2🔥wait");
        if ([self ignoreKVOInstanceClass:observer]) {
            [self hookRemoveObserver:observer forKeyPath:keyPath context:context];
            NSLog(@"2🔥signal💦");
            [self.kvoLock unlock];
        } else {
            NSLog(@"2🔥signal💦");
            [self.kvoLock unlock];
            [self removeObserver:observer forKeyPath:keyPath];
        }
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
        
        [self.kvoLock lock];
        NSLog(@"3🔥wait");
        if ([self ignoreKVOInstanceClass:observer]) {
            [self hookRemoveObserver:observer forKeyPath:keyPath];
            NSLog(@"3🔥signal💦");
            [self.kvoLock unlock];
            return;
        }
        
        if (!observer) {
            NSLog(@"3🔥signal💦");
            [self.kvoLock unlock];
            return;
        }
        
        // 被观察者removeObserver(观察者)：清理被观察者的关系
        // (观察者dealloc的时候会去清理自己的,当然被观察者delloc时也会去清理,针对不同场景处理。)
        KVOObjectContainer* objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);
        if (!objectContainer) {
            NSLog(@"3🔥signal💦");
            [self.kvoLock unlock];
            return;
        }
        
        /*
         * Fix observer associated bug,disconnect the self and observer,
         * bug link:https://github.com/jezzmemo/JJException/issues/68
         */
        KVOObjectItem* targetItem = [[KVOObjectItem alloc] init];
        targetItem.observer = observer;
        targetItem.whichObject = self;
        targetItem.keyPath = keyPath;
        
        KVOObjectItem* resultItem = nil;
        NSSet *set = [objectContainer.kvoObjectSet copy];
        for (KVOObjectItem* item in set) {
            if ([item isEqual:targetItem]) {
                resultItem = item;
                break;
            }
        }
        if (resultItem) {
            @try {
                [self hookRemoveObserver:observer forKeyPath:keyPath];
            }@catch (NSException *exception) {
            }
            resultItem.observer = nil;
            resultItem.whichObject = nil;
            resultItem.keyPath = nil;
            [objectContainer.kvoObjectSet removeObject:resultItem];
        }
        [targetItem release];
        [set release];
        NSLog(@"3🔥signal💦");
        [self.kvoLock unlock];
}

- (void)hookObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([self ignoreKVOInstanceClass:object]) {
        [self hookObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    @try {
        [self hookObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    } @catch (NSException *exception) {
        handleCrashException(JJExceptionGuardKVOCrash, exception.description);
    }
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
- (void)jj_cleanKVO{
    [self.kvoLock lock];
    NSLog(@"4☠️☠️☠️4%@", self);
    KVOObjectContainer* objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);
    
    if (objectContainer) { // 清理和自己相关的观察关系
        NSLog(@"4☠️☠️☠️☠️%@", self);
        [objectContainer cleanKVOData];
    }
    [self.kvoLock unlock];
//    dispatch_release(self.kvoLock);
}

@end
