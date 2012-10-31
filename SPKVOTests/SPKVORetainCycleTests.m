//
//  SPKVORetainCycleTests.m
//  SPKVO
//
//  Created by Patrik Sjöberg on 31/10/12.
//  Copyright (c) 2012 Spotify. All rights reserved.
//

#import "SPKVORetainCycleTests.h"
#import "Dummies.h"
#import "SPKVO.h"


@interface RetainCycleDummy : Dummy
@property (nonatomic, readonly) BOOL fired;
@property (nonatomic, weak) SPKVO *observation;
- (void)run;
@end


@implementation RetainCycleDummy
- (void)run
{
    __weak __typeof(self) weakSelf = self;
    self.observation = [SPKVO observe:self keyPath:@"boolean" change:^(id oldValue, id newValue) {
        _fired = YES;
        weakSelf.integer += 1;
    } initial:NO];
    self.boolean = YES;
}
@end


@implementation SPKVORetainCycleTests
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

- (void)testRetainCycle
{
    __weak RetainCycleDummy *weakDummy = nil;
    __weak SPKVO *weakKVO = nil;
    @autoreleasepool {
        RetainCycleDummy *retainDummy = [RetainCycleDummy new];
        @autoreleasepool {
            weakDummy = retainDummy;
            weakKVO = weakDummy.observation;
            [retainDummy run];
            STAssertTrue(retainDummy.fired, @"should have fired");
        }
        retainDummy = nil;
    }
    STAssertNil(weakKVO, @"kvo should be released now");
    STAssertNil(weakDummy, @"dummy should be released now");
}

- (void)testDoubleRetain
{
    __weak SPKVO *weakObservation = nil;
    __block BOOL fired = NO;
    @autoreleasepool {
        __block SPKVO *observation = [SPKVO observe:dummy keyPath:@"boolean" change:^(id oldValue, id newValue) {
            NSLog(@"observation fired: %@", observation);
            fired = YES;
        } initial:NO];
        weakObservation = observation;
        dummy.boolean = YES;
        observation = nil;
    }
    STAssertNil(weakObservation, @"should be gone now");
    STAssertTrue(fired, @"should fire");
}

//- (void)testAutoreleasedShouldNotCauseTrouble
//{
//    Dummy *dummyWithLingeringKVO = [Dummy new];
//    [SPKVO observe:dummyWithLingeringKVO keyPath:@"boolean" change:^(id oldValue, id newValue) {} initial:NO];
//    dummyWithLingeringKVO = nil;
//    //TODO:Assert that this NSAsserts
//}

@end
