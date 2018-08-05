# JJException

保护App,一般常见的问题不会导致闪退，增强App的健壮性，同时会将错误抛出来，根据每个App自身的日志渠道记录，下次迭代修复那些问题.

__源码在内部测试阶段，后续通过测试后，会放出来__

- [x] Unrecognized Selector Sent to Instance

- [x] NSArray,NSMutableArray,NSDictonary,NSMutableDictionary

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

### Unrecognized Selector Sent to Instance
由于Objective-c是Message机制，而且对象在转换的时候，会有拿到的对象和预期不一致，所以会有方法找不到的情况，在找不到方法时，查找方法将会进入方法Forward流程,系统给了三次补救的机会，所以我们要解决这个问题，在这三次均可以解决这个问题

![forward](https://upload-images.jianshu.io/upload_images/1654054-5e5737afb54d4654.png)

* resolveInstanceMethod:(SEL)sel
这是实例化方法没有找到方法，最先执行的函数，首先会流转到这里来，返回值是BOOL,没有找到就是NO,找到就返回YES,如果要解决就需要再当前的实例中加入不存在的Selector,并绑定IMP，示例如下:
```objc
static void xxxInstanceName(id self, SEL cmd, id value) {
    NSLog(@"resolveInstanceMethod %@", value);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    NSLog(@"resolveInstanceMethod");
    
    NSMethodSignature* sign = [self methodSignatureForSelector:selector];
    if (!sign) {
        class_addMethod([self class], sel, (IMP)xxxInstanceName, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
```

* forwardingTargetForSelector:(SEL)aSelector

如果resolveInstanceMethod没有处理，将进行到forwardingTargetForSelector这步来，这时候你可以返回nil，你也可以用一个Stub对象来接住，把消息流程流转到了你的Stub那边了，然后在你的Stub里添加不存在的Selector，这样就不会crash了，示例如下:
```objc
- (id)forwardingTargetForSelectorSwizzled:(SEL)selector{
    NSMethodSignature* sign = [self methodSignatureForSelector:selector];
    if (!sign) {
        id stub = [[UnrecognizedSelectorHandle new] autorelease];
        class_addMethod([stub class], selector, (IMP)unrecognizedSelector, "v@:");
        return stub;
    }
    return [self forwardingTargetForSelectorSwizzled:selector];
}
```

* methodSignatureForSelector:(SEL)aSelector
* forwardInvocation:(NSInvocation *)anInvocation

这两个方法一起说，因为他们之间有关联，
1. 当methodSignatureForSelector返回nil时，会Crash
2. 如果methodSignatureForSelector返回一个定义好的NSMethodSignature，但是没有实现forwardInvocation，也会闪退，如果实现了forwardInvocation，__会先返回到resolveInstanceMethod然后再才会到forwardInvocation__
3. 当流转到`forwardInvocation`,通过
```
[anInvocation invokeWithTarget:xxxtarget1];
[anInvocation invokeWithTarget:xxxtarget2];
```
还可以流转到多个对象,[anInvocation invokeWithTarget:xxxtarget2]是为了让不存在的方法有着陆点,实验发现流程2的时候，没有[anInvocation invokeWithTarget:xxxtarget1]也不会闪退

### NSArray,NSMutableArray,NSDictonary,NSMutableDictionary

### Zombie Pointer
