//
//  NSObject+SwizzleHook.m
//  JJException
//
//  Created by Jezz on 2018/7/10.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSObject+SwizzleHook.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>

typedef IMP (^JJSWizzleImpProvider)(void);

static const char jjSwizzledDeallocKey;

@interface JJSwizzleObject()
@property (nonatomic,readwrite,copy) JJSWizzleImpProvider impProviderBlock;
@property (nonatomic,readwrite,assign) SEL selector;
@end

@implementation JJSwizzleObject

- (JJSwizzleOriginalIMP)getOriginalImplementation{
    NSAssert(_impProviderBlock,nil);
    return (JJSwizzleOriginalIMP)_impProviderBlock();
}

@end

void swizzleClassMethod(Class cls, SEL originSelector, SEL swizzleSelector){
    if (!cls) {
        return;
    }
    Method originalMethod = class_getClassMethod(cls, originSelector);
    Method swizzledMethod = class_getClassMethod(cls, swizzleSelector);
    
    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        originSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* swizzing super class method, added if not exist */
        class_replaceMethod(metacls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(metacls,
                            swizzleSelector,
                            class_replaceMethod(metacls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

void swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector){
    if (!cls) {
        return;
    }
    /* if current class not exist selector, then get super*/
    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzleSelector);
    
    /* add selector if not exist, implement append with method */
    if (class_addMethod(cls,
                        originSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        /* replace class instance method, added if selector not exist */
        /* for class cluster , it always add new selector here */
        class_replaceMethod(cls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        /* swizzleMethod maybe belong to super */
        class_replaceMethod(cls,
                            swizzleSelector,
                            class_replaceMethod(cls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

// a class doesn't need dealloc swizzled if it or a superclass has been swizzled already
BOOL jj_requiresDeallocSwizzle(Class class)
{
    BOOL swizzled = NO;
    
    for ( Class currentClass = class; !swizzled && currentClass != nil; currentClass = class_getSuperclass(currentClass) ) {
        swizzled = [objc_getAssociatedObject(currentClass, &jjSwizzledDeallocKey) boolValue];
    }
    
    return !swizzled;
}

void jj_swizzleDeallocIfNeeded(Class class)
{
    static SEL deallocSEL = NULL;
    static SEL cleanupSEL = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deallocSEL = sel_getUid("dealloc");
        cleanupSEL = sel_getUid("jj_cleanKVO");
    });
    
    @synchronized (class) {
        if ( !jj_requiresDeallocSwizzle(class) ) {
            return;
        }
        
        objc_setAssociatedObject(class, &jjSwizzledDeallocKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    Method dealloc = NULL;
    
    unsigned int count = 0;
    Method* method = class_copyMethodList(class, &count);
    for (unsigned int i = 0; i < count; i++) {
        if (method_getName(method[i]) == deallocSEL) {
            dealloc = method[i];
            break;
        }
    }
    
    if ( dealloc == NULL ) {
        Class superclass = class_getSuperclass(class);
        
        class_addMethod(class, deallocSEL, imp_implementationWithBlock(^(__unsafe_unretained id self) {
            
            ((void(*)(id, SEL))objc_msgSend)(self, cleanupSEL);
            
            struct objc_super superStruct = (struct objc_super){ self, superclass };
            ((void (*)(struct objc_super*, SEL))objc_msgSendSuper)(&superStruct, deallocSEL);
            
        }), method_getTypeEncoding(dealloc));
    }else{
        __block IMP deallocIMP = method_setImplementation(dealloc, imp_implementationWithBlock(^(__unsafe_unretained id self) {
            ((void(*)(id, SEL))objc_msgSend)(self, cleanupSEL);
            
            ((void(*)(id, SEL))deallocIMP)(self, deallocSEL);
        }));
    }
}


@implementation NSObject (SwizzleHook)

void __JJ_SWIZZLE_BLOCK(Class classToSwizzle,SEL selector,JJSwizzledIMPBlock impBlock){
    Method method = class_getInstanceMethod(classToSwizzle, selector);
    
    __block IMP originalIMP = NULL;
    
    JJSWizzleImpProvider originalImpProvider = ^IMP{
        
        IMP imp = originalIMP;
        
        if (NULL == imp){
            Class superclass = class_getSuperclass(classToSwizzle);
            imp = method_getImplementation(class_getInstanceMethod(superclass,selector));
        }
        return imp;
    };
    
    JJSwizzleObject* swizzleInfo = [JJSwizzleObject new];
    swizzleInfo.selector = selector;
    swizzleInfo.impProviderBlock = originalImpProvider;
    
    id newIMPBlock = impBlock(swizzleInfo);
    
    const char* methodType = method_getTypeEncoding(method);
    
    IMP newIMP = imp_implementationWithBlock(newIMPBlock);
    
    originalIMP = class_replaceMethod(classToSwizzle, selector, newIMP, methodType);
}

+ (void)jj_swizzleClassMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector{
    swizzleClassMethod(self.class, originSelector, swizzleSelector);
}

- (void)jj_swizzleInstanceMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector{
    swizzleInstanceMethod(self.class, originSelector, swizzleSelector);
}

- (void)jj_swizzleInstanceMethod:(SEL)originSelector withSwizzledBlock:(JJSwizzledIMPBlock)swizzledBlock{
    __JJ_SWIZZLE_BLOCK(self.class, originSelector, swizzledBlock);
}

@end
