//
//  NSNotificationCenter+ClearNotification.m
//  JJException
//
//  Created by Jezz on 2018/9/6.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSNotificationCenter+ClearNotification.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>

static const char DeallocNotificationCenterStubKey;

@interface NotificationCenterStub : NSObject

/**
 Observer object dealloc
 */
@property(nonatomic,readwrite,unsafe_unretained)id stubObject;

@end

@implementation NotificationCenterStub

/**
 Clean NSNotificationCenter StubObject data
 */
- (void)dealloc{
    if (self.stubObject) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.stubObject];
    }
    self.stubObject = nil;
}

@end


@implementation NSNotificationCenter (ClearNotification)

+ (void)jj_swizzleNSNotificationCenter{
    swizzleInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), @selector(hookAddObserver:selector:name:object:));
}

- (void)hookAddObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject{
    
    if (observer) {
        NotificationCenterStub* object = objc_getAssociatedObject(observer, &DeallocNotificationCenterStubKey);
        if (!object) {
            NotificationCenterStub* stub = [NotificationCenterStub new];
            [stub setStubObject:observer];
            objc_setAssociatedObject(observer, &DeallocNotificationCenterStubKey, stub, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [self hookAddObserver:observer selector:aSelector name:aName object:anObject];
    }
}

@end
