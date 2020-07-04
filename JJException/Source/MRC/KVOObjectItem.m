//
//  KVOObjectItem.m
//  JJException
//
//  Created by 张猫猫 on 2020/7/2.
//  Copyright © 2020 Jezz. All rights reserved.
//

#import "KVOObjectItem.h"

@implementation KVOObjectItem

- (BOOL)isEqual:(KVOObjectItem *)object {
    return self.hash == object.hash;
}

- (NSUInteger)hash {
    return [self.observer hash] ^ [self.whichObject hash] ^ [self.keyPath hash];
}
@end
