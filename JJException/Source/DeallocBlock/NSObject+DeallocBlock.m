//
//  NSObject+DeallocBlock.m
//  JJException
//
//  Created by Jezz on 2018/9/15.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSObject+DeallocBlock.h"
#import <objc/runtime.h>

static const char DeallocNSObjectKey;

/**
 Observer the target middle object
 */
@interface DeallocStub : NSObject

@property (nonatomic,readwrite,copy) void(^deallocBlock)(void);

@end

@implementation DeallocStub

- (void)dealloc {
    if (self.deallocBlock) {
        self.deallocBlock();
    }
    self.deallocBlock = nil;
}

@end

@implementation NSObject (DeallocBlock)

- (void)jj_deallocBlock:(void(^)(void))block{
    @synchronized(self){
        NSMutableArray* blockArray = objc_getAssociatedObject(self, &DeallocNSObjectKey);
        if (!blockArray) {
            blockArray = [NSMutableArray array];
            objc_setAssociatedObject(self, &DeallocNSObjectKey, blockArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        DeallocStub *stub = [DeallocStub new];
        stub.deallocBlock = block;
        
        [blockArray addObject:stub];
    }
}

@end
