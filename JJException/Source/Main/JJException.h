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
 - JJExceptionGuardKVOCrash: KVO exception
 - JJExceptionGuardNSTimer: NSTimer
 - JJExceptionGuardNSNotificationCenter: NSNotificationCenter
 - JJExceptionGuardNSStringContainer:NSString,NSMutableString,NSAttributedString,NSMutableAttributedString
 - JJExceptionGuardAll: Above All
 */
typedef NS_OPTIONS(NSInteger,JJExceptionGuardCategory){
    JJExceptionGuardNone = 0,
    JJExceptionGuardUnrecognizedSelector = 1 << 1,
    JJExceptionGuardDictionaryContainer = 1 << 2,
    JJExceptionGuardArrayContainer = 1 << 3,
    JJExceptionGuardKVOCrash = 1 << 4,
    JJExceptionGuardNSTimer = 1 << 5,
    JJExceptionGuardNSNotificationCenter = 1 << 6,
    JJExceptionGuardNSStringContainer = 1 << 7,
    JJExceptionGuardAll = JJExceptionGuardUnrecognizedSelector | JJExceptionGuardDictionaryContainer | JJExceptionGuardArrayContainer | JJExceptionGuardKVOCrash | JJExceptionGuardNSTimer | JJExceptionGuardNSNotificationCenter | JJExceptionGuardNSStringContainer,
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
 JJException guard exception status,default is NO
 */
@property(class,nonatomic,readonly,assign)BOOL isGuardException;

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
 
 * Why deprecated this method:
 * https://github.com/jezzmemo/JJException/issues/54
 */
+ (void)stopGuardException __attribute__((deprecated("Stop invoke this method,If invoke this,Maybe occur the infinite loop and then CRASH")));

/**
 Register exception interface

 @param exceptionHandle JJExceptionHandle
 */
+ (void)registerExceptionHandle:(id<JJExceptionHandle>)exceptionHandle;

@end

NS_ASSUME_NONNULL_END
