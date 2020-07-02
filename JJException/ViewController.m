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
#import "KVOObjectDemo.h"

@interface KVOCrashObject : NSObject
@property (nonatomic, copy) NSString *name;
@end

@implementation KVOCrashObject
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    NSLog(@"KVOCrashObject：object = %@, keyPath = %@", object, keyPath);
}
- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end


@interface ViewController ()<JJExceptionHandle>

@property(nonatomic,readwrite,strong)KVOObjectDemo* kvoObject;
@property(nonatomic,readwrite,strong)KVOObjectDemo* kvoObject2;

@property (nonatomic, strong) KVOCrashObject *objc;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton* startGuardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [startGuardButton setTitle:@"Start Guard" forState:UIControlStateNormal];
    [startGuardButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    startGuardButton.frame = CGRectMake((self.view.frame.size.width - 100)/2, 80, 100, 50);
    [startGuardButton addTarget:self action:@selector(startGuardAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startGuardButton];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Test KVO|NotificatinCenter|NSTimer" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 120, self.view.frame.size.width, 50);
    [button addTarget:self action:@selector(testKVONotificatinCenterNSTimerAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

//    UIButton* otherButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [otherButton setTitle:@"Test NSArray|NSDictionary|UnrecognizedSelector|NSNull" forState:UIControlStateNormal];
//    [otherButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    otherButton.frame = CGRectMake(0, 350, self.view.frame.size.width, 50);
//    [otherButton addTarget:self action:@selector(testArrayDictionaryUnrecognizedSelector) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:otherButton];
    
    self.kvoObject = [[KVOObjectDemo alloc] init];
    self.kvoObject2 = [[KVOObjectDemo alloc] init];
    
    [self setupUI];
    [self startGuardAction];
}

- (void)setupUI {
    NSArray *titleArray = @[
                    @"1.1 移除了未注册的观察者",
                    @"1.2 重复移除多次，移除次数多于添加次数",
                    @"1.3 重复添加多次，被观察多次。",
                    @"2. 被观察者 dealloc 时仍然注册着 KVO",
                    @"3. 观察者没有实现观察方法",
                    @"4. 添加或者移除时 keypath == nil",
                    @"5. 多线程操作add和remove"
                    ];
    
    self.objc = [[KVOCrashObject alloc] init];
    
    CGFloat buttonWidth = (self.view.frame.size.width-60);
    CGFloat buttonHeight = 44;
    CGFloat buttonSpace = 30;
    CGFloat buttonGap = 10;
    for (int i = 0; i < titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1000+i;
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        button.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        button.frame = CGRectMake(buttonSpace, 200+(buttonHeight+buttonGap)*i, buttonWidth, buttonHeight);
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.backgroundColor = [UIColor colorWithRed:214/255.0 green:235/255.0 blue:253/255.0 alpha:1];
        [self.view addSubview:button];
    }
}

- (void)buttonClick:(UIButton *)button {
    NSInteger buttonTag = button.tag;
    switch (buttonTag) {
        case 1000: {
            [self testKVOCrash11];
        }
            break;
        case 1001: {
            [self testKVOCrash12];
        }
            break;
        case 1002: {
            [self testKVOCrash13];
        }
            break;
        case 1003: {
            [self testKVOCrash2];
        }
            break;
        case 1004: {
            [self testKVOCrash3];
        }
            break;
        case 1005: {
            [self testKVOCrash4];
        }
            break;
        case 1006: {
            [self testKVOCrash5];
        }
            break;
        default:
            break;
    }
}

/**
 1.1 移除了未注册的观察者，导致崩溃
 */
- (void)testKVOCrash11 {
    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
    [self.objc removeObserver:self forKeyPath:@"name"];
}

/**
 1.2 重复移除多次，移除次数多于添加次数，导致崩溃
 */
- (void)testKVOCrash12 {
    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objc.name = @"0";
    [self.objc removeObserver:self forKeyPath:@"name"];
    [self.objc removeObserver:self forKeyPath:@"name"];
}

/**
 1.3 重复添加多次，虽然不会崩溃，但是发生改变时，也同时会被观察多次。
 */
- (void)testKVOCrash13 {
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
    self.objc.name = @"0";
}

/**
 2. 被观察者 dealloc 时仍然注册着 KVO，导致崩溃
 */
- (void)testKVOCrash2 {
    // 崩溃日志：An instance xxx of class xxx was deallocated while key value observers were still registered with it.
    // iOS 10 及以下会导致崩溃，iOS 11 之后就不会崩溃了
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    [obj addObserver: self
          forKeyPath: @"name"
             options: NSKeyValueObservingOptionNew
             context: nil];
}

/**
 3. 观察者没有实现 -observeValueForKeyPath:ofObject:change:context:导致崩溃
 */
- (void)testKVOCrash3 {
    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    
    [self addObserver: obj
           forKeyPath: @"title"
              options: NSKeyValueObservingOptionNew
              context: nil];
    
    self.title = @"111";
    
}

/**
 4. 添加或者移除时 keypath == nil，导致崩溃。
 */
- (void)testKVOCrash4 {
    // 崩溃日志： -[__NSCFConstantString characterAtIndex:]: Range or index out of bounds
    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
    
    [self addObserver: obj
           forKeyPath: @""
              options: NSKeyValueObservingOptionNew
              context: nil];
    
//    [self removeObserver:obj forKeyPath:@""];
}

/**
 5. 多线程操作add和remove
 */
- (void)testKVOCrash5 {
    dispatch_queue_t queue = dispatch_queue_create("testkvo", DISPATCH_QUEUE_CONCURRENT);

    for (int i = 0; i < 1000; i++) {
        NSString *str = [NSString stringWithFormat:@"name%d", i];
        dispatch_async(queue, ^{
            [self.objc addObserver:self forKeyPath:str options:NSKeyValueObservingOptionNew context:nil];
        });
        dispatch_async(queue, ^{
            [self.objc removeObserver:self forKeyPath:str context:nil];
        });
        dispatch_async(queue, ^{
            self.objc.name = str;
        });
        dispatch_async(queue, ^{
            self.objc = nil;
        });
        dispatch_async(queue, ^{
            self.objc = [[KVOCrashObject alloc] init];
        });
    }
    dispatch_barrier_async(queue, ^{
        [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
        self.objc.name = @"🍎📷😄";
    });
}

#pragma mark - Test Action

- (void)testKVONotificatinCenterNSTimerAction{
    PushViewController* push = [[PushViewController alloc] init];
    push.kvoObject = self.kvoObject;
    push.kvoObject2 = self.kvoObject2;
    [self presentViewController:push animated:YES completion:^{
        self.kvoObject = nil;
//        self.kvoObject2 = nil;
    }];
}














#pragma mark - observe

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
    NSLog(@"object = %@, keyPath = %@, change = %@", object, keyPath, change[@"new"]);
}

#pragma mark - Start

- (void)startGuardAction{
    JJException.exceptionWhenTerminate = NO;
    
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
    
    [JJException registerExceptionHandle:self];
}

#pragma mark - Exception Delegate

- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{

}

//#pragma mark - Origin
//
//- (void)testArrayDictionaryUnrecognizedSelector{
//    [self testSampleArray];
//    [self testSimpleDictionary];
//    [self testUnrecognizedSelector];
//    [self testNull];
//}
//
//- (void)testSampleArray{
//    NSArray* test = @[];
//    NSLog(@"object:%@",test[1]);
//}
//
//- (void)testSimpleDictionary{
//    id value = nil;
//    NSDictionary* dic = @{@"key":value};
//    NSLog(@"dic:%@",dic);
//}
//
//- (void)testUnrecognizedSelector{
//    [self performSelector:@selector(testUndefineSelector)];
//    [self performSelector:@selector(handleCrashException:exceptionCategory:extraInfo:)];
//}
//
//- (void)testNull{
//    NSNull* null = [NSNull null];
//    NSString* str = (NSString*)null;
//    NSLog(@"Str length:%ld",str.length);
//}

@end
