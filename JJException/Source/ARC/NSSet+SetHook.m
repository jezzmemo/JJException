//
//  NSSet+SetHook.m
//  JJException
//
//  Created by Jezz on 2018/11/11.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSSet+SetHook.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"

@implementation NSSet (SetHook)

+ (void)jj_swizzleNSSet{
    [NSSet jj_swizzleClassMethod:@selector(setWithObject:) withSwizzleMethod:@selector(hookSetWithObject:)];
}

+ (instancetype)hookSetWithObject:(id)object{
    if (object){
        return [self hookSetWithObject:object];
    }
    handleCrashException(JJExceptionGuardArrayContainer,@"NSSet setWithObject nil object");
    return nil;
}

@end
