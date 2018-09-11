//
//  NSMutableArray+MutableArrayHook.h
//  JJException
//
//  Created by Jezz on 2018/7/15.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MutableArrayHook)

+ (void)jj_swizzleNSMutableArray;

@end
