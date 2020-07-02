//
//  KVOObjectItem.h
//  JJException
//
//  Created by 张猫猫 on 2020/7/2.
//  Copyright © 2020 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

//NS_ASSUME_NONNULL_BEGIN

/**
 Record the kvo object
 Override the isEqual and hash method
 */
@interface KVOObjectItem : NSObject

/** 观察者 (如果是weak，当observer被dealloc时做清理操作，读取item的observer，此时item的被weak修饰的observer属性已经被置nil了) */
@property(nonatomic,readwrite,assign)NSObject* observer;
/** 被观察者 */
@property(nonatomic,readwrite,assign)NSObject* whichObject;

@property(nonatomic,readwrite,copy)NSString* keyPath;
@property(nonatomic,readwrite,assign)NSKeyValueObservingOptions options;
@property(nonatomic,readwrite,assign)void* context;

@end

//NS_ASSUME_NONNULL_END
