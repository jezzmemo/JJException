//
//  ViewController.m
//  JJException
//
//  Created by Jezz on 2018/7/8.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "ViewController.h"
#import "JJException.h"
#import <objc/runtime.h>
#import "PushViewController.h"

@interface ViewController ()<JJExceptionHandle>

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
    
    [JJException registerExceptionHandle:self];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"Push controller" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, self.view.frame.size.width, 50);
    button.center = self.view.center;
    [button addTarget:self action:@selector(pushAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
#pragma mark - Delegate

- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{
    
}

#pragma mark - Action

- (void)pushAction{
    PushViewController* push = [[PushViewController alloc] init];
    [self presentViewController:push animated:YES completion:nil];
}


@end
