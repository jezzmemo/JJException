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
    UIButton* startGuardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [startGuardButton setTitle:@"Start Guard" forState:UIControlStateNormal];
    [startGuardButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    startGuardButton.frame = CGRectMake((self.view.frame.size.width - 100)/2, 250, 100, 50);
    [startGuardButton addTarget:self action:@selector(startGuardAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startGuardButton];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Test KVO|NotificatinCenter|NSTimer" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 300, self.view.frame.size.width, 50);
    [button addTarget:self action:@selector(testKVONotificatinCenterNSTimerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton* otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [otherButton setTitle:@"Test NSArray|NSDictionary|UnrecognizedSelector|NSNull" forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    otherButton.frame = CGRectMake(0, 350, self.view.frame.size.width, 50);
    [otherButton addTarget:self action:@selector(testArrayDictionaryUnrecognizedSelector) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:otherButton];
}
#pragma mark - Exception Delegate

- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{

}

#pragma mark - Action

- (void)startGuardAction{
    JJException.exceptionWhenTerminate = NO;
    
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
    
    [JJException registerExceptionHandle:self];
}

#pragma mark - Test Action

- (void)testKVONotificatinCenterNSTimerAction{
    PushViewController* push = [[PushViewController alloc] init];
    [self presentViewController:push animated:YES completion:nil];
}

- (void)testArrayDictionaryUnrecognizedSelector{
    [self testSampleArray];
    [self testSimpleDictionary];
    [self testUnrecognizedSelector];
    [self testNull];
}

- (void)testSampleArray{
    NSArray* test = @[];
    NSLog(@"object:%@",test[1]);
}

- (void)testSimpleDictionary{
    id value = nil;
    NSDictionary* dic = @{@"key":value};
    NSLog(@"dic:%@",dic);
}

- (void)testUnrecognizedSelector{
    [self performSelector:@selector(testUndefineSelector)];
    [self performSelector:@selector(handleCrashException:exceptionCategory:extraInfo:)];
}

- (void)testNull{
    NSNull* null = [NSNull null];
    NSString* str = (NSString*)null;
    NSLog(@"Str length:%ld",str.length);
}

@end
