//
//  NSObject+KVCCrash.m
//  JJException
//
//  Created by 无头骑士 GJ on 2019/1/30.
//  Copyright © 2019 Jezz. All rights reserved.
//

#import "NSObject+KVCCrash.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"
#import <objc/message.h>

@implementation NSObject (KVCCrash)
+ (void)jj_swizzleKVCCrash
{
     swizzleInstanceMethod([self class], @selector(setValue:forKey:), @selector(hookSetValue:forKey:));
}

- (void)hookSetValue:(id)value forKey:(NSString *)key
{
    if (key.length == 0) return;
    

    NSString *methodSuffix = [NSString stringWithFormat: @"%@%@", [[key substringToIndex: 1] uppercaseString], [key substringFromIndex: 1]];
    
    // 1、判断setKey方法是否存在
    SEL setXXSelector = NSSelectorFromString([NSString stringWithFormat: @"set%@", methodSuffix]);
    Method setXXMethod = class_getInstanceMethod([self class], setXXSelector);
    
    if (setXXMethod)
    {
        [self hookSetValue: value forKey: key];
        return;
    }
    
    // 2、判断_setKey方法是否存在
    SEL _setXXSelector = NSSelectorFromString([NSString stringWithFormat: @"_set%@", methodSuffix]);
    Method _setXXMethod = class_getInstanceMethod([self class], _setXXSelector);
    if (_setXXMethod)
    {
        [self hookSetValue: value forKey: key];
        return;
    }
    
    // 3、accessInstanceVariablesDirectly的返回值，如果为NO，直接抛出异常
    SEL accessInstanceVariablesDirectlySEL = @selector(accessInstanceVariablesDirectly);
    NSMethodSignature *methodSignature = [NSMethodSignature methodSignatureForSelector: accessInstanceVariablesDirectlySEL];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: methodSignature];
    [invocation setSelector: accessInstanceVariablesDirectlySEL];
    [invocation invokeWithTarget: [self class]];
    
    BOOL result;
    [invocation getReturnValue: &result];
    
    // 异常处理
    if (result == NO)
    {
        handleCrashException(JJExceptionGuardKVCCrash, @"hookSetValue:forKey: key is not exist");
        return;
    }
    
    // 4、检查是否存在 _key、_isKey、key, isKey任一属性是否包含在成员变量中
    NSMutableArray *keys = [NSMutableArray array];
    [keys addObject: [NSString stringWithFormat: @"_%@", key]];
    [keys addObject: [NSString stringWithFormat: @"_is%@", methodSuffix]];
    [keys addObject: [NSString stringWithFormat: @"%@", key]];
    [keys addObject: [NSString stringWithFormat: @"is%@", methodSuffix]];
    
    unsigned  int count = 0;
    Ivar *members = class_copyIvarList([self class], &count);
    
    __block BOOL find = NO;
    for (int i = 0; i < count; i++)
    {
        Ivar var = members[i];
        NSString *memeberName = [[NSString alloc] initWithUTF8String: ivar_getName(var)];
        
        if (![[memeberName lowercaseString] containsString: key]) continue;
        
        [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isEqualToString: memeberName])
            {
                find = YES;
                [self hookSetValue: value forKey: key];
                *stop = YES;
            }
        }];
        
        if (find) break;
        
    }

    if (find == NO)
        handleCrashException(JJExceptionGuardKVCCrash, @"hookSetValue:forKey: key is not exist");
}


@end
