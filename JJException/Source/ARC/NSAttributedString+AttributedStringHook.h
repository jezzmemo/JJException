//
//  NSAttributedString+AttributedStringHook.h
//  JJException
//
//  Created by Jezz on 2018/9/20.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (AttributedStringHook)

+ (void)jj_swizzleNSAttributedString;

@end
