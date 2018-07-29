# JJException
* Swizzle常见的错误，如：NSArray越界,NSDictionary空对象
* UnrecognizedSelector
* Zombie crash
* 自定义接口决定是否上报错误信息

## 如何接入
```
pod 'JJException'
``` 

## 如何使用

* 无侵入式，直接引入即可

* 上报错误信息

```
- (void)viewDidLoad {
    [super viewDidLoad];
    [JJException registerExceptionHandle:self];
}

- (void)handleCrashException:(NSString*)exceptionMessage extraInfo:(NSDictionary*)info{
    
}
```

* Zombie对象，自己加名单

```
[JJException addZombieObjectArray:@[TestZombie.class]];
```

## 实现原理

* Swizzle类族
* Objective-c method forward
* MRC
* Zombie机制
