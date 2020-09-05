//
//  NSTimer+CleanResource.m
//  JJException
//
//  Created by Jezz on 2018/9/4.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSTimer+CleanTimer.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"

/**
 Copy the NSTimer Info
 */
@interface TimerObject : NSObject

@property(nonatomic,readwrite,assign)NSTimeInterval ti;

/**
 weak reference target
 */
@property(nonatomic,readwrite,weak)id target;

@property(nonatomic,readwrite,assign)SEL selector;

@property(nonatomic,readwrite,assign)id userInfo;

/**
 TimerObject Associated NSTimer
 */
@property(nonatomic,readwrite,weak)NSTimer* timer;

/**
 Record the target class name
 */
@property(nonatomic,readwrite,copy)NSString* targetClassName;

/**
 Record the target method name
 */
@property(nonatomic,readwrite,copy)NSString* targetMethodName;

@end


@implementation TimerObject

- (void)fireTimer{
    if (!self.target) {
        [self.timer invalidate];
        self.timer = nil;
        handleCrashException(JJExceptionGuardNSTimer,[NSString stringWithFormat:@"Need invalidate timer from target:%@ method:%@",self.targetClassName,self.targetMethodName]);
        return;
    }
    if ([self.target respondsToSelector:self.selector]) {
        // Fix performSelector maybe some memmory leak or return object crash
        NSMethodSignature* signature = [self.target methodSignatureForSelector:self.selector];
        if (!signature) {
            return;
        }
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = self.target;
        invocation.selector = self.selector;
        if (signature.numberOfArguments > 2) {
            [invocation setArgument:&_timer atIndex:2];
        }
        [invocation retainArguments];
        [invocation invoke];
    }
}

@end

@implementation NSTimer (CleanTimer)

+ (void)jj_swizzleNSTimer{
    swizzleClassMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:), @selector(hookScheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
}

+ (NSTimer*)hookScheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    if (!yesOrNo) {
        return [self hookScheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }
    TimerObject* timerObject = [TimerObject new];
    timerObject.ti = ti;
    timerObject.target = aTarget;
    timerObject.selector = aSelector;
    timerObject.userInfo = userInfo;
    if (aTarget) {
        timerObject.targetClassName = [NSString stringWithCString:object_getClassName(aTarget) encoding:NSASCIIStringEncoding];
    }
    timerObject.targetMethodName = NSStringFromSelector(aSelector);
    
    NSTimer* timer = [NSTimer hookScheduledTimerWithTimeInterval:ti target:timerObject selector:@selector(fireTimer) userInfo:userInfo repeats:yesOrNo];
    timerObject.timer = timer;
    
    return timer;
    
}

@end
