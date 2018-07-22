//
//  ViewController.m
//  JJException
//
//  Created by Jezz on 2018/7/8.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "ViewController.h"
#import "JJException.h"

@interface ViewController ()<JJExceptionHandle>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [JJException registerExceptionHandle:self];
}

- (void)handleCrashException:(NSString *)exceptionMessage{
    NSLog(@"%@",exceptionMessage);
}

@end
