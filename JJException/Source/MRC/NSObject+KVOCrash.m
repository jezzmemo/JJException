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

/** 观察者 (如果是weak，当observer被dealloc时做清理操作，读取item的observer，此时item的被weak修饰的observer属性已经被置nil了) */
@property(nonatomic,readwrite,assign)NSObject* observer;
/** 被观察者 */
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
    // self.observer可能已释放
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

- (void)checkAddKVOItemExist:(KVOObjectItem*)item blk:(void (^)(void))blk;

@end

@implementation KVOObjectContainer

- (void)checkAddKVOItemExist:(KVOObjectItem*)item blk:(void (^)(void))blk{
    dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
    if (!item) {
        dispatch_semaphore_signal(self.kvoLock);
        return;
    }
    BOOL exist = [self.kvoObjectSet containsObject:item];
    if (!exist) {
        if (blk) {
            blk();
        }
        [self.kvoObjectSet addObject:item];
    }
    dispatch_semaphore_signal(self.kvoLock);
}

- (void)lock:(void (^)(NSMutableSet *kvoObjectSet))blk {
    if (blk) {
        dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
        blk(self.kvoObjectSet);
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
    [objectContainer checkAddKVOItemExist:item blk:^{
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    }];
    
    // 观察者observer：记录自己观察了谁
    KVOObjectContainer* observerContainer = objc_getAssociatedObject(observer,&DeallocKVOKey);
    if (!observerContainer) {
        observerContainer = [KVOObjectContainer new];
        objc_setAssociatedObject(observer, &DeallocKVOKey, observerContainer, OBJC_ASSOCIATION_RETAIN);
        [observerContainer release];
    }
    [observerContainer checkAddKVOItemExist:item blk:nil];

    [item release];

    // 观察者和被观察者都需要：要在dealloc之前清理和自己相关的观察关系jj_cleanKVO
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

    // 被观察者removeObserver(观察者)：清理被观察者的关系
    // (观察者dealloc的时候会去清理自己的,当然被观察者delloc时也会去清理,针对不同场景处理。)
    KVOObjectContainer* objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);
    if (!objectContainer) {
        return;
    }

    /*
     * Fix observer associated bug,disconnect the self and observer,
     * bug link:https://github.com/jezzmemo/JJException/issues/68
     */
    [objectContainer lock:^(NSMutableSet *kvoObjectSet) {
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
            resultItem.observer = nil;
            resultItem.whichObject = nil;
            resultItem.keyPath = nil;
            [kvoObjectSet removeObject:resultItem];
        }
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
    
    if (objectContainer) { // 清理和自己相关的观察关系
        [objectContainer cleanKVOData];
    }
}

@end
