//
//  NSMutableString+MutableStringHook.m
//  JJException
//
//  Created by Jezz on 2018/9/18.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSMutableString+MutableStringHook.h"
#import "NSObject+SwizzleHook.h"

@implementation NSMutableString (MutableStringHook)

+ (void)jj_swizzleNSMutableString{
    
    swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderMutableString"), @selector(initWithCString:encoding:), @selector(hookInitWithCString:encoding:));
    
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(appendString:), @selector(hookAppendString:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(insertString:atIndex:), @selector(hookInsertString:atIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(deleteCharactersInRange:), @selector(hookDeleteCharactersInRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringFromIndex:), @selector(hookSubstringFromIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringToIndex:), @selector(hookSubstringToIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFString"), @selector(substringWithRange:), @selector(hookSubstringWithRange:));
    
}

- (nullable instancetype) hookInitWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding{
    if (NULL != nullTerminatedCString){
        return [self hookInitWithCString:nullTerminatedCString encoding:encoding];
    }
    return nil;
}

- (void) hookAppendString:(NSString *)aString{
    if (aString){
        [self hookAppendString:aString];
    }else{
    }
}

- (void) hookInsertString:(NSString *)aString atIndex:(NSUInteger)loc{
    if (aString && loc <= self.length) {
        [self hookInsertString:aString atIndex:loc];
    }else{
    }
}

- (void) hookDeleteCharactersInRange:(NSRange)range{
    if (range.location + range.length <= self.length){
        [self hookDeleteCharactersInRange:range];
    }else{
        
    }
}

- (NSString *)hookStringByAppendingString:(NSString *)aString{
    if (aString){
        return [self hookStringByAppendingString:aString];
    }
    return self;
}

- (NSString *)hookSubstringFromIndex:(NSUInteger)from{
    if (from <= self.length) {
        return [self hookSubstringFromIndex:from];
    }
    return nil;
}

- (NSString *)hookSubstringToIndex:(NSUInteger)to{
    if (to <= self.length) {
        return [self hookSubstringToIndex:to];
    }
    return self;
}

- (NSString *)hookSubstringWithRange:(NSRange)range{
    if (range.location + range.length <= self.length) {
        return [self hookSubstringWithRange:range];
    }else if (range.location < self.length){
        return [self hookSubstringWithRange:NSMakeRange(range.location, self.length-range.location)];
    }
    return nil;
}

@end
