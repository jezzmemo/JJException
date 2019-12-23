//
//  PushViewController.m
//  JJException
//
//  Created by Jezz on 2018/9/2.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "PushViewController.h"
#import "KVOObjectDemo.h"


@interface KVOObserver :NSObject

@end

@implementation KVOObserver

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

- (void)dealloc{
    NSLog(@"dealloc");
}

@end

@interface PushViewController (){
    NSTimer* _t;
    KVOObjectDemo* _kvoDemo;
    KVOObserver* _kvoObserver;
}

@property(nonatomic,readwrite,copy)NSString* test;

@property(nonatomic,readwrite,copy)NSString* test1;

@property(nonatomic,readwrite,copy)NSString* demoString1;

@end

@implementation PushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _kvoDemo = [KVOObjectDemo new];
    _kvoObserver = [KVOObserver new];
    
    [self testTimer];
    
    [self testKVO];
    
    [self testNotification];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _kvoObserver = nil;
        self.demoString1 = @"11";
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
    _t = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(scheduledMethod:) userInfo:nil repeats:YES];
}

- (void)scheduledMethod:(NSTimer*)timer{
    NSLog(@"scheduledMethod:%@",timer);
}

#pragma mark - Test KVO

- (void)testKVO{
    [self addObserver:self forKeyPath:@"test1" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"test1" options:NSKeyValueObservingOptionNew context:nil];
    
    [self removeObserver:self forKeyPath:@"test0" context:nil];
    
    [self addObserver:self forKeyPath:@"test2" options:NSKeyValueObservingOptionNew context:nil];
    
    [_kvoDemo addObserver:self forKeyPath:@"demoString" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addObserver:_kvoObserver forKeyPath:@"demoString1" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

#pragma mark - Dealloc

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"test2"];
    NSLog(@"PushViewController%s",__FILE__);
}

@end
