//
//  NSNotificationCenter+ClearNotification.m
//  JJException
//
//  Created by Jezz on 2018/9/6.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSNotificationCenter+ClearNotification.h"
#import "NSObject+SwizzleHook.h"
#import "NSObject+DeallocBlock.h"
#import "JJExceptionMacros.h"
#import <objc/runtime.h>
#import <pthread.h>

/**
 Copy the NSNotification Info
 */
@interface JJNotificationObject : NSObject

@property (nonatomic,readwrite,copy) NSString* name;

@property(nonatomic,readwrite,weak)id observer;

@property(nonatomic,readwrite,assign)id object;

@end


@implementation JJNotificationObject

- (NSString *)debugDescription{
    return [NSString stringWithFormat:@"<%@: %p> name: %@ observer: %@ object: %@", NSStringFromClass([self class]), self, _name, _observer, _object];
}

- (NSString *)description{
    return [self debugDescription];
}

@end


JJSYNTH_DUMMY_CLASS(NSNotificationCenter_ClearNotification)

@implementation NSNotificationCenter (ClearNotification)

static pthread_mutex_t jj_notification_lock;
static NSMutableDictionary *jj_observerInfo;

NSString * jj_observerInfoKey(id observer){
    NSString *className = NSStringFromClass([observer class]);
    NSString *key = [NSString stringWithFormat:@"%@_%p", className, observer];
    return key;
}

void jj_setNotificationObserverInfo(id observer, NSNotificationName name, id anObject){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&jj_notification_lock, NULL);
        jj_observerInfo = [[NSMutableDictionary alloc] init];
    });
    JJNotificationObject *observerInfo = [[JJNotificationObject alloc] init];
    observerInfo.observer = observer;
    observerInfo.name = name;
    observerInfo.object = anObject;
    NSString *key = jj_observerInfoKey(observer);
    NSMutableArray *infos = jj_notificationObserverInfos(observer);
    pthread_mutex_lock(&jj_notification_lock);
    if (!infos) {
        infos = [[NSMutableArray alloc] init];
    }
    [infos addObject:observerInfo];
    [jj_observerInfo setObject:infos forKey:key];
    pthread_mutex_unlock(&jj_notification_lock);
}

NSMutableArray <JJNotificationObject *>* jj_notificationObserverInfos(id observer){
    if (!jj_observerInfo || (jj_observerInfo.count == 0)) {
        return nil;
    }
    NSMutableArray <JJNotificationObject *>*objcets = nil;
    NSString *key = jj_observerInfoKey(observer);
    pthread_mutex_lock(&jj_notification_lock);
    objcets = [jj_observerInfo objectForKey:key];
    pthread_mutex_unlock(&jj_notification_lock);
    return objcets;
}

void jj_removeNotificationObserverInfo(id observer){
    if (!jj_observerInfo || (jj_observerInfo.count == 0)) {
        return ;
    }
    NSString *key = jj_observerInfoKey(observer);
    pthread_mutex_lock(&jj_notification_lock);
    [jj_observerInfo removeObjectForKey:key];
    pthread_mutex_unlock(&jj_notification_lock);
}

+ (void)jj_swizzleNSNotificationCenter{
    [self jj_swizzleInstanceMethod:@selector(addObserver:selector:name:object:) withSwizzledBlock:^id(JJSwizzleObject *swizzleInfo) {
        return ^(__unsafe_unretained id self,id observer,SEL aSelector,NSString* aName,id anObject){
            [self processAddObserver:observer selector:aSelector name:aName object:anObject swizzleInfo:swizzleInfo];
        };
    }];
}

- (void)processAddObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject swizzleInfo:(JJSwizzleObject*)swizzleInfo{

    if (!observer) {
        return;
    }

    if ([observer isKindOfClass:NSObject.class]) {
        jj_setNotificationObserverInfo(observer, aName, anObject);
        __unsafe_unretained typeof(observer) unsafeObject = observer;
        [observer jj_deallocBlock:^{
            NSMutableArray <JJNotificationObject *>*infos = jj_notificationObserverInfos(unsafeObject);
            jj_removeNotificationObserverInfo(unsafeObject);
            if ([infos isKindOfClass:[NSArray class]] && infos.count > 0) {
                for (JJNotificationObject *jjObject in infos) {
                    /**
                     this is a safe way to remove observer
                     https://stackoverflow.com/questions/21418726/ios-remove-observer-from-notification-can-i-call-this-once-for-all-observers-a
                     https://useyourloaf.com/blog/unregistering-nsnotificationcenter-observers-in-ios-9/
                     */
                    [[NSNotificationCenter defaultCenter] removeObserver:unsafeObject name:jjObject.name object:jjObject.object];
                }
            }
        }];
    }
    
    void(*originIMP)(__unsafe_unretained id,SEL,id,SEL,NSString*,id);
    originIMP = (__typeof(originIMP))[swizzleInfo getOriginalImplementation];
    if (originIMP != NULL) {
        originIMP(self,swizzleInfo.selector,observer,aSelector,aName,anObject);
    }
}

@end
