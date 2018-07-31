# JJException

保护App,一般常见的问题不会导致闪退，增强App的健壮性，同时会将错误抛出来，根据每个App自身的日志渠道记录，下次迭代修复那些问题.

__源码在内部测试阶段，后续通过测试后，会放出来__

- [x] Unrecognized Selector Sent to Instance

- [x] NSArray,NSDictonary

- [ ] KVO

- [x] Zombie Pointer

- [ ] NSTimer

- [ ] NSNotification

## 如何安装

```
pod 'JJException'
```

## 如何使用

* 由于是无侵入式的，所以只要引入代码即可工作

* 如果需要记录日志，只需要实现`JJExceptionHandle`协议，并注册:
```
@interface ViewController ()<JJExceptionHandle>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [JJException registerExceptionHandle:self];
}

- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{
    
}
```

## 工作原理
