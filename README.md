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

* 由于是无侵入式的，所以只要引入代码即可工作

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
```

* Zombie使用黑名单机制，只有加入这个名单的才有作用,示例如下:
```objc
[JJException addZombieObjectArray:@[TestZombie.class]];
```
## 工作原理

[JJException技术原理](https://github.com/jezzmemo/JJException/blob/master/JJExceptionPrinciple.md)

## TODO(大家记得给我星哦)
* 每种异常可自由配置
* 去除无侵入式的加载方式，必须手动开启和关闭
* 报错信息更加详细

## License
JJException is released under the MIT license. See LICENSE for details.
