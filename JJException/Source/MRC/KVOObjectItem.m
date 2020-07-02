//
//  KVOObjectItem.m
//  JJException
//
//  Created by 张猫猫 on 2020/7/2.
//  Copyright © 2020 Jezz. All rights reserved.
//

#import "KVOObjectItem.h"

@implementation KVOObjectItem

- (BOOL)isEqual:(KVOObjectItem*)object{
    // 防止可能已释放
    if (!self.observer || !self.whichObject || !self.keyPath
        || !object.observer || !object.whichObject || !object.keyPath) {
        return NO;
    }
    if ([self.observer isEqual:object.observer] && [self.whichObject isEqual:object.whichObject] && [self.keyPath isEqualToString:object.keyPath]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash{
    return [self.observer hash] ^ [self.whichObject hash] ^ [self.keyPath hash];
}

- (void)dealloc{
    self.context = nil;
    [super dealloc];
}

@end
