//
//  JJExceptionProxy.m
//  JJException
//
//  Created by Jezz on 2018/7/22.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "JJExceptionProxy.h"

void handleCrashException(NSString* exceptionMessage){
    [[JJExceptionProxy shareExceptionProxy] handleCrashException:exceptionMessage];
}

@implementation JJExceptionProxy

+(instancetype)shareExceptionProxy{
    static dispatch_once_t onceToken;
    static id exceptionProxy;
    dispatch_once(&onceToken, ^{
        exceptionProxy = [[self alloc] init];
    });
    return exceptionProxy;
}

- (void)handleCrashException:(NSString *)exceptionMessage{
    if (!exceptionMessage) {
        return;
    }
    if (![self.delegate respondsToSelector:@selector(handleCrashException:)]){
        return;
    }
    NSArray* callStack = [NSThread callStackSymbols];
    NSString* callStackString = [NSString stringWithFormat:@"%@",callStack];
    
    NSString* exceptionResult = [NSString stringWithFormat:@"%@\n%@",exceptionMessage,callStackString];
    
    [self.delegate handleCrashException:exceptionResult];
}

@end
