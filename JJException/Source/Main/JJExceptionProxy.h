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
__attribute__((overloadable)) void handleCrashException(NSString* exceptionMessage);

/**
 C style invoke handle crash message,and extra crash info

 @param exceptionMessage crash message
 @param extraInfo extra crash message
 */
__attribute__((overloadable)) void handleCrashException(NSString* exceptionMessage,NSDictionary* extraInfo);

/**
 C style invoke handle crash message,and extra crash info
 
 @param exceptionCategory crash type
 @param exceptionMessage crash message
 @param extraInfo extra info
 */
__attribute__((overloadable)) void handleCrashException(JJExceptionGuardCategory exceptionCategory, NSString* exceptionMessage,NSDictionary* extraInfo);

/**
 C style invoke handle crash type,and exception message
 
 @param exceptionCategory JJExceptionGuardCategory
 @param exceptionMessage crash message
 */
__attribute__((overloadable)) void handleCrashException(JJExceptionGuardCategory exceptionCategory, NSString* exceptionMessage);

/**
 Exception Proxy
 */
@interface JJExceptionProxy : NSObject<JJExceptionHandle>


+ (instancetype)shareExceptionProxy;


#pragma mark - Handle crash interface

/**
 Hold the JJExceptionHandle interface object
 */
@property(nonatomic,readwrite,weak)id<JJExceptionHandle> delegate;

/**
 Setting hook excpetion status,default value is NO
 */
@property(nonatomic,readwrite,assign)BOOL isProtectException;

/**
 If exceptionWhenTerminate YES,the exception will stop application
 If exceptionWhenTerminate NO,the exception only show log on the console, will not stop the application
 Default value:NO
 */
@property(nonatomic,readwrite,assign)BOOL exceptionWhenTerminate;

/**
 Setting exceptionGuardCategory
 @see JJExceptionGuardCategory
 */
@property(nonatomic,readwrite,assign)JJExceptionGuardCategory exceptionGuardCategory;

#pragma mark - Zombie collection

/**
 Real addZombieObjectArray invoke

 @param objects class array
 */
- (void)addZombieObjectArray:(NSArray*)objects;

/**
 Zombie only process the Set class
 */
@property(nonatomic,readonly,strong)NSSet* blackClassesSet;

/**
 Record the all Set class size
 */
@property(nonatomic,readonly,assign)NSInteger currentClassSize;

/**
 Add object to the currentClassesSet
 
 @param object NSObject
 */
- (void)addCurrentZombieClass:(Class)object;

/**
 Remove object from the currentClassesSet

 @param object NSObject
 */
- (void)removeCurrentZombieClass:(Class)object;

/**
 Record the objc_destructInstance instance object
 */
@property(nonatomic,readonly,strong)NSSet* currentClassesSet;

/**
 Random get the object from blackClassesSet

 @return NSObject
 */
- (nullable id)objectFromCurrentClassesSet;

@end

NS_ASSUME_NONNULL_END
