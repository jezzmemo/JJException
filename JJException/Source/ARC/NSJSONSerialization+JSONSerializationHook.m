//
//  NSJSONSerialization+JSONSerializationHook.m
//  JJException
//
//  Created by mac on 2021/7/5.
//  Copyright © 2021 Jezz. All rights reserved.
//

#import "NSJSONSerialization+JSONSerializationHook.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import "JJExceptionProxy.h"
#import "JJExceptionMacros.h"

JJSYNTH_DUMMY_CLASS(NSJSONSerialization_JSONSerializationHook)

@implementation NSJSONSerialization (JSONSerializationHook)

+ (void)jj_swizzleNSJSONSerialization{
    [NSJSONSerialization jj_swizzleClassMethod:@selector(dataWithJSONObject:options:error:) withSwizzleMethod:@selector(hookDataWithJSONObject:options:error:)];
    [NSJSONSerialization jj_swizzleClassMethod:@selector(JSONObjectWithData:options:error:) withSwizzleMethod:@selector(hookJSONObjectWithData:options:error:)];
    [NSJSONSerialization jj_swizzleClassMethod:@selector(writeJSONObject:toStream:options:error:) withSwizzleMethod:@selector(hookWriteJSONObject:toStream:options:error:)];
    [NSJSONSerialization jj_swizzleClassMethod:@selector(JSONObjectWithStream:options:error:) withSwizzleMethod:@selector(hookJSONObjectWithStream:options:error:)];
}

+ (nullable NSData *)hookDataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error{
    if (!obj){
        handleCrashException(JJExceptionGuardJSONSerialization,@"NSJSONSerialization dataWithJSONObject:options:error: obj parameter is nil");
        return nil;
    }
    return [self hookDataWithJSONObject:obj options:opt error:error];
}

+ (nullable id)hookJSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error{
    if (!data.length){
        handleCrashException(JJExceptionGuardJSONSerialization,@"NSJSONSerialization JSONObjectWithData:options:error: data parameter is nil");
        return nil;
    }
    return [self hookJSONObjectWithData:data options:opt error:error];
}

+ (NSInteger)hookWriteJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error{
    if (!stream.hasSpaceAvailable){
        handleCrashException(JJExceptionGuardJSONSerialization,@"NSJSONSerialization writeJSONObject:toStream:options:error: stream is not open for writing");
        return 0;
    }
    
    if (!obj) {
        handleCrashException(JJExceptionGuardJSONSerialization,@"NSJSONSerialization writeJSONObject:toStream:options:error: obj parameter is nil");
        return 0;
    }
    return [self hookWriteJSONObject:obj toStream:stream options:opt error:error];
}

+ (nullable id)hookJSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error{
    if (!stream.hasBytesAvailable){
        handleCrashException(JJExceptionGuardJSONSerialization,@"NSJSONSerialization JSONObjectWithStream:options:error: stream is not open for reading");
        return nil;
    }
    return [self hookJSONObjectWithStream:stream options:opt error:error];
}

@end
