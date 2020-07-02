//
//  KVOObjectContainer.h
//  JJException
//
//  Created by 张猫猫 on 2020/7/2.
//  Copyright © 2020 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVOObjectItem.h"

static const char DeallocKVOKey = 'S';

NS_ASSUME_NONNULL_BEGIN

@interface KVOObjectContainer : NSObject

/**
 KVO object array set
 */
@property(nonatomic,readwrite,retain)NSMutableSet* kvoObjectSet;

- (void)cleanKVOData;
@end

NS_ASSUME_NONNULL_END
