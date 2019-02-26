//
//  NSMutableSet+MutableSetHook.m
//  JJException
//
//  Created by Jezz on 2018/11/11.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSMutableSet+MutableSetHook.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import "JJExceptionProxy.h"
#import "JJExceptionMacros.h"

JJSYNTH_DUMMY_CLASS(NSMutableSet_MutableSetHook)

@implementation NSMutableSet (MutableSetHook)

+ (void)jj_swizzleNSMutableSet{
    NSMutableSet* instanceObject = [NSMutableSet new];
    Class cls =  object_getClass(instanceObject);
    
    swizzleInstanceMethod(cls,@selector(addObject:), @selector(hookAddObject:));
    swizzleInstanceMethod(cls,@selector(removeObject:), @selector(hookRemoveObject:));
}

- (void) hookAddObject:(id)object {
    if (object) {
        [self hookAddObject:object];
    } else {
        handleCrashException(JJExceptionGuardArrayContainer,@"NSSet addObject nil object");
    }
}

- (void) hookRemoveObject:(id)object {
    if (object) {
        [self hookRemoveObject:object];
    } else {
        handleCrashException(JJExceptionGuardArrayContainer,@"NSSet removeObject nil object");
    }
}

@end
