//
//  NSObject+SwizzleHook.h
//  JJException
//
//  Created by Jezz on 2018/7/10.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * JJSwizzledIMPBlock assist variable
 */

typedef void (*JJSwizzleOriginalIMP)(void /* id, SEL, ... */ );

@interface JJSwizzleObject : NSObject

- (JJSwizzleOriginalIMP)getOriginalImplementation;

@property (nonatomic,readonly,assign) SEL selector;

@end

typedef id (^JJSwizzledIMPBlock)(JJSwizzleObject* swizzleInfo);

/*
 * JJSwizzledIMPBlock assist variable
 */


/**
 * Swizzle Class Method

 @param cls Class
 @param originSelector originSelector
 @param swizzleSelector swizzleSelector
 */
void swizzleClassMethod(Class cls, SEL originSelector, SEL swizzleSelector);

/**
 * Swizzle Instance Class Method

 @param cls Class
 @param originSelector originSelector
 @param swizzleSelector swizzleSelector
 */
void swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector);

/**
 * Only swizzle the current class,not swizzle all class
 * perform jj_cleanKVO selector before the origin dealloc

 @param class Class
 */
void jj_swizzleDeallocIfNeeded(Class class);

/**
 Swizzle the NSObject Extension
 */
@interface NSObject (SwizzleHook)

/**
 Swizzle Class Method

 @param originSelector originSelector
 @param swizzleSelector swizzleSelector
 */
+ (void)jj_swizzleClassMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector;

/**
 Swizzle Instance Method

 @param originSelector originSelector
 @param swizzleSelector swizzleSelector
 */
- (void)jj_swizzleInstanceMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector;

/**
 Swizzle instance method to the block target

 @param originSelector originSelector
 @param swizzledBlock block
 */
- (void)jj_swizzleInstanceMethod:(SEL)originSelector withSwizzledBlock:(JJSwizzledIMPBlock)swizzledBlock;

@end
