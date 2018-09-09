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
 Address Offset,arm64:0x0000000100000000 armv7:0x00004000

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
    dispatch_semaphore_t _classArrayLock;
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
    }
    return self;
}

- (void)handleCrashException:(NSString *)exceptionMessage extraInfo:(nullable NSDictionary *)info{
    if (!exceptionMessage) {
        return;
    }
    
    NSArray* callStack = [NSThread callStackSymbols];
    NSString* callStackString = [NSString stringWithFormat:@"%@",callStack];
    
    NSString* exceptionResult = [NSString stringWithFormat:@"%@\n%@",exceptionMessage,callStackString];
    
    
    if ([self.delegate respondsToSelector:@selector(handleCrashException:extraInfo:)]){
        [self.delegate handleCrashException:exceptionResult extraInfo:info];
    }
    
#ifdef DEBUG
    NSLog(@"================================JJException Start==================================");
    NSAssert(NO, exceptionResult);
    NSLog(@"================================JJException End====================================");
#endif
    
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

- (id)objectFromCurrentClassesSet{
    NSEnumerator* objectEnum = [_currentClassesSet objectEnumerator];
    for (id object in objectEnum) {
        return object;
    }
    return nil;
}

@end
