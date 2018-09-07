//
//  PushViewController.m
//  JJException
//
//  Created by Jezz on 2018/9/2.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "PushViewController.h"

@interface PushViewController (){
    NSTimer* _t;
}

@property(nonatomic,readwrite,copy)NSString* test;

//@property(nonatomic,readwrite,copy)NSObject* test1;

@end

@implementation PushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testTimer];
    
    [self testKVO];
    
    [self testNotification];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
    
}

#pragma mark - Test Notifiaction

- (void)testNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(testNotificationObserver) name:@"test" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"test" object:nil];
}

- (void)testNotificationObserver{
    NSLog(@"testNotificationObserver");
}

#pragma mark - Test Timer

- (void)testTimer{
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scheduledMethod) userInfo:nil repeats:YES];
}

- (void)scheduledMethod{
    NSLog(@"11");
}

#pragma mark - Test KVO

- (void)testKVO{
    [self addObserver:self forKeyPath:@"test1" options:NSKeyValueObservingOptionNew context:nil];
//    [self removeObserver:self forKeyPath:@"test1" context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

#pragma mark - Dealloc

- (void)dealloc{
    [_t invalidate];
    _t = nil;
    NSLog(@"PushViewController%s",__FILE__);
}

@end
