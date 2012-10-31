//
//  OnceTests.m
//  SPKVO
//
//  Created by Patrik Sjöberg on 31/10/12.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import "OnceTests.h"
#import "SPKVO.h"
#import "Dummies.h"

@implementation OnceTests
{
    Dummy *dummy;
}
- (void)setUp
{
    dummy = [Dummy new];
}

- (void)tearDown
{
    dummy = nil;
}


- (void)testFireOnce
{
    __weak SPKVO *weakObserver;
    __block int fired = 0;
    @autoreleasepool {
        @autoreleasepool {
            weakObserver = [[SPKVO observe:dummy keyPath:@"boolean" change:^(id oldValue, id newValue) {
                fired += 1;
            } initial:NO] once];
        }
        
        STAssertNotNil(weakObserver, @"should outlive autorelease until fired");
        dummy.boolean = YES;
    }
    STAssertEquals(fired, 1, @"Should have fired exactly once");
    STAssertNil(weakObserver, @"should have autoreleased itself after first trigger");
    dummy.boolean = NO;
    dummy.boolean = YES;
    dummy.boolean = NO;
    
    STAssertEquals(fired, 1, @"Should have fired exactly once");
}

@end
