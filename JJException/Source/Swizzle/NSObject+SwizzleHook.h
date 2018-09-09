//
//  NSObject+SwizzleHook.h
//  JJException
//
//  Created by Jezz on 2018/7/10.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

void swizzleClassMethod(Class cls, SEL originSelector, SEL swizzleSelector);

void swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector);

@interface NSObject (SwizzleHook)

+ (void)jj_swizzleClassMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector;

- (void)jj_swizzleInstanceMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector;

@end
