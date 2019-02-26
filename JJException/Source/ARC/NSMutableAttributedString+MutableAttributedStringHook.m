//
//  NSMutableAttributedString+MutableAttributedStringHook.m
//  JJException
//
//  Created by Jezz on 2018/9/20.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSMutableAttributedString+MutableAttributedStringHook.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import "JJExceptionProxy.h"
#import "JJExceptionMacros.h"

JJSYNTH_DUMMY_CLASS(NSMutableAttributedString_MutableAttributedStringHook)

@implementation NSMutableAttributedString (MutableAttributedStringHook)

+ (void)jj_swizzleNSMutableAttributedString{
    NSMutableAttributedString* instanceObject = [NSMutableAttributedString new];
    Class cls =  object_getClass(instanceObject);
    
    swizzleInstanceMethod(cls,@selector(initWithString:), @selector(hookInitWithString:));
    swizzleInstanceMethod(cls,@selector(initWithString:attributes:), @selector(hookInitWithString:attributes:));
    swizzleInstanceMethod(cls,@selector(addAttribute:value:range:), @selector(hookAddAttribute:value:range:));
    swizzleInstanceMethod(cls,@selector(addAttributes:range:), @selector(hookAddAttributes:range:));
    swizzleInstanceMethod(cls,@selector(setAttributes:range:), @selector(hookSetAttributes:range:));
    swizzleInstanceMethod(cls,@selector(removeAttribute:range:), @selector(hookRemoveAttribute:range:));
    swizzleInstanceMethod(cls,@selector(deleteCharactersInRange:), @selector(hookDeleteCharactersInRange:));
    swizzleInstanceMethod(cls,@selector(replaceCharactersInRange:withString:), @selector(hookReplaceCharactersInRange:withString:));
    swizzleInstanceMethod(cls,@selector(replaceCharactersInRange:withAttributedString:), @selector(hookReplaceCharactersInRange:withAttributedString:));
}

- (id)hookInitWithString:(NSString*)str{
    if (str){
        return [self hookInitWithString:str];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,@"NSMutableAttributedString initWithString parameter nil");
    return nil;
}

- (id)hookInitWithString:(NSString*)str attributes:(nullable NSDictionary*)attributes{
    if (str){
        return [self hookInitWithString:str attributes:attributes];
    }
    handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString initWithString:attributes: str:%@ attributes:%@",str,attributes]);
    return nil;
}

- (void)hookAddAttribute:(id)name value:(id)value range:(NSRange)range{
    if (!range.length) {
        [self hookAddAttribute:name value:value range:range];
    }else if (value){
        if (range.location + range.length <= self.length) {
            [self hookAddAttribute:name value:value range:range];
        }else{
            handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString addAttribute:value:range: name:%@ value:%@ range:%@",name,value,NSStringFromRange(range)]);
        }
    }else {
        handleCrashException(JJExceptionGuardNSStringContainer,@"NSMutableAttributedString addAttribute:value:range: value nil");
    }
}
- (void)hookAddAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range{
    if (!range.length) {
        [self hookAddAttributes:attrs range:range];
    }else if (attrs){
        if (range.location + range.length <= self.length) {
            [self hookAddAttributes:attrs range:range];
        }else{
            handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString addAttributes:range: attrs:%@ range:%@",attrs,NSStringFromRange(range)]);
        }
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,@"NSMutableAttributedString addAttributes:range: value nil");
    }
}

- (void)hookSetAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range{
    if (!range.length) {
        [self hookSetAttributes:attrs range:range];
    }else if (attrs){
        if (range.location + range.length <= self.length) {
            [self hookSetAttributes:attrs range:range];
        }else{
            handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString setAttributes:range: attrs:%@ range:%@",attrs,NSStringFromRange(range)]);
        }
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,@"NSMutableAttributedString setAttributes:range: attrs nil");
    }
}

- (void)hookRemoveAttribute:(id)name range:(NSRange)range {
    if (!range.length) {
        [self hookRemoveAttribute:name range:range];
    }else if (name){
        if (range.location + range.length <= self.length) {
            [self hookRemoveAttribute:name range:range];
        }else {
            handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString removeAttribute:range: name:%@ range:%@",name,NSStringFromRange(range)]);
        }
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,@"NSMutableAttributedString removeAttribute:range: attrs nil");
    }
}

- (void)hookDeleteCharactersInRange:(NSRange)range {
    if (range.location + range.length <= self.length) {
        [self hookDeleteCharactersInRange:range];
    }else {
        handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString deleteCharactersInRange: range:%@",NSStringFromRange(range)]);
    }
}
- (void)hookReplaceCharactersInRange:(NSRange)range withString:(NSString *)str {
    if (str){
        if (range.location + range.length <= self.length) {
            [self hookReplaceCharactersInRange:range withString:str];
        }else{
            handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString replaceCharactersInRange:withString string:%@ range:%@",str,NSStringFromRange(range)]);
        }
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,@"NSMutableAttributedString replaceCharactersInRange:withString: string nil");
    }
}
- (void)hookReplaceCharactersInRange:(NSRange)range withAttributedString:(NSAttributedString *)str {
    if (str){
        if (range.location + range.length <= self.length) {
            [self hookReplaceCharactersInRange:range withAttributedString:str];
        }else{
          handleCrashException(JJExceptionGuardNSStringContainer,[NSString stringWithFormat:@"NSMutableAttributedString replaceCharactersInRange:withString string:%@ range:%@",str,NSStringFromRange(range)]);
        }
    }else{
        handleCrashException(JJExceptionGuardNSStringContainer,@"NSMutableAttributedString replaceCharactersInRange:withString: attributedString nil");
    }
}

@end
