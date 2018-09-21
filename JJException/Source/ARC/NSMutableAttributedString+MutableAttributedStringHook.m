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

@implementation NSMutableAttributedString (MutableAttributedStringHook)

+ (void)jj_swizzleNSMutableAttributedString{
    NSMutableAttributedString* instanceObject = [NSMutableAttributedString new];
    Class cls =  object_getClass(instanceObject);
    
    swizzleInstanceMethod(cls,@selector(initWithString:), @selector(hookInitWithString:));
    swizzleInstanceMethod(cls,@selector(initWithString:attributes:), @selector(hookInitWithString:attributes:));
    swizzleInstanceMethod(cls,@selector(addAttribute:value:range:), @selector(hookAddAttribute:value:range:));
    swizzleInstanceMethod(cls,@selector(addAttributes:range:), @selector(hookAddAttributes:range:));
    swizzleInstanceMethod(cls,@selector(setAttributes:range:), @selector(hookSetAttributes:range:));
}

- (id)hookInitWithString:(NSString*)str{
    if (str){
        return [self hookInitWithString:str];
    }
    return nil;
}

- (id)hookInitWithString:(NSString*)str attributes:(nullable NSDictionary*)attributes{
    if (str){
        return [self hookInitWithString:str attributes:attributes];
    }
    return nil;
}

- (void)hookAddAttribute:(id)name value:(id)value range:(NSRange)range{
    if (!range.length) {
        [self hookAddAttribute:name value:value range:range];
    }else if (value){
        if (range.location + range.length <= self.length) {
            [self hookAddAttribute:name value:value range:range];
        }else if (range.location < self.length){
            [self hookAddAttribute:name value:value range:NSMakeRange(range.location, self.length-range.location)];
        }
    }else {
        
    }
}
- (void)hookAddAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range{
    if (!range.length) {
        [self hookAddAttributes:attrs range:range];
    }else if (attrs){
        if (range.location + range.length <= self.length) {
            [self hookAddAttributes:attrs range:range];
        }else if (range.location < self.length){
            [self hookAddAttributes:attrs range:NSMakeRange(range.location, self.length-range.location)];
        }
    }else{
        
    }
}

- (void)hookSetAttributes:(NSDictionary<NSString *,id> *)attrs range:(NSRange)range{
    if (!range.length) {
        [self hookSetAttributes:attrs range:range];
    }else if (attrs){
        if (range.location + range.length <= self.length) {
            [self hookSetAttributes:attrs range:range];
        }else if (range.location < self.length){
            [self hookSetAttributes:attrs range:NSMakeRange(range.location, self.length-range.location)];
        }
    }else{
        
    }
    
}

@end
