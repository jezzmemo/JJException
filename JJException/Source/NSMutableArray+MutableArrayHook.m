//
//  NSMutableArray+MutableArrayHook.m
//  JJException
//
//  Created by Jezz on 2018/7/15.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSMutableArray+MutableArrayHook.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"

@implementation NSMutableArray (MutableArrayHook)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:), @selector(hookAddObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(insertObject:atIndex:), @selector(hookInsertObject:atIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(removeObjectAtIndex:), @selector(hookRemoveObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(replaceObjectAtIndex:withObject:), @selector(hookReplaceObjectAtIndex:withObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(removeObjectsInRange:), @selector(hookRemoveObjectsInRange:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
        
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(addObject:), @selector(hookAddObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(insertObject:atIndex:), @selector(hookInsertObject:atIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(removeObjectAtIndex:), @selector(hookRemoveObjectAtIndex:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(replaceObjectAtIndex:withObject:), @selector(hookReplaceObjectAtIndex:withObject:));
        swizzleInstanceMethod(NSClassFromString(@"__NSCFArray"), @selector(removeObjectsInRange:), @selector(hookRemoveObjectsInRange:));
    });
}

- (void) hookAddObject:(id)anObject {
    if (anObject) {
        [self hookAddObject:anObject];
    }else{
        handleCrashException(@"HookAddObject invalid object");
    }
}
- (id) hookObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self hookObjectAtIndex:index];
    }else{
        handleCrashException(@"HookObjectAtIndex invalid index");
    }
    return nil;
}
- (id) hookObjectAtIndexedSubscript:(NSInteger)index {
    if (index < self.count) {
        return [self hookObjectAtIndexedSubscript:index];
    }
    handleCrashException(@"HookObjectAtIndexedSubscript invalid index");
    return nil;
}
- (void) hookInsertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject && index <= self.count) {
        [self hookInsertObject:anObject atIndex:index];
    }else{
        handleCrashException(@"HookInsertObject invalid index and object");
    }
}

- (void) hookRemoveObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self hookRemoveObjectAtIndex:index];
    }else{
        handleCrashException(@"HookRemoveObjectAtIndex invalid index");
    }
}


- (void) hookReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (index < self.count && anObject) {
        [self hookReplaceObjectAtIndex:index withObject:anObject];
    }else{
        handleCrashException(@"HookReplaceObjectAtIndex invalid index and object");
    }
}

- (void) hookRemoveObjectsInRange:(NSRange)range {
    if (range.location + range.length <= self.count) {
        [self hookRemoveObjectsInRange:range];
    }else{
        handleCrashException(@"HookRemoveObjectsInRange invalid range");
    }
}

- (NSArray *)hookSubarrayWithRange:(NSRange)range
{
    if (range.location + range.length <= self.count){
        return [self hookSubarrayWithRange:range];
    }else if (range.location < self.count){
        return [self hookSubarrayWithRange:NSMakeRange(range.location, self.count-range.location)];
    }
    handleCrashException(@"HookSubarrayWithRange invalid range");
    return nil;
}

@end
