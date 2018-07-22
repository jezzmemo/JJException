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

void handleCrashException(NSString* exceptionMessage);

@interface JJExceptionProxy : NSObject<JJExceptionHandle>

+(instancetype)shareExceptionProxy;

@property(nonatomic,readwrite,strong)id<JJExceptionHandle> delegate;

@end

NS_ASSUME_NONNULL_END
