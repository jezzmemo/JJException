//
//  JJExceptionTests.m
//  JJExceptionTests
//
//  Created by Jezz on 2018/7/12.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface JJExceptionTests : XCTestCase

@end

@implementation JJExceptionTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testUnrecognizedSelector {
    [self performSelectorOnMainThread:@selector(tearDown1) withObject:nil waitUntilDone:NO];
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

@end
