//
//  NSArray+ArrayHook.m
//  JJException
//
//  Created by Jezz on 2018/7/11.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "NSArray+ArrayHook.h"
#import "NSObject+SwizzleHook.h"
#import "JJExceptionProxy.h"
#import "JJExceptionMacros.h"

JJSYNTH_DUMMY_CLASS(NSArray_ArrayHook)

@implementation NSArray (ArrayHook)

+ (void)jj_swizzleNSArray{
    [NSArray jj_swizzleClassMethod:@selector(arrayWithObject:) withSwizzleMethod:@selector(hookArrayWithObject:)];
    [NSArray jj_swizzleClassMethod:@selector(arrayWithObjects:count:) withSwizzleMethod:@selector(hookArrayWithObjects:count:)];
    
    /* __NSArray0 */
    swizzleInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
    
    /* __NSArrayI */
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
    
    /* __NSArrayI_Transfer */
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayI_Transfer"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayI_Transfer"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayI_Transfer"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
    
    /* above iOS10  __NSSingleObjectArrayI */
    swizzleInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
    
    /* __NSFrozenArrayM */
    swizzleInstanceMethod(NSClassFromString(@"__NSFrozenArrayM"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSFrozenArrayM"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSFrozenArrayM"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
    
    /* __NSArrayReversed */
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayReversed"), @selector(objectAtIndex:), @selector(hookObjectAtIndex:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayReversed"), @selector(subarrayWithRange:), @selector(hookSubarrayWithRange:));
    swizzleInstanceMethod(NSClassFromString(@"__NSArrayReversed"), @selector(objectAtIndexedSubscript:), @selector(hookObjectAtIndexedSubscript:));
}

+ (instancetype) hookArrayWithObject:(id)anObject
{
    if (anObject) {
        return [self hookArrayWithObject:anObject];
    }
    handleCrashException(JJExceptionGuardArrayContainer,@"NSArray arrayWithObject object is nil");
    return nil;
}

- (id) hookObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self hookObjectAtIndex:index];
    }
    handleCrashException(JJExceptionGuardArrayContainer,[NSString stringWithFormat:@"NSArray objectAtIndex invalid index:%tu total:%tu",index,self.count]);
    return nil;
}
- (id) hookObjectAtIndexedSubscript:(NSInteger)index {
    if (index < self.count) {
        return [self hookObjectAtIndexedSubscript:index];
    }
    handleCrashException(JJExceptionGuardArrayContainer,[NSString stringWithFormat:@"NSArray objectAtIndexedSubscript invalid index:%tu total:%tu",index,self.count]);
    return nil;
}
- (NSArray *)hookSubarrayWithRange:(NSRange)range
{
    if (range.location + range.length <= self.count){
        return [self hookSubarrayWithRange:range];
    }else if (range.location < self.count){
        return [self hookSubarrayWithRange:NSMakeRange(range.location, self.count-range.location)];
    }
    handleCrashException(JJExceptionGuardArrayContainer,[NSString stringWithFormat:@"NSArray subarrayWithRange invalid range location:%tu length:%tu",range.location,range.length]);
    return nil;
}
+ (instancetype)hookArrayWithObjects:(const id [])objects count:(NSUInteger)cnt
{
    NSInteger index = 0;
    id objs[cnt];
    for (NSInteger i = 0; i < cnt ; ++i) {
        if (objects[i]) {
            objs[index++] = objects[i];
        }else{
            handleCrashException(JJExceptionGuardArrayContainer,[NSString stringWithFormat:@"NSArray arrayWithObjects invalid index object:%tu total:%tu",i,cnt]);
        }
    }
    return [self hookArrayWithObjects:objs count:index];
}

@end
