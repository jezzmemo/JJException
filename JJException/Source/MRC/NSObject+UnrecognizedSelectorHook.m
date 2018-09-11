//
//  NSObject+UnrecognizedSelectorHook.m
//  JJException
//
//  Created by Jezz on 2018/7/11.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSObject+UnrecognizedSelectorHook.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import "JJExceptionProxy.h"


@interface UnrecognizedSelectorHandle : NSObject

@property(nonatomic,readwrite,weak)id fromObject;

@end


@implementation UnrecognizedSelectorHandle

void unrecognizedSelector(UnrecognizedSelectorHandle* self, SEL _cmd){
    NSString* message = [NSString stringWithFormat:@"Unrecognized selector class:%@ and selector:%@",[self.fromObject class],NSStringFromSelector(_cmd)];
    handleCrashException(JJExceptionGuardUnrecognizedSelector,message);
}

@end

@implementation NSObject (UnrecognizedSelectorHook)

+ (void)jj_swizzleUnrecognizedSelector{
    swizzleInstanceMethod([self class], @selector(forwardingTargetForSelector:), @selector(forwardingTargetForSelectorSwizzled:));
}

- (id)forwardingTargetForSelectorSwizzled:(SEL)selector{
    NSMethodSignature* sign = [self methodSignatureForSelector:selector];
    if (!sign) {
        id stub = [[UnrecognizedSelectorHandle new] autorelease];
        [stub setFromObject:self];
        class_addMethod([stub class], selector, (IMP)unrecognizedSelector, "v@:");
        return stub;
    }
    return [self forwardingTargetForSelectorSwizzled:selector];
}

@end
