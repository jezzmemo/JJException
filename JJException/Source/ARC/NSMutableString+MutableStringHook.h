//
//  NSMutableString+MutableStringHook.h
//  JJException
//
//  Created by Jezz on 2018/9/18.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (MutableStringHook)

+ (void)jj_swizzleNSMutableString;

@end
