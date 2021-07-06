//
//  NSJSONSerialization+JSONSerializationHook.h
//  JJException
//
//  Created by mac on 2021/7/5.
//  Copyright © 2021 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSJSONSerialization (JSONSerializationHook)

+ (void)jj_swizzleNSJSONSerialization;

@end

NS_ASSUME_NONNULL_END
