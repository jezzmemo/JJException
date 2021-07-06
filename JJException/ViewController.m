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
    
    UIButton* JSONSerializationButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [JSONSerializationButton setTitle:@"Test NSJSONSerialization" forState:UIControlStateNormal];
    [JSONSerializationButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    JSONSerializationButton.frame = CGRectMake(0, 400, self.view.frame.size.width, 50);
    [JSONSerializationButton addTarget:self action:@selector(testNSJSONSerialization) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:JSONSerializationButton];
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

- (void)testNSJSONSerialization{
    ///case1, obj is nil
    NSObject *obj;
    [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
    
    ///case2, data is nil
    NSData *data;
    [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    ///case3, obj is nil or stream is not available
    NSOutputStream *oStream;
    [NSJSONSerialization writeJSONObject:obj toStream:oStream options:0 error:nil];
    
    ///case4, stream is not available
    NSInputStream *iStream = [[NSInputStream alloc] initWithData:NSData.new];
    [NSJSONSerialization JSONObjectWithStream:iStream options:NSJSONReadingMutableContainers error:nil];
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
