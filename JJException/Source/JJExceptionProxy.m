//
//  JJExceptionProxy.m
//  JJException
//
//  Created by Jezz on 2018/7/22.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "JJExceptionProxy.h"

void handleCrashException(NSString* exceptionMessage){
    [[JJExceptionProxy shareExceptionProxy] handleCrashException:exceptionMessage extraInfo:@{}];
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

- (void)handleCrashException:(NSString *)exceptionMessage extraInfo:(nullable NSDictionary *)info{
    if (!exceptionMessage) {
        return;
    }
    
    NSArray* callStack = [NSThread callStackSymbols];
    NSString* callStackString = [NSString stringWithFormat:@"%@",callStack];
    
    NSString* exceptionResult = [NSString stringWithFormat:@"%@\n%@",exceptionMessage,callStackString];
    
#ifdef DEBUG
    NSLog(@"================================JJException Start==================================");
    NSLog(@"%@",exceptionResult);
    NSLog(@"================================JJException End====================================");
#endif
    
    if (![self.delegate respondsToSelector:@selector(handleCrashException:extraInfo:)]){
        return;
    }
    
    [self.delegate handleCrashException:exceptionResult extraInfo:info];
}

- (void)addZombieObjectArray:(NSArray*)objects{
    if (!objects) {
        return;
    }
    [self.blackClassesSet addObjectsFromArray:objects];
}

- (NSMutableSet*)blackClassesSet{
    if (_blackClassesSet) {
        return _blackClassesSet;
    }
    _blackClassesSet = [NSMutableSet new];
    return _blackClassesSet;
}

- (NSMutableSet*)currentClassesSet{
    if (_currentClassesSet) {
        return _currentClassesSet;
    }
    _currentClassesSet = [NSMutableSet new];
    return _currentClassesSet;
}

- (id)objectFromCurrentClassesSet{
    NSEnumerator* objectEnum = [_currentClassesSet objectEnumerator];
    for (id object in objectEnum) {
        return object;
    }
    return nil;
}

@end
