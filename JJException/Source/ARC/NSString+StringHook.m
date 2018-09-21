//
//  NSString+StringHook.m
//  JJException
//
//  Created by Jezz on 2018/9/18.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSString+StringHook.h"
#import "NSObject+SwizzleHook.h"

@implementation NSString (StringHook)

+ (void)jj_swizzleNSString{
    [NSString jj_swizzleClassMethod:@selector(stringWithUTF8String:) withSwizzleMethod:@selector(hookStringWithUTF8String:)];
    [NSString jj_swizzleClassMethod:@selector(stringWithCString:encoding:) withSwizzleMethod:@selector(hookStringWithCString:encoding:)];
    
    //NSPlaceholderString
    swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderString"), @selector(initWithCString:encoding:), @selector(hookInitWithCString:encoding:));
    swizzleInstanceMethod(NSClassFromString(@"NSPlaceholderString"), @selector(initWithString:), @selector(hookInitWithString:));
    
    //_NSCFConstantString
    swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(substringFromIndex:), @selector(hookSubstringFromIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(substringToIndex:), @selector(hookSubstringToIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(substringWithRange:), @selector(hookSubstringWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSCFConstantString"), @selector(rangeOfString:options:range:locale:), @selector(hookRangeOfString:options:range:locale:));
    
    //NSTaggedPointerString
    swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(substringFromIndex:), @selector(hookSubstringFromIndex:));
    swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(substringToIndex:), @selector(hookSubstringToIndex:));
    swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(substringWithRange:), @selector(hookSubstringWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"NSTaggedPointerString"), @selector(rangeOfString:options:range:locale:), @selector(hookRangeOfString:options:range:locale:));
}

+ (NSString*) hookStringWithUTF8String:(const char *)nullTerminatedCString
{
    if (NULL != nullTerminatedCString) {
        return [self hookStringWithUTF8String:nullTerminatedCString];
    }
    return nil;
}

+ (nullable instancetype) hookStringWithCString:(const char *)cString encoding:(NSStringEncoding)enc
{
    if (NULL != cString){
        return [self hookStringWithCString:cString encoding:enc];
    }
    return nil;
}

- (nullable instancetype) hookInitWithString:(id)cString{
    if (nil != cString){
        return [self hookInitWithString:cString];
    }
    return nil;
}

- (nullable instancetype) hookInitWithCString:(const char *)nullTerminatedCString encoding:(NSStringEncoding)encoding
{
    if (NULL != nullTerminatedCString){
        return [self hookInitWithCString:nullTerminatedCString encoding:encoding];
    }
    return nil;
}
- (NSString *)hookStringByAppendingString:(NSString *)aString
{
    if (aString){
        return [self hookStringByAppendingString:aString];
    }
    return self;
}
- (NSString *)hookSubstringFromIndex:(NSUInteger)from
{
    if (from <= self.length) {
        return [self hookSubstringFromIndex:from];
    }
    return nil;
}
- (NSString *)hookSubstringToIndex:(NSUInteger)to
{
    if (to <= self.length) {
        return [self hookSubstringToIndex:to];
    }
    return self;
}
- (NSString *)hookSubstringWithRange:(NSRange)range
{
    if (range.location + range.length <= self.length) {
        return [self hookSubstringWithRange:range];
    }else if (range.location < self.length){
        return [self hookSubstringWithRange:NSMakeRange(range.location, self.length-range.location)];
    }
    return nil;
}
- (NSRange)hookRangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)range locale:(nullable NSLocale *)locale
{
    if (searchString){
        if (range.location + range.length <= self.length) {
            return [self hookRangeOfString:searchString options:mask range:range locale:locale];
        }else if (range.location < self.length){
            return [self hookRangeOfString:searchString options:mask range:NSMakeRange(range.location, self.length-range.location) locale:locale];
        }
        return NSMakeRange(NSNotFound, 0);
    }else{
        return NSMakeRange(NSNotFound, 0);
    }
}

@end
