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

JJSYNTH_DUMMY_CLASS(NSNotificationCenter_ClearNotification)

@implementation NSNotificationCenter (ClearNotification)

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
        __unsafe_unretained typeof(observer) unsafeObject = observer;
        [observer jj_deallocBlock:^{
            [[NSNotificationCenter defaultCenter] removeObserver:unsafeObject];
        }];
    }
    
    void(*originIMP)(__unsafe_unretained id,SEL,id,SEL,NSString*,id);
    originIMP = (__typeof(originIMP))[swizzleInfo getOriginalImplementation];
    if (originIMP != NULL) {
        originIMP(self,swizzleInfo.selector,observer,aSelector,aName,anObject);
    }
}

@end
