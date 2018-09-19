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
#import <objc/runtime.h>

@implementation NSNotificationCenter (ClearNotification)

+ (void)jj_swizzleNSNotificationCenter{
    swizzleInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:), @selector(hookAddObserver:selector:name:object:));
}

- (void)hookAddObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject{
    
    if (observer) {
        __unsafe_unretained typeof(observer) unsafeObject = observer;
        [observer jj_deallocBlock:^{
            [[NSNotificationCenter defaultCenter] removeObserver:unsafeObject];
        }];
        [self hookAddObserver:observer selector:aSelector name:aName object:anObject];
    }
}

@end
