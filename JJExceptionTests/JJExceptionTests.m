//
//  JJExceptionTests.m
//  JJExceptionTests
//
//  Created by Jezz on 2018/7/12.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JJException.h"

@interface TestZombie : NSObject

- (void)test;

@end

@implementation TestZombie

- (void)test{
    
}

@end

@interface JJExceptionTests : XCTestCase

@end

@implementation JJExceptionTests

- (void)setUp {
    [super setUp];
    JJException.exceptionWhenTerminate = NO;
    
    [JJException configExceptionCategory:JJExceptionGuardAll];
    [JJException startGuardException];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUnrecognizedSelector {
    [self performSelectorOnMainThread:@selector(tearDown1) withObject:nil waitUntilDone:NO];
}

- (void)testNull{
    NSNull* null = [NSNull null];
    NSString* str = (NSString*)null;
    NSAssert([str uppercaseString] == nil, @"NSNull is nil");
}

- (void)testArrayException{
    NSArray* testArray = @[@"1"];
    
    NSAssert([testArray[0] isEqualToString:@"1"], @"Get valid index object");
    NSAssert([[testArray objectAtIndex:0] isEqualToString:@"1"], @"Get valid index object");
    
    NSAssert(testArray[2] == nil, @"Check invalid index crash");
    NSAssert([testArray objectAtIndex:2] == nil, @"Check invalid index crash");
    
    NSAssert([NSArray arrayWithObject:nil] == nil, @"Check arrayWithObject nil object");
}

- (void)testMutableArrayException{
    NSMutableArray* mutableArray = [NSMutableArray arrayWithObject:@"1"];
    
    NSAssert([mutableArray objectAtIndex:2] == nil, @"Check invalid index crash");
    NSAssert(mutableArray[2] == nil, @"Check invalid index crash");
}

- (void)testDictionaryException{
    id object = nil;
    NSDictionary* testDic = @{@"key":@"value",@"key2":object};
    NSAssert([testDic count] == 1, @"Real only one key and object");
    
    NSDictionary* testDic1 = [NSDictionary dictionaryWithObject:object forKey:@"key"];
    NSAssert([testDic1 count] == 0, @"Only valid key and object");
}

- (void)testMutableDictionaryException{
    
    NSMutableDictionary* testDic = [NSMutableDictionary dictionary];
    
    id object = nil;
    [testDic setObject:object forKey:@"key"];
    
    NSString* key = nil;
    [testDic removeObjectForKey:key];
}

- (void)testZombieException{
//    [JJException addZombieObjectArray:@[TestZombie.class]];
//    
//    TestZombie* test = [TestZombie new];
//    [test release];
//    [test test];
//    
//    free(test);
    
}

- (void)testImmutableString{
    NSAssert([NSString stringWithUTF8String:NULL] == nil,@"Check parameter nil");
    NSAssert([NSString stringWithCString:NULL encoding:NSUTF8StringEncoding] == nil,@"Check parameter nil");
    
    NSString* empty = @"";//__NSCFConstantString
    [empty substringFromIndex:10];
    [empty substringToIndex:10];
    [empty substringWithRange:NSMakeRange(100, 1000)];
    [empty rangeOfString:@"11" options:NSCaseInsensitiveSearch range:NSMakeRange(10, 100) locale:[NSLocale new]];
    
    NSString* taggedPointerString = @"a";
    NSString* taggedPointerStringB = [[taggedPointerString mutableCopy] copy];//NSTaggedPointerString
    
    [taggedPointerStringB substringFromIndex:10];
    [taggedPointerStringB substringToIndex:10];
    [taggedPointerStringB substringWithRange:NSMakeRange(100, 1000)];
    [taggedPointerStringB rangeOfString:@"11" options:NSCaseInsensitiveSearch range:NSMakeRange(10, 100) locale:[NSLocale new]];
    
    NSString* test = nil;
    [NSString stringWithString:test];//NSPlaceholderString
}

- (void)testMutableString{
    
    NSMutableString* normalMutableString = [NSMutableString new];
    NSString* nilString = nil;
    
    [normalMutableString appendString:nilString];
    [normalMutableString insertString:@"test" atIndex:1000];
    [normalMutableString deleteCharactersInRange:NSMakeRange(100, 1000)];
    [normalMutableString substringFromIndex:100];
    [normalMutableString substringToIndex:1000];
    [normalMutableString substringWithRange:NSMakeRange(100, 1000)];
}


- (void)testAttributeString{
    NSString* nilString = nil;
    
    NSAttributedString* attribute = [[NSAttributedString alloc] initWithString:nilString];
    
    NSAttributedString* noramlAttribute = [[NSAttributedString alloc] initWithString:@"1"];
    [noramlAttribute attributedSubstringFromRange:NSMakeRange(100, 1000)];
    NSRange point = NSMakeRange(100, 1000);
    [noramlAttribute attribute:@"test" atIndex:100 effectiveRange:&point];
    
    [noramlAttribute enumerateAttribute:@"test" inRange:NSMakeRange(100, 1001) options:NSAttributedStringEnumerationReverse usingBlock:nil];
    [noramlAttribute enumerateAttributesInRange:NSMakeRange(0, 1000) options:NSAttributedStringEnumerationReverse usingBlock:nil];
}

- (void)testNSMutableAttributedString{
    NSString* nilString = nil;
    NSDictionary* nilDic = nil;
    NSMutableAttributedString* attribute = [[NSMutableAttributedString alloc] initWithString:nilString];
    
    NSMutableAttributedString* attribute1 = [[NSMutableAttributedString alloc] initWithString:nilString attributes:nilDic];
    
    NSMutableAttributedString* attribute2 = [[NSMutableAttributedString alloc] initWithString:@""];
    [attribute2 addAttribute:NSFontAttributeName value:nilString range:NSMakeRange(0, 1000)];
    [attribute2 addAttributes:nilDic range:NSMakeRange(1000, 100000)];
    [attribute2 addAttributes:nilDic range:NSMakeRange(1000, 0)];
    
    [attribute2 setAttributes:nilDic range:NSMakeRange(100, 100)];
    [attribute2 setAttributes:nilDic range:NSMakeRange(100, 0)];
    [attribute2 setAttributes:@{} range:NSMakeRange(100, 100)];
}

- (void)testJJExceptionPerformance{
    [self measureBlock:^{
        NSArray* array = @[@"112",@"12",@"12",@"12",@"12",@"12",@"12",@"12",@"12",@"12"];
        for (int i = 0;i < 1000000;i++) {
            id object = [array objectAtIndex:1];
        }
    }];
}

@end
