//
//  NSMutableDictionary+MutableDictionaryHook.m
//  JJException
//
//  Created by Jezz on 2018/7/15.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSMutableDictionary+MutableDictionaryHook.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"

@implementation NSMutableDictionary (MutableDictionaryHook)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod(NSClassFromString(@"__NSDictionaryM"), @selector(setObject:forKey:), @selector(hookSetObject:forKey:));
        swizzleInstanceMethod(NSClassFromString(@"__NSDictionaryM"), @selector(removeObjectForKey:), @selector(hookRemoveObjectForKey:));
    });
}

- (void) hookSetObject:(id)object forKey:(id)key {
    if (object && key) {
        [self hookSetObject:object forKey:key];
    }else{
        handleCrashException([NSString stringWithFormat:@"HookSetObject invalid object:%@ and key:%@",object,key]);
    }
}

- (void) hookRemoveObjectForKey:(id)key {
    if (key) {
        [self hookRemoveObjectForKey:key];
    }else{
        handleCrashException([NSString stringWithFormat:@"HookRemoveObjectForKey invalid key:%@",key]);
    }
}

@end
