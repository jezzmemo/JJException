//
//  JJException.h
//  JJException
//
//  Created by Jezz on 2018/7/21.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JJExceptionHandle<NSObject>

- (void)handleCrashException:(NSString*)exceptionMessage;

@end

@interface JJException : NSObject

+ (void)registerExceptionHandle:(id<JJExceptionHandle>)exceptionHandle;

@end

NS_ASSUME_NONNULL_END
