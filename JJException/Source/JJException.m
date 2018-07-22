//
//  JJException.m
//  JJException
//
//  Created by Jezz on 2018/7/21.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "JJException.h"
#import "JJExceptionProxy.h"

@implementation JJException

+ (void)registerExceptionHandle:(id<JJExceptionHandle>)exceptionHandle{
    [JJExceptionProxy shareExceptionProxy].delegate = exceptionHandle;
}

@end
