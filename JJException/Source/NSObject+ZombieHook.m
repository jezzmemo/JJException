//
//  NSObject+Zombie.m
//  JJException
//
//  Created by Jezz on 2018/7/26.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSObject+ZombieHook.h"
#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import "JJExceptionProxy.h"

const NSInteger MAX_ARRAY_SIZE = 1024 * 1024 * 5;// MAX Memeory Size 5M

@interface ZombieSelectorHandle : NSObject

@property(nonatomic,readwrite,weak)id fromObject;

@end


@implementation ZombieSelectorHandle

void unrecognizedSelectorZombie(ZombieSelectorHandle* self, SEL _cmd){
    
}

@end

@interface JJZombieSub : NSObject

@end

@implementation JJZombieSub

- (id)forwardingTargetForSelectorSwizzled:(SEL)selector{
    NSMethodSignature* sign = [self methodSignatureForSelector:selector];
    if (!sign) {
        id stub = [[ZombieSelectorHandle new] autorelease];
        [stub setFromObject:self];
        class_addMethod([stub class], selector, (IMP)unrecognizedSelectorZombie, "v@:");
        return stub;
    }
    return [self forwardingTargetForSelectorSwizzled:selector];
}

@end

@implementation NSObject (ZombieHook)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self jj_swizzleInstanceMethod:@selector(dealloc) withSwizzleMethod:@selector(hookDealloc)];
    });
}

- (void)hookDealloc{
    Class currentClass = self.class;
    
    //Check black list
    if (![[[JJExceptionProxy shareExceptionProxy] blackClassesSet] containsObject:currentClass]) {
        [self hookDealloc];
        return;
    }
    
    //Check the array max size
    //TODO:Real remove less than MAX_ARRAY_SIZE
    if ([JJExceptionProxy shareExceptionProxy].currentClassSize > MAX_ARRAY_SIZE) {
        id object = [[JJExceptionProxy shareExceptionProxy] objectFromCurrentClassesSet];
        [[JJExceptionProxy shareExceptionProxy].currentClassesSet removeObject:object];
        object?free(object):nil;
    }
    
    objc_destructInstance(self);
    object_setClass(self, [JJZombieSub class]);
    [[JJExceptionProxy shareExceptionProxy].currentClassesSet addObject:self];
    [[JJExceptionProxy shareExceptionProxy] setCurrentClassSize:[JJExceptionProxy shareExceptionProxy].currentClassSize + class_getInstanceSize(self.class)];
}

@end
