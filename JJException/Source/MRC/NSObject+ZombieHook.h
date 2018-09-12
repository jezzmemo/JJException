//
//  NSObject+Zombie.h
//  JJException
//
//  Created by Jezz on 2018/7/26.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZombieHook)

+ (void)jj_swizzleZombie;

@end
