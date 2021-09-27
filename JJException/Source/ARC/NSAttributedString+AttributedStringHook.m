//
//  NSAttributedString+AttributedStringHook.m
//  JJException
//
//  Created by Jezz on 2018/9/20.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSAttributedString+AttributedStringHook.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import "JJExceptionProxy.h"
#import "JJExceptionMacros.h"

JJSYNTH_DUMMY_CLASS(NSAttributedString_AttributedStringHook)

@implementation NSAttributedString (AttributedStringHook)

+ (void)jj_swizzleNSAttributedString{
    NSAttributedString* instanceObject = [NSAttributedString new];
    Class cls =  object_getClass(instanceObject);
    
    swizzleInstanceMethod(cls, @selector(initWithString:), @selector(hookInitWithString:));
    swizzleInstanceMethod(cls, @selector(attributedSubstringFromRange:), @selector(hookAttributedSubstringFromRange:));
    swizzleInstanceMethod(cls, @selector(attribute:atIndex:effectiveRange:), @selector(hookAttribute:atIndex:effectiveRange:));
    swizzleInstanceMethod(cls, @selector(enumerateAttribute:inRange:options:usingBlock:), @selector(hookEnumerateAttribute:inRange:options:usingBlock:));
    swizzleInstanceMethod(cls, @selector(enumerateAttributesInRange:options:usingBlock:), @selector(hookEnumerateAttributesInRange:options:usingBlock:));
}

- (id)hookInitWithString:(NSString*)str{
    if (str){
        return [self hookInitWithString:str];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,@"NSAttributedString initWithString parameter nil");
    return nil;
}

- (id)hookAttribute:(NSAttributedStringKey)attrName atIndex:(NSUInteger)location effectiveRange:(nullable NSRangePointer)range{
    if (location < self.length){
        return [self hookAttribute:attrName atIndex:location effectiveRange:range];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSAttributedString attribute:atIndex:effectiveRange: attrName:%@ location:%tu",attrName,location]);
    return nil;
}

- (NSAttributedString *)hookAttributedSubstringFromRange:(NSRange)range{
    if (range.location + range.length <= self.length) {
        return [self hookAttributedSubstringFromRange:range];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSAttributedString attributedSubstringFromRange range:%@",NSStringFromRange(range)]);
    return nil;
}

- (void)hookEnumerateAttribute:(NSString *)attrName inRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id _Nullable, NSRange, BOOL * _Nonnull))block{
    if (range.location + range.length <= self.length) {
        [self hookEnumerateAttribute:attrName inRange:range options:opts usingBlock:block];
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSAttributedString enumerateAttribute attrName:%@ range:%@",attrName,NSStringFromRange(range)]);
    }
}

- (void)hookEnumerateAttributesInRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary<NSString*,id> * _Nonnull, NSRange, BOOL * _Nonnull))block{
    
    if (range.location == NSNotFound && range.length == 0) {
        [self hookEnumerateAttributesInRange:range options:opts usingBlock:block];
        return;
    }
    if (range.location + range.length <= self.length && range.location != NSNotFound) {
        [self hookEnumerateAttributesInRange:range options:opts usingBlock:block];
    } else {
        handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSAttributedString enumerateAttributesInRange range:%@",NSStringFromRange(range)]);
    }
}

@end
