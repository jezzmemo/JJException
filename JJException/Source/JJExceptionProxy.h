//
//  JJExceptionProxy.h
//  JJException
//
//  Created by Jezz on 2018/7/22.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JJException.h"

NS_ASSUME_NONNULL_BEGIN

/**
 C style invoke handle crash message

 @param exceptionMessage crash message
 */
void handleCrashException(NSString* exceptionMessage);

/**
 Exception Proxy
 */
@interface JJExceptionProxy : NSObject<JJExceptionHandle>


+ (instancetype)shareExceptionProxy;


#pragma mark - Handle crash interface

/**
 Hold the JJExceptionHandle interface object
 */
@property(nonatomic,readwrite,strong)id<JJExceptionHandle> delegate;

#pragma mark - Zombie collection

/**
 Real addZombieObjectArray invoke

 @param objects class array
 */
- (void)addZombieObjectArray:(NSArray*)objects;

/**
 Zombie only process the Set class
 */
@property(nonatomic,readwrite,strong)NSMutableSet* blackClassesSet;

/**
 Record the all Set class size
 */
@property(nonatomic,readwrite,assign)NSInteger currentClassSize;

/**
 Record the objc_destructInstance instance object
 */
@property(nonatomic,readwrite,strong)NSMutableSet* currentClassesSet;

/**
 Random get the object from blackClassesSet

 @return NSObject
 */
- (id)objectFromCurrentClassesSet;

@end

NS_ASSUME_NONNULL_END
