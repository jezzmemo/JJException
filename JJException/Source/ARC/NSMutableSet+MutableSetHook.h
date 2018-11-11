//
//  NSMutableSet+MutableSetHook.h
//  JJException
//
//  Created by Jezz on 2018/11/11.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableSet (MutableSetHook)

+ (void)jj_swizzleNSMutableSet;

@end

NS_ASSUME_NONNULL_END
