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
#import <objc/message.h>
#import "JJExceptionProxy.h"

static const char DeallocKVOKey;

/**
 Record the kvo object
 Override the isEqual and hash method
 */
@interface KVOObjectItem : NSObject

/// KVO observer
@property(nonatomic,readwrite,assign)NSObject* observer;

/// KVO which object
@property(nonatomic,readwrite,assign)NSObject* whichObject;

@property(nonatomic,readwrite,copy)NSString* keyPath;

@property(nonatomic,readwrite,assign)NSKeyValueObservingOptions options;

@property(nonatomic,readwrite,assign)void* context;

@end

@implementation KVOObjectItem

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (BOOL)isEqual:(KVOObjectItem*)object{
    // check object nil
    if (!self.observer || !self.whichObject || !self.keyPath
        || !object.observer || !object.whichObject || !object.keyPath) {
        return NO;
    }
    if ([self.observer isEqual:object.observer] && [self.whichObject isEqual:object.whichObject] && [self.keyPath isEqualToString:object.keyPath]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash{
    return [self.observer hash] ^ [self.whichObject hash] ^ [self.keyPath hash];
}

- (void)dealloc{
    self.observer = nil;
    self.whichObject = nil;
    self.context = nil;
    if (self.keyPath) {
        [self.keyPath release];
    }
    [super dealloc];
}

@end


@interface KVOObjectContainer : NSObject

/**
 KVO object array set
 */
@property(nonatomic,readwrite,retain)NSMutableSet* kvoObjectSet;

/**
 NSMutableSet safe-thread
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property(nonatomic,readwrite,retain)dispatch_semaphore_t kvoLock;
#else
@property(nonatomic,readwrite,assign)dispatch_semaphore_t kvoLock;
#endif

- (void)checkAddKVOItemExist:(KVOObjectItem*)item existResult:(void (^)(void))existResult;

@end

@implementation KVOObjectContainer

/// Check item exist and block result
/// @param item KVOObjectItem
/// @param existResult item exist block
- (void)checkAddKVOItemExist:(KVOObjectItem*)item existResult:(void (^)(void))existResult{
    dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
    if (!item) {
        dispatch_semaphore_signal(self.kvoLock);
        return;
    }
    BOOL exist = [self.kvoObjectSet containsObject:item];
    if (!exist) {
        if (existResult) {
            existResult();
        }
        [self.kvoObjectSet addObject:item];
    }
    dispatch_semaphore_signal(self.kvoLock);
}

- (void)lockObjectSet:(void (^)(NSMutableSet *kvoObjectSet))objectSet {
    if (objectSet) {
        dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
        objectSet(self.kvoObjectSet);
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
    [self.kvoObjectSet release];
    dispatch_release(self.kvoLock);
    [super dealloc];
}

/// Clean the kvo info and set the item property nil,break the reference
- (void)cleanKVOData{
    dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
    for (KVOObjectItem* item in self.kvoObjectSet) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        if (item.observer) {
            @try {
                ((void(*)(id,SEL,id,NSString*))objc_msgSend)(item.whichObject,@selector(hookRemoveObserver:forKeyPath:),item.observer,item.keyPath);
            }@catch (NSException *exception) {
            }
            item.observer = nil;
            item.whichObject = nil;
            item.keyPath = nil;
        }
        #pragma clang diagnostic pop
    }
    [self.kvoObjectSet removeAllObjects];
    dispatch_semaphore_signal(self.kvoLock);
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
    swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:context:), @selector(hookRemoveObserver:forKeyPath:context:));
    swizzleInstanceMethod([self class], @selector(observeValueForKeyPath:ofObject:change:context:), @selector(hookObserveValueForKeyPath:ofObject:change:context:));
}

- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if ([self ignoreKVOInstanceClass:observer]) {
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
        return;
    }

    if (!observer || keyPath.length == 0) {
        return;
    }

    // Record the kvo relation
    KVOObjectItem* item = [[KVOObjectItem alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    item.options = options;
    item.context = context;
    item.whichObject = self;

    // Observer current self
    KVOObjectContainer* objectContainer = objc_getAssociatedObject(self,&DeallocKVOKey);
    if (!objectContainer) {
        objectContainer = [KVOObjectContainer new];
        objc_setAssociatedObject(self, &DeallocKVOKey, objectContainer, OBJC_ASSOCIATION_RETAIN);
        [objectContainer release];
    }

    [objectContainer checkAddKVOItemExist:item existResult:^{
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    }];

    // Observer observer
    KVOObjectContainer* observerContainer = objc_getAssociatedObject(observer,&DeallocKVOKey);
    if (!observerContainer) {
        observerContainer = [KVOObjectContainer new];
        objc_setAssociatedObject(observer, &DeallocKVOKey, observerContainer, OBJC_ASSOCIATION_RETAIN);
        [observerContainer release];
    }
    [observerContainer checkAddKVOItemExist:item existResult:nil];

    [item release];

    // clean the self and observer
    jj_swizzleDeallocIfNeeded(self.class);
    jj_swizzleDeallocIfNeeded(observer.class);
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void*)context{
    if ([self ignoreKVOInstanceClass:observer]) {
        [self hookRemoveObserver:observer forKeyPath:keyPath context:context];
        return;
    }

    [self removeObserver:observer forKeyPath:keyPath];
}

- (void)hookRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if ([self ignoreKVOInstanceClass:observer]) {
        [self hookRemoveObserver:observer forKeyPath:keyPath];
        return;
    }

    if (!observer) {
        return;
    }

    KVOObjectContainer* objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);
    if (!objectContainer) {
        return;
    }

    /*
     * Fix observer associated bug,disconnect the self and observer,
     * bug link:https://github.com/jezzmemo/JJException/issues/68
     */
    [objectContainer lockObjectSet:^(NSMutableSet *kvoObjectSet) {
        KVOObjectItem* targetItem = [[KVOObjectItem alloc] init];
        targetItem.observer = observer;
        targetItem.whichObject = self;
        targetItem.keyPath = keyPath;

        KVOObjectItem* resultItem = nil;
        NSSet *set = [kvoObjectSet copy];
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
            //Clean the reference
            resultItem.observer = nil;
            resultItem.whichObject = nil;
            resultItem.keyPath = nil;
            [kvoObjectSet removeObject:resultItem];
        }
        /*
         * Fix memory leak,
         * bug link:https://github.com/jezzmemo/JJException/issues/131
         */
        [targetItem release];
        [set release];
    }];
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
    KVOObjectContainer* objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);

    if (objectContainer) {
        [objectContainer cleanKVOData];
    }
}

@end
