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
3. 当流转到`forwardInvocation`,通过以下方法:
```
[anInvocation invokeWithTarget:xxxtarget1];
[anInvocation invokeWithTarget:xxxtarget2];
```
还可以流转到多个对象,[anInvocation invokeWithTarget:xxxtarget2]是为了让不存在的方法有着陆点

* doesNotRecognizeSelector:(SEL)aSelector
执行到这里的时候，两种情况:
1. 当methodSignatureForSelector返回一种任意的方法签名的时候，也会进入doesNotRecognizeSelector，但是不会闪退
2. 当methodSignatureForSelector返回nil时，进入doesNotRecognizeSelector就会闪退

根据以上流程，最终还是选择流程2,原因如下:
1. resolveInstanceMethod虽然可以解决问题，给不存在的方法增加到示例中去，会污染当前示例
2. forwardInvocation在三步中式最后一步，会导致流转的周期变长，而且会产生NSInvocation,性能不是最好的选择

### NSArray,NSMutableArray,NSDictonary,NSMutableDictionary

* 类族(Class Cluster)

NSDictonary，NSArray,NSString等，都使用了类族，这种模式最大的好处就是，可以隐藏抽象基类背后的复杂细节，使用者只需调用基类简单的方法就可以返回不同的子类实例

* Swizzle Hook

这里就不赘述Swizzle概念了，Google到处都是讲解的，这里给一个典型的例子:
```
swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));

- (id) hookObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self hookObjectAtIndex:index];
    }
    handleCrashException(@"HookObjectAtIndex invalid index");
    return nil;
}
```

### Zombie Pointer

让野指针不闪退是模仿了XCode debug的Zombie Object，也参考了网易和美团的做法,主要是以下步骤:

1. Hook住dealloc方法
2. 如果当前示例在黑名单里，就把当年前示例加入集合，并把当前对象`objc_destructInstance`清理引用关系，并未真正释放内存，并将`object_setClass`设置成自己的中间对象
3. Hook中间对象的方法，收到的消息都由中间对象来处理
4. 维护的野指针集合，要么根据个数来维护，要么根据总大小来维护，当满了，就需要真正释放对象内存`free(obj)`

存在的问题:

1. 需要单独的内存那些问题对象
2. 最后释放内存后，再访问时会闪退，这个方法只是一定程度延迟了闪退时间
3. 需要后台维护黑名单机制，来指定那些问题对象

### KVO，NSTimer，NSNotification

这三种放在一起，是因为他们之间有共同的特征，就是创建后，忘记销毁会导致闪退，或者会有一些异常的情况，所以需要一种知道当前创建者啥时候释放，首先会想到dealloc,这样会Hook的NSObject,在一定程度会影响性能，后面发现一种比较优雅的方法,原理来自于Runtime源码:
```
/***********************************************************************
* objc_destructInstance
* Destroys an instance without freeing memory. 
* Calls C++ destructors.
* Calls ARR ivar cleanup.
* Removes associative references.
* Returns `obj`. Does nothing if `obj` is nil.
* Be warned that GC DOES NOT CALL THIS. If you edit this, also edit finalize.
* CoreFoundation and other clients do call this under GC.
**********************************************************************/
void *objc_destructInstance(id obj) 
{
    if (obj) {
        // Read all of the flags at once for performance.
        bool cxx = obj->hasCxxDtor();
        bool assoc = !UseGC && obj->hasAssociatedObjects();
        bool dealloc = !UseGC;

        // This order is important.
        if (cxx) object_cxxDestruct(obj);
        if (assoc) _object_remove_assocations(obj);
        if (dealloc) obj->clearDeallocating();
    }

    return obj;
}
```

用`objc_setAssociatedObject`给当前对象，当前对象释放时，会清理AssociatedObject数据，AssociatedObject对象将被清理释放，AssociatedObject的dealloc方法将被执行，最终清理之前加入的监听。

* KVO(addObserver:forKeyPath)
* NSNotification(addObserver:selector)

### MRC
