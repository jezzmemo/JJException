//
//  NSMutableString+MutableStringHook.m
//  JJException
//
//  Created by Jezz on 2018/9/18.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSMutableString+MutableStringHook.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"
#import "JJExceptionMacros.h"

JJSYNTH_DUMMY_CLASS(NSMutableString_MutableStringHook)

@implementation NSMutableString (MutableStringHook)

+ (void)jj_swizzleNSMutableString{
    //__NSCFString
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(appendString:), @selector(hookAppendString:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(insertString:atIndex:), @selector(hookInsertString:atIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(deleteCharactersInRange:), @selector(hookDeleteCharactersInRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringFromIndex:), @selector(hookSubstringFromIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringToIndex:), @selector(hookSubstringToIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringWithRange:), @selector(hookSubstringWithRange:));
}

- (void) hookAppendString:(NSString *)aString{
    if (aString){
        [self hookAppendString:aString];
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableString appendString value:%@ parameter nil",self]);
    }
}

- (void) hookInsertString:(NSString *)aString atIndex:(NSUInteger)loc{
    if (aString && loc <= self.length) {
        [self hookInsertString:aString atIndex:loc];
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableString insertString:atIndex: value:%@ paremeter string:%@ atIndex:%tu",self,aString,loc]);
    }
}

- (void) hookDeleteCharactersInRange:(NSRange)range{
    if (range.location + range.length <= self.length){
        [self hookDeleteCharactersInRange:range];
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableString deleteCharactersInRange value:%@ range:%@",self,NSStringFromRange(range)]);
    }
}

- (NSString *)hookSubstringFromIndex:(NSUInteger)from{
    if (from <= self.length) {
        return [self hookSubstringFromIndex:from];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableString substringFromIndex value:%@ from:%tu",self,from]);
    return nil;
}

- (NSString *)hookSubstringToIndex:(NSUInteger)to{
    if (to <= self.length) {
        return [self hookSubstringToIndex:to];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableString substringToIndex value:%@ to:%tu",self,to]);
    return self;
}

- (NSString *)hookSubstringWithRange:(NSRange)range{
    if (range.location + range.length <= self.length) {
        return [self hookSubstringWithRange:range];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableString substringWithRange value:%@ range:%@",self,NSStringFromRange(range)]);
    return nil;
}

@end
