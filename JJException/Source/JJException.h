//
//  JJException.h
//  JJException
//
//  Created by Jezz on 2018/7/21.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Exception interface
 */
@protocol JJExceptionHandle<NSObject>

/**
 Crash message and extra info

 @param exceptionMessage crash message
 @param info extraInfo,key and value
 */
- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(nullable NSDictionary*)info;

@end

/**
 Exception main
 */
@interface JJException : NSObject

/**
 Register exception interface

 @param exceptionHandle JJExceptionHandle
 */
+ (void)registerExceptionHandle:(id<JJExceptionHandle>)exceptionHandle;

/**
 Only handle the black list zombie object
 
 Sample Code:
 
    [JJException addZombieObjectArray:@[TestZombie.class]];

 @param objects Class Array
 */
+ (void)addZombieObjectArray:(NSArray*)objects;

@end

NS_ASSUME_NONNULL_END
