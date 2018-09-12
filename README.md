[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JJException.svg)](https://img.shields.io/cocoapods/v/JJException.svg)
[![Platform](https://img.shields.io/cocoapods/p/JJException.svg?style=flat)](http://cocoadocs.org/docsets/JJException)
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)

# JJException

保护App,一般常见的问题不会导致闪退，增强App的健壮性，同时会将错误抛出来，根据每个App自身的日志渠道记录，下次迭代或者热修复以下问题.

- [x] Unrecognized Selector Sent to Instance

- [x] NSArray,NSMutableArray,NSDictonary,NSMutableDictionary

- [x] KVO

- [x] Zombie Pointer

- [x] NSTimer

- [x] NSNotification

## 如何安装

```
pod 'JJException'
```

## 如何使用

* 设置异常类型并开启
```objc
    [JJException configExceptionCategory:JJExceptionGuardAll];
    //[JJException configExceptionCategory:JJExceptionGuardUnrecognizedSelector | JJExceptionGuardDictionaryContainer];
    [JJException startGuardException];
```

* 实时关闭保护
```objc
	[JJException stopGuardException];
```

* 如果需要记录日志，只需要实现`JJExceptionHandle`协议，并注册:
```objc
@interface ViewController ()<JJExceptionHandle>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [JJException registerExceptionHandle:self];
}

- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{
    
}
- (void)handleCrashException:(NSString*)exceptionMessage exceptionCategory:(JJExceptionGuardCategory)exceptionCategory extraInfo:(nullable NSDictionary*)info{

}
```

* Zombie使用黑名单机制，只有加入这个名单的才有作用,示例如下:
```objc
[JJException addZombieObjectArray:@[TestZombie.class]];
```
## 工作原理

[JJException技术原理](https://github.com/jezzmemo/JJException/blob/master/JJExceptionPrinciple.md)

## TODO(大家记得给我星哦)
* 正在构思

## License
JJException is released under the MIT license. See LICENSE for details.
