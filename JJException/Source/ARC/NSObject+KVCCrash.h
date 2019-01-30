//
//  NSObject+KVCCrash.h
//  JJException
//
//  Created by 无头骑士 GJ on 2019/1/30.
//  Copyright © 2019 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVCCrash)
+ (void)jj_swizzleKVCCrash;
@end

NS_ASSUME_NONNULL_END
