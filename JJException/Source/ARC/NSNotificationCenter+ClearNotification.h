//
//  NSNotificationCenter+ClearNotification.h
//  JJException
//
//  Created by Jezz on 2018/9/6.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Copy the NSNotification Info
 */
@interface JJNotificationObject : NSObject

@property (nonatomic,readwrite,copy) NSString* name;

@property(nonatomic,readwrite,weak)id observer;

@property(nonatomic,readwrite,assign)id object;

/**
 get key from observer

 @param observer NSNotification observer
 @return the key of observer info in static NSMutableDictionary
 */
+ (NSString *)jj_observerInfoKey:(id)observer;

/**
 set observer info to static NSMutableDictionary

 @param observer NSNotification observer
 @param name NSNotificationName
 @param anObject NSNotification object
 */
+ (void)jj_setNotificationObserverInfo:(id)observer name:(NSNotificationName)name object:(id)anObject;

/**
 get observer infos array form static NSMutableDictionary

 @param observer NSNotification observer
 @return array
 */
+ (NSMutableArray <JJNotificationObject *>* )jj_notificationObserverInfos:(id)observer;

/**
 remove observer infos from static NSMutableDictionary

 @param observer NSNotification observer
 */
+ (void)jj_removeNotificationObserverInfo:(id)observer;

@end

@interface NSNotificationCenter (ClearNotification)

+ (void)jj_swizzleNSNotificationCenter;

@end
