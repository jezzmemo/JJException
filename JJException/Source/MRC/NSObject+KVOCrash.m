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
static const char ObserverDeallocKVOKey;

/**
 Record the kvo object
 Override the isEqual and hash method
 */
@interface KVOObjectItem : NSObject

@property(nonatomic,readwrite,assign)NSObject* observer;
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

- (void)dealloc{
    self.observer = nil;
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
 Associated owner object
 */
@property(nonatomic,readwrite,unsafe_unretained)NSObject* whichObject;

/**
 NSMutableSet safe-thread
 */
#if OS_OBJECT_HAVE_OBJC_SUPPORT
@property(nonatomic,readwrite,retain)dispatch_semaphore_t kvoLock;
#else
@property(nonatomic,readwrite,assign)dispatch_semaphore_t kvoLock;
#endif

- (void)addKVOObjectItem:(KVOObjectItem*)item;

- (void)removeKVOObjectItem:(KVOObjectItem*)item;

- (BOOL)checkKVOItemExist:(KVOObjectItem*)item;

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

- (BOOL)checkKVOItemExist:(KVOObjectItem*)item{
    dispatch_semaphore_wait(self.kvoLock, DISPATCH_TIME_FOREVER);
    BOOL exist = NO;
    if (!item) {
        dispatch_semaphore_signal(self.kvoLock);
        return exist;
    }
    exist = [self.kvoObjectSet containsObject:item];
    dispatch_semaphore_signal(self.kvoLock);
    return exist;
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
    self.whichObject = nil;
    dispatch_release(self.kvoLock);
    [super dealloc];
}

- (void)cleanKVOData{
    for (KVOObjectItem* item in self.kvoObjectSet) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        @try {
            ((void(*)(id,SEL,id,NSString*))objc_msgSend)(self.whichObject,@selector(hookRemoveObserver:forKeyPath:),item.observer,item.keyPath);
        }@catch (NSException *exception) {
        }
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

@interface JJObserverContainer : NSObject

@property (nonatomic,readwrite,retain) NSHashTable* observers;

/**
 Associated owner object
 */
@property(nonatomic,readwrite,assign) NSObject* whichObject;

- (void)addObserver:(KVOObjectItem *)observer;

- (void)removeObserver:(KVOObjectItem *)observer;

@end

@implementation JJObserverContainer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.observers = [NSHashTable hashTableWithOptions:NSMapTableWeakMemory];
    }
    return self;
}

- (void)addObserver:(KVOObjectItem *)observer
{
    @synchronized (self) {
        [self.observers addObject:observer];
    }
}

- (void)removeObserver:(KVOObjectItem *)observer
{
    @synchronized (self) {
        [self.observers removeObject:observer];
    }
}

- (void)cleanObservers{
    for (KVOObjectItem* item in self.observers) {
        [self.whichObject removeObserver:item.observer forKeyPath:item.keyPath];
        
    }
    @synchronized (self) {
        [self.observers removeAllObjects];
    }
}

- (void)dealloc{
    self.whichObject = nil;
    [self.observers release];
    [super dealloc];
}

@end

@implementation NSObject (KVOCrash)

+ (void)jj_swizzleKVOCrash{
    swizzleInstanceMethod([self class], @selector(addObserver:forKeyPath:options:context:), @selector(hookAddObserver:forKeyPath:options:context:));
    swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:), @selector(hookRemoveObserver:forKeyPath:));
    swizzleInstanceMethod([self class], @selector(removeObserver:forKeyPath:context:), @selector(hookRemoveObserver:forKeyPath:context:));
}

- (void)hookAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if ([self ignoreKVOInstanceClass:observer]) {
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
        return;
    }
    
    if (!observer || keyPath.length == 0) {
        return;
    }
    
    KVOObjectContainer* objectContainer = objc_getAssociatedObject(self,&DeallocKVOKey);
    
    KVOObjectItem* item = [[KVOObjectItem alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    item.options = options;
    item.context = context;
    
    if (!objectContainer) {
        objectContainer = [KVOObjectContainer new];
        [objectContainer setWhichObject:self];
        objc_setAssociatedObject(self, &DeallocKVOKey, objectContainer, OBJC_ASSOCIATION_RETAIN);
        [objectContainer release];
    }
    
    if (![objectContainer checkKVOItemExist:item]) {
        [objectContainer addKVOObjectItem:item];
        [self hookAddObserver:observer forKeyPath:keyPath options:options context:context];
    }
    
    JJObserverContainer* observerContainer = objc_getAssociatedObject(observer,&ObserverDeallocKVOKey);
    
    if (!observerContainer) {
        observerContainer = [JJObserverContainer new];
        [observerContainer setWhichObject:self];
        [observerContainer addObserver:item];
        objc_setAssociatedObject(observer, &ObserverDeallocKVOKey, observerContainer, OBJC_ASSOCIATION_RETAIN);
        [observerContainer release];
    }else{
        [observerContainer addObserver:item];
    }
    
    [item release];
    
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
    
    KVOObjectContainer* objectContainer = objc_getAssociatedObject(self, &DeallocKVOKey);
    
    if (!observer) {
        return;
    }
    
    if (!objectContainer) {
        return;
    }
    
    KVOObjectItem* item = [[KVOObjectItem alloc] init];
    item.observer = observer;
    item.keyPath = keyPath;
    
    if ([objectContainer checkKVOItemExist:item]) {
        @try {
            [self hookRemoveObserver:observer forKeyPath:keyPath];
        }@catch (NSException *exception) {
        }
        [objectContainer removeKVOObjectItem:item];
    }
    
    [item release];
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
    JJObserverContainer* observerContainer = objc_getAssociatedObject(self, &ObserverDeallocKVOKey);
    
    if (objectContainer) {
        [objectContainer cleanKVOData];
    }else if(observerContainer){
        [observerContainer cleanObservers];
    }
}

@end
