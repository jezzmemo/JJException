//
//  NSDictionary+DictionaryHook.m
//  JJException
//
//  Created by Jezz on 2018/7/15.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSDictionary+DictionaryHook.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"
#import "JJExceptionMacros.h"

JJSYNTH_DUMMY_CLASS(NSDictionary_DictionaryHook)

@implementation NSDictionary (DictionaryHook)

+ (void)jj_swizzleNSDictionary{
    [NSDictionary jj_swizzleClassMethod:@selector(dictionaryWithObject:forKey:) withSwizzleMethod:@selector(hookDictionaryWithObject:forKey:)];
    [NSDictionary jj_swizzleClassMethod:@selector(dictionaryWithObjects:forKeys:count:) withSwizzleMethod:@selector(hookDictionaryWithObjects:forKeys:count:)];
}

+ (instancetype) hookDictionaryWithObject:(id)object forKey:(id)key
{
    if (object && key) {
        return [self hookDictionaryWithObject:object forKey:key];
    }
    handleCrashException(JJExceptionGuardDictionaryContainer,[NSString stringWithFormat:@"NSDictionary dictionaryWithObject invalid object:%@ and key:%@",object,key]);
    return nil;
}
+ (instancetype) hookDictionaryWithObjects:(const id [])objects forKeys:(const id [])keys count:(NSUInteger)cnt
{
    NSInteger index = 0;
    id ks[cnt];
    id objs[cnt];
    for (NSInteger i = 0; i < cnt ; ++i) {
        if (keys[i] && objects[i]) {
            ks[index] = keys[i];
            objs[index] = objects[i];
            ++index;
        }else{
            handleCrashException(JJExceptionGuardDictionaryContainer,[NSString stringWithFormat:@"NSDictionary dictionaryWithObjects invalid keys:%@ and object:%@",keys[i],objects[i]]);
        }
    }
    return [self hookDictionaryWithObjects:objs forKeys:ks count:index];
}

@end
