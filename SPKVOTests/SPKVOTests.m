//
//  SPKVOTests.m
//  SPKVOTests
//
//  Created by Patrik Sjöberg on 31/10/12.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import "SPKVOTests.h"
#import "SPKVO.h"
#import "Dummies.h"

@implementation SPKVOTests
{
    Dummy *dummy;
    SPKVO *observation;
}
- (void)setUp
{
    [super setUp];
    dummy = [Dummy new];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    observation = nil;
    dummy = nil;
    [super tearDown];
}

- (void)testAutodestruct
{
    @autoreleasepool {
        [SPKVO observe:dummy keyPath:@"boolean" change:^(id oldValue, id newValue) {
            STAssertTrue(NO, @"KVO should have been teared down");
        } initial:NO];
    }
    dummy.boolean = YES;
}

- (void)testTriggering
{
    __block BOOL trigged = NO;
    @autoreleasepool {
        observation = [SPKVO observe:dummy keyPath:@"boolean" change:^(id oldValue, id newValue) {
            trigged = YES;
        } initial:NO];
    }
    dummy.boolean = YES;
    STAssertTrue(trigged, @"kvo should have trigged");
}

- (void)testDereferencingDestructs
{
    __block BOOL trigged = NO;
    @autoreleasepool {
        observation = [SPKVO observe:dummy keyPath:@"boolean" change:^(id oldValue, id newValue) {
            trigged = YES;
        } initial:NO];
    }
    
    @autoreleasepool {
        observation = nil;
    }
    dummy.boolean = YES;
    STAssertFalse(trigged, @"kvo should not have trigged");
}

- (void)testInitial
{
    __block BOOL trigged = NO;
    @autoreleasepool {
        [SPKVO observe:dummy keyPath:@"boolean" change:^(id oldValue, id newValue) {
            trigged = YES;
        } initial:YES];
    }
    STAssertTrue(trigged, @"kvo should have trigged");
}

- (void)testValuesString
{
    NSString *stringBefore = @"hello world";
    NSString *stringAfter = @"goodbye space";
    
    __block id before = nil;
    __block id after = nil;
    
    dummy.string = stringBefore;
    @autoreleasepool {
        observation = [SPKVO observe:dummy keyPath:@"string" change:^(id oldValue, id newValue) {
            before = oldValue;
            after = newValue;
        } initial:NO];
    }
    dummy.string = stringAfter;
    STAssertEqualObjects(before, stringBefore, @"the before stirng and oldValue should match");
    STAssertEqualObjects(after, stringAfter, @"the after stirng and newValue should match");
}

- (void)testValuesBoolean
{
    BOOL boolBefore = YES;
    BOOL boolAfter = NO;
    
    __block id before = nil;
    __block id after = nil;
    
    dummy.boolean = boolBefore;
    @autoreleasepool {
        observation = [SPKVO observe:dummy keyPath:@"boolean" change:^(id oldValue, id newValue) {
            before = oldValue;
            after = newValue;
        } initial:NO];
    }
    dummy.boolean = boolAfter;
    STAssertEquals([before boolValue], boolBefore, @"the before bool and oldValue should match");
    STAssertEquals([after boolValue], boolAfter, @"the after bool and newValue should match");
}


@end
