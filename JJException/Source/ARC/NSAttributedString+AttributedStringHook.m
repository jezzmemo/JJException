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

- (id)hookInitWithString:(NSString*)str {
    if (str){
        return [self hookInitWithString:str];
    }
    return nil;
}

- (id)hookAttribute:(NSAttributedStringKey)attrName atIndex:(NSUInteger)location effectiveRange:(nullable NSRangePointer)range{
    if (location < self.length){
        return [self hookAttribute:attrName atIndex:location effectiveRange:range];
    }else{
        return nil;
    }
}

- (NSAttributedString *)hookAttributedSubstringFromRange:(NSRange)range{
    if (range.location + range.length <= self.length) {
        return [self hookAttributedSubstringFromRange:range];
    }else if (range.location < self.length){
        return [self hookAttributedSubstringFromRange:NSMakeRange(range.location, self.length-range.location)];
    }
    return nil;
}

- (void)hookEnumerateAttribute:(NSString *)attrName inRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(id _Nullable, NSRange, BOOL * _Nonnull))block{
    if (range.location + range.length <= self.length) {
        [self hookEnumerateAttribute:attrName inRange:range options:opts usingBlock:block];
    }else if (range.location < self.length){
        [self hookEnumerateAttribute:attrName inRange:NSMakeRange(range.location, self.length-range.location) options:opts usingBlock:block];
    }
}

- (void)hookEnumerateAttributesInRange:(NSRange)range options:(NSAttributedStringEnumerationOptions)opts usingBlock:(void (^)(NSDictionary<NSString*,id> * _Nonnull, NSRange, BOOL * _Nonnull))block{
    if (range.location + range.length <= self.length) {
        [self hookEnumerateAttributesInRange:range options:opts usingBlock:block];
    }else if (range.location < self.length){
        [self hookEnumerateAttributesInRange:NSMakeRange(range.location, self.length-range.location) options:opts usingBlock:block];
    }
}

@end
