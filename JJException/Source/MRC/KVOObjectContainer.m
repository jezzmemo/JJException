//
//  KVOObjectContainer.m
//  JJException
//
//  Created by 张猫猫 on 2020/7/2.
//  Copyright © 2020 Jezz. All rights reserved.
//

#import "KVOObjectContainer.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation KVOObjectContainer

- (void)cleanKVOData {
    for (KVOObjectItem* item in self.kvoObjectSet) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        
        NSObject *obj = item.observer;
        if (obj == self) {
            obj = item.whichObject;
        }
        if (obj) {
            KVOObjectContainer* objectContainer = objc_getAssociatedObject(obj, &DeallocKVOKey);
            if (objectContainer) { // 清理和自己相关的观察关系
                NSLog(@"1🌲1");
                [objectContainer.kvoObjectSet removeObject:item];
            }
        }
        
        if (item.observer) {
            @try {
                ((void(*)(id,SEL,id,NSString*))objc_msgSend)(item.whichObject,@selector(hookRemoveObserver:forKeyPath:),item.observer,item.keyPath);
            }@catch (NSException *exception) {
            }
            
            item.observer = nil;
            item.whichObject = nil;
            item.keyPath = nil;
        }
        #pragma clang diagnostic pop
    }
    [self.kvoObjectSet removeAllObjects];
}

- (NSMutableSet*)kvoObjectSet {
    if(!_kvoObjectSet){
        _kvoObjectSet = [[NSMutableSet alloc] init];
    }
    return _kvoObjectSet;
}

/**
 Clean the kvo object array and temp var
 release the dispatch_semaphore
 */
- (void)dealloc {
    [self.kvoObjectSet release];
    [super dealloc];
//    NSLog(@"🔥");
}

@end
