//
//  JJExceptionProxy.m
//  JJException
//
//  Created by Jezz on 2018/7/22.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "JJExceptionProxy.h"
#import <mach-o/dyld.h>
#import <objc/runtime.h>

__attribute__((overloadable)) void handleCrashException(NSString* exceptionMessage){
    [[JJExceptionProxy shareExceptionProxy] handleCrashException:exceptionMessage extraInfo:@{}];
}

__attribute__((overloadable)) void handleCrashException(NSString* exceptionMessage,NSDictionary* extraInfo){
    [[JJExceptionProxy shareExceptionProxy] handleCrashException:exceptionMessage extraInfo:extraInfo];
}

__attribute__((overloadable)) void handleCrashException(JJExceptionGuardCategory exceptionCategory, NSString* exceptionMessage,NSDictionary* extraInfo){
    [[JJExceptionProxy shareExceptionProxy] handleCrashException:exceptionMessage exceptionCategory:exceptionCategory extraInfo:extraInfo];
}

__attribute__((overloadable)) void handleCrashException(JJExceptionGuardCategory exceptionCategory, NSString* exceptionMessage){
    [[JJExceptionProxy shareExceptionProxy] handleCrashException:exceptionMessage exceptionCategory:exceptionCategory extraInfo:nil];
}

/**
 Get application base address,the application different base address after started
 
 @return base address
 */
uintptr_t get_load_address(void) {
    const struct mach_header *exe_header = NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE) {
            exe_header = header;
            break;
        }
    }
    return (uintptr_t)exe_header;
}

/**
 Address Offset

 @return slide address
 */
uintptr_t get_slide_address(void) {
    uintptr_t vmaddr_slide = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE) {
            vmaddr_slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    
    return (uintptr_t)vmaddr_slide;
}

@interface JJExceptionProxy(){
    NSMutableSet* _currentClassesSet;
    NSMutableSet* _blackClassesSet;
    NSInteger _currentClassSize;
    dispatch_semaphore_t _classArrayLock;//Protect _blackClassesSet and _currentClassesSet atomic
    dispatch_semaphore_t _swizzleLock;//Protect swizzle atomic
}

@end

@implementation JJExceptionProxy

+(instancetype)shareExceptionProxy{
    static dispatch_once_t onceToken;
    static id exceptionProxy;
    dispatch_once(&onceToken, ^{
        exceptionProxy = [[self alloc] init];
    });
    return exceptionProxy;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _blackClassesSet = [NSMutableSet new];
        _currentClassesSet = [NSMutableSet new];
        _currentClassSize = 0;
        _classArrayLock = dispatch_semaphore_create(1);
        _swizzleLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)handleCrashException:(NSString *)exceptionMessage exceptionCategory:(JJExceptionGuardCategory)exceptionCategory extraInfo:(NSDictionary *)info{
    if (!exceptionMessage) {
        return;
    }
    
    NSArray* callStack = [NSThread callStackSymbols];
    NSString* callStackString = [NSString stringWithFormat:@"%@",callStack];
    
    uintptr_t loadAddress =  get_load_address();
    uintptr_t slideAddress =  get_slide_address();
    
    NSString* exceptionResult = [NSString stringWithFormat:@"%ld\n%ld\n%@\n%@",loadAddress,slideAddress,exceptionMessage,callStackString];
    
    
    if ([self.delegate respondsToSelector:@selector(handleCrashException:extraInfo:)]){
        [self.delegate handleCrashException:exceptionResult extraInfo:info];
    }
    
    if ([self.delegate respondsToSelector:@selector(handleCrashException:exceptionCategory:extraInfo:)]) {
        [self.delegate handleCrashException:exceptionResult exceptionCategory:exceptionCategory extraInfo:info];
    }
    
#ifdef DEBUG
    NSLog(@"================================JJException Start==================================");
    NSLog(@"JJException Type:%ld",(long)exceptionCategory);
    NSLog(@"JJException Description:%@",exceptionMessage);
    NSLog(@"JJException Extra info:%@",info);
    NSLog(@"JJException CallStack:%@",callStack);
    NSLog(@"================================JJException End====================================");
    if (self.exceptionWhenTerminate) {
        NSAssert(NO, @"");
    }
#endif
}

- (void)handleCrashException:(NSString *)exceptionMessage extraInfo:(nullable NSDictionary *)info{
    [self handleCrashException:exceptionMessage exceptionCategory:JJExceptionGuardNone extraInfo:info];
}

- (void)setIsProtectException:(BOOL)isProtectException{
    dispatch_semaphore_wait(_swizzleLock, DISPATCH_TIME_FOREVER);
    if (_isProtectException != isProtectException) {
        _isProtectException = isProtectException;
        
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wundeclared-selector"
        
        if(self.exceptionGuardCategory & JJExceptionGuardArrayContainer){
            [NSArray performSelector:@selector(jj_swizzleNSArray)];
            [NSMutableArray performSelector:@selector(jj_swizzleNSMutableArray)];
            [NSSet performSelector:@selector(jj_swizzleNSSet)];
            [NSMutableSet performSelector:@selector(jj_swizzleNSMutableSet)];
        }
        if(self.exceptionGuardCategory & JJExceptionGuardDictionaryContainer){
            [NSDictionary performSelector:@selector(jj_swizzleNSDictionary)];
            [NSMutableDictionary performSelector:@selector(jj_swizzleNSMutableDictionary)];
        }
        if(self.exceptionGuardCategory & JJExceptionGuardUnrecognizedSelector){
            [NSObject performSelector:@selector(jj_swizzleUnrecognizedSelector)];
        }
        
        if (self.exceptionGuardCategory & JJExceptionGuardZombie) {
            [NSObject performSelector:@selector(jj_swizzleZombie)];
        }
        
        if (self.exceptionGuardCategory & JJExceptionGuardKVOCrash) {
            [NSObject performSelector:@selector(jj_swizzleKVOCrash)];
        }
        
        if (self.exceptionGuardCategory & JJExceptionGuardNSTimer) {
            [NSTimer performSelector:@selector(jj_swizzleNSTimer)];
        }
        
        if (self.exceptionGuardCategory & JJExceptionGuardNSNotificationCenter) {
            [NSNotificationCenter performSelector:@selector(jj_swizzleNSNotificationCenter)];
        }
        
        if (self.exceptionGuardCategory & JJExceptionGuardNSStringContainer) {
            [NSString performSelector:@selector(jj_swizzleNSString)];
            [NSMutableString performSelector:@selector(jj_swizzleNSMutableString)];
            [NSAttributedString performSelector:@selector(jj_swizzleNSAttributedString)];
            [NSMutableAttributedString performSelector:@selector(jj_swizzleNSMutableAttributedString)];
        }
        #pragma clang diagnostic pop
    }
    dispatch_semaphore_signal(_swizzleLock);
}

- (void)setExceptionGuardCategory:(JJExceptionGuardCategory)exceptionGuardCategory{
    if (_exceptionGuardCategory != exceptionGuardCategory) {
        _exceptionGuardCategory = exceptionGuardCategory;
    }
}



- (void)addZombieObjectArray:(NSArray*)objects{
    if (!objects) {
        return;
    }
    dispatch_semaphore_wait(_classArrayLock, DISPATCH_TIME_FOREVER);
    [_blackClassesSet addObjectsFromArray:objects];
    dispatch_semaphore_signal(_classArrayLock);
}

- (NSSet*)blackClassesSet{
    return _blackClassesSet;
}

- (void)addCurrentZombieClass:(Class)object{
    if (object) {
        dispatch_semaphore_wait(_classArrayLock, DISPATCH_TIME_FOREVER);
        _currentClassSize = _currentClassSize + class_getInstanceSize(object);
        [_currentClassesSet addObject:object];
        dispatch_semaphore_signal(_classArrayLock);
    }
}

- (void)removeCurrentZombieClass:(Class)object{
    if (object) {
        dispatch_semaphore_wait(_classArrayLock, DISPATCH_TIME_FOREVER);
        _currentClassSize = _currentClassSize - class_getInstanceSize(object);
        [_currentClassesSet removeObject:object];
        dispatch_semaphore_signal(_classArrayLock);
    }
}

- (NSSet*)currentClassesSet{
    return _currentClassesSet;
}

- (NSInteger)currentClassSize{
    return _currentClassSize;
}

- (nullable id)objectFromCurrentClassesSet{
    NSEnumerator* objectEnum = [_currentClassesSet objectEnumerator];
    for (id object in objectEnum) {
        return object;
    }
    return nil;
}

@end
