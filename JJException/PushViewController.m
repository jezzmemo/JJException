//
//  PushViewController.m
//  JJException
//
//  Created by Jezz on 2018/9/2.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "PushViewController.h"

@interface PushViewController ()

@property(nonatomic,readwrite,copy)NSString* test;

//@property(nonatomic,readwrite,copy)NSObject* test1;

@end

@implementation PushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver:self forKeyPath:@"test1" options:NSKeyValueObservingOptionNew context:nil];
    [self removeObserver:self forKeyPath:@"test1" context:nil];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];

    });
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
}

- (void)dealloc{
    NSLog(@"PushViewController%s",__FILE__);
}

@end
