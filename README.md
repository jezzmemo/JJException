[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/JJException.svg)](https://img.shields.io/cocoapods/v/JJException.svg)
[![Build Status](https://travis-ci.org/jezzmemo/JJException.svg?branch=master)](https://travis-ci.org/jezzmemo/JJException.svg?branch=master)
[![codecov](https://codecov.io/gh/jezzmemo/JJException/branch/master/graph/badge.svg)](https://codecov.io/gh/jezzmemo/JJException)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/cocoapods/p/JJException.svg?style=flat)](http://cocoadocs.org/docsets/JJException)
![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)

# JJException

Common problems will not crash by the JJException,Hook the Unrecognized Selector,Out of bound,Paramter is nil,etc.Throw the exception to the interface,And then save the exception record to the log,Upgrad the app or Hot-Fix to resolve the exception.


保护App,一般常见的问题不会导致闪退，增强App的健壮性，同时会将错误抛出来，根据每个App自身的日志渠道记录，下次迭代或者热修复以下问题.

- [x] Unrecognized Selector Sent to Instance(方法不存在异常)

- [x] NSNull(方法不存在异常)

- [x] NSArray,NSMutableArray,NSDictonary,NSMutableDictionary(数组越界,key-value参数异常)

- [x] KVO(忘记移除keypath导致闪退)

- [x] NSTimer(忘记移除导致内存泄漏)

- [x] NSNotification(忘记移除导致异常)

- [x] NSString,NSMutableString,NSAttributedString,NSMutableAttributedString(下标越界以及参数nil异常)

## 如何安装

__Requirements__

* iOS 8.0+
* OSX 10.7+
* Xcode 8.0+

__Podfile__

```
pod 'JJException'
```

__Cartfile__

```
github "jezzmemo/JJException"
```

__手动导入代码__

导入`Source`文件夹里所有文件，需要将`MRC`目录下所有.m文件，编译选项更改成-fno-objc-arc

## 如何使用

* 所有异常的分类,根据自身需要，自由组合
```objc
typedef NS_OPTIONS(NSInteger,JJExceptionGuardCategory){
    JJExceptionGuardNone = 0,
    JJExceptionGuardUnrecognizedSelector = 1 << 1,
    JJExceptionGuardDictionaryContainer = 1 << 2,
    JJExceptionGuardArrayContainer = 1 << 3,
    JJExceptionGuardKVOCrash = 1 << 4,
    JJExceptionGuardNSTimer = 1 << 5,
    JJExceptionGuardNSNotificationCenter = 1 << 6,
    JJExceptionGuardNSStringContainer = 1 << 7,
    JJExceptionGuardAll = JJExceptionGuardUnrecognizedSelector | JJExceptionGuardDictionaryContainer | JJExceptionGuardArrayContainer | JJExceptionGuardKVOCrash | JJExceptionGuardNSTimer | JJExceptionGuardNSNotificationCenter | JJExceptionGuardNSStringContainer,
};
```

* 设置异常类型并开启，__建议放在`didFinishLaunchingWithOptions`第一行，以免在多线程出现异常的情况__
```objc
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
```

* 当异常时，默认程序不会中断，如果需要遇到异常时退出，需要如下设置:
```objc
    //Default value:NO
    JJException.exceptionWhenTerminate = YES;
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

- (void)handleCrashException:(NSString*)exceptionMessage exceptionCategory:(JJExceptionGuardCategory)exceptionCategory extraInfo:(nullable NSDictionary*)info{

}
```

## FAQ

> 是否影响上线App Store

不会的，JJException的功能都是使用的官方API,没有任何私有API

> 保护App的实现技术原理是什么?

[JJException技术原理](https://github.com/jezzmemo/JJException/blob/master/JJExceptionPrinciple.md)

> JJException是否和Bugly和友盟等第三方库是否有冲突？

Bugly和友盟是记录Crash Bug的log还有一些统计功能，JJException主要是通过Hook技术来实现，所以不会和JJException冲突

> 如何上传异常信息到Bugly？

Bugly可以帮我们解决重复信息和CallStack信息，以及状态维护。  
实现JJExceptionHandle协议后，将异常信息组织成Error，然后用[Bugly reportError:error]上传异常信息，上传后异常信息Bugly的后台`错误分析`菜单里

> Swift是否有作用

是有作用的，Swift有些API实现是独立实现的，比如String,Array,用结构体的方式，但是有些还是沿用了Objective-c，凡是沿用Objective-c的特性的，JJException还是生效的，下面我来列下还依然生效的功能点:

* Unrecognized Selector Sent to Instance
* NSNull
* KVO
* NSNotification
* NSString,NSMutableString,NSAttributedString,NSMutableAttributedString(__注意不是String__)
* NSArray,NSMutableArray,NSDictonary,NSMutableDictionary(__注意不是Array__)

这里贴下Swift的初始化代码示例:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    self.registerJJException()
    return true
}
    
func registerJJException(){
    JJException.configExceptionCategory(.all)
    JJException.startGuard()
    JJException.register(self);
}
    
func handleCrashException(_ exceptionMessage: String, extraInfo info: [AnyHashable : Any]?) {
        
}
```

> JJException Hook那些API?

[HookAPI](https://github.com/jezzmemo/JJException/blob/master/JJExceptionHookAPI.md)


## TODO(大家记得给我星哦)
* 国际化JJException

## Linker
* [高性能自定义日志](https://github.com/jezzmemo/JJSwiftLog)

## License
JJException is released under the MIT license. See LICENSE for details.
