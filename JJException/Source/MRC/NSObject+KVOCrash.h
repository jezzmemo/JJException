//
//  NSObject+KVOCrash.h
//  JJException
//
//  Created by Jezz on 2018/8/29.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class KVOObjectItem;

@interface NSObject (KVOCrash)

+ (void)jj_swizzleKVOCrash;

- (BOOL)removeItemWithObject:(NSObject *)object observer:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
