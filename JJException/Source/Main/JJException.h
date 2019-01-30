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
 Before start JJException,must config the JJExceptionGuardCategory
 
 - JJExceptionGuardNone: Do not guard normal crash exception
 - JJExceptionGuardUnrecognizedSelector: Unrecognized Selector Exception
 - JJExceptionGuardDictionaryContainer: NSDictionary,NSMutableDictionary
 - JJExceptionGuardArrayContainer: NSArray,NSMutableArray
 - JJExceptionGuardZombie: Zombie
 - JJExceptionGuardKVOCrash: KVO exception
 - JJExceptionGuardNSTimer: NSTimer
 - JJExceptionGuardNSNotificationCenter: NSNotificationCenter
 - JJExceptionGuardNSStringContainer:NSString,NSMutableString,NSAttributedString,NSMutableAttributedString
 - JJExceptionGuardAllExceptZombie:Above All except Zombie
 - JJExceptionGuardAll: Above All
 */
typedef NS_OPTIONS(NSInteger,JJExceptionGuardCategory){
    JJExceptionGuardNone = 0,
    JJExceptionGuardUnrecognizedSelector = 1 << 1,
    JJExceptionGuardDictionaryContainer = 1 << 2,
    JJExceptionGuardArrayContainer = 1 << 3,
    JJExceptionGuardZombie = 1 << 4,
    JJExceptionGuardKVOCrash = 1 << 5,
    JJExceptionGuardNSTimer = 1 << 6,
    JJExceptionGuardNSNotificationCenter = 1 << 7,
    JJExceptionGuardNSStringContainer = 1 << 8,
    JJExceptionGuardKVCCrash = 1 << 9,
    JJExceptionGuardAllExceptZombie = JJExceptionGuardUnrecognizedSelector | JJExceptionGuardDictionaryContainer | JJExceptionGuardArrayContainer | JJExceptionGuardKVOCrash | JJExceptionGuardNSTimer | JJExceptionGuardNSNotificationCenter | JJExceptionGuardNSStringContainer,
    JJExceptionGuardAll = JJExceptionGuardUnrecognizedSelector | JJExceptionGuardDictionaryContainer | JJExceptionGuardArrayContainer | JJExceptionGuardZombie | JJExceptionGuardKVOCrash | JJExceptionGuardNSTimer | JJExceptionGuardNSNotificationCenter | JJExceptionGuardNSStringContainer | JJExceptionGuardKVCCrash,
};

/**
 Exception interface
 */
@protocol JJExceptionHandle<NSObject>

/**
 Crash message and extra info from current thread
 
 @param exceptionMessage crash message
 @param info extraInfo,key and value
 */
- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(nullable NSDictionary*)info;

@optional

/**
 Crash message,exceptionCategory, extra info from current thread
 
 @param exceptionMessage crash message
 @param exceptionCategory JJExceptionGuardCategory
 @param info extra info
 */
- (void)handleCrashException:(NSString*)exceptionMessage exceptionCategory:(JJExceptionGuardCategory)exceptionCategory extraInfo:(nullable NSDictionary*)info;

@end

/**
 Exception main
 */
@interface JJException : NSObject


/**
 If exceptionWhenTerminate YES,the exception will stop application
 If exceptionWhenTerminate NO,the exception only show log on the console, will not stop the application
 Default value:NO
 */
@property(class,nonatomic,readwrite,assign)BOOL exceptionWhenTerminate;

/**
 Config the guard exception category,default:JJExceptionGuardNone
 
 @param exceptionGuardCategory JJExceptionGuardCategory
 */
+ (void)configExceptionCategory:(JJExceptionGuardCategory)exceptionGuardCategory;

/**
 Start the exception protect
 */
+ (void)startGuardException;

/**
 Stop the exception protect
 */
+ (void)stopGuardException;

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
