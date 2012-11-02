
#import "LaterTests.h"
#import "Dummies.h"
#import "SPLater.h"

@implementation LaterTests
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

- (void)testLater
{
    __block int fired = 0;
    @autoreleasepool {
        [SPLater when:dummy keyPath:@"boolean" changes:^(SPLater *later, id oldValue, id newValue) {
            [later invalidate];
            fired += 1;
        } initial:NO];
    }
    dummy.boolean = YES;
    dummy.boolean = NO;
    dummy.boolean = YES;
    STAssertEquals(fired, 1, @"Should have fired exactly once");
}

- (void)testTimeoutFires
{
    __block int fired = 0;
    __block int timedOut = 0;
    @autoreleasepool {
        [[SPLater when:dummy keyPath:@"boolean" changes:^(SPLater *later, id oldValue, id newValue) {
            fired += 1;
            [later invalidate];
        } initial:NO] timeout:^(SPLater *later) {
            timedOut += 1;
        } after:0];
    }
    //let timers fire
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    STAssertEquals(fired, 0, @"should not have fired");
    STAssertEquals(timedOut, 1, @"should have timed out");
}

- (void)testTimeoutDoesNotFire
{
    __block int fired = 0;
    __block int timedOut = 0;
    @autoreleasepool {
        [[SPLater when:dummy keyPath:@"boolean" changes:^(SPLater *later, id oldValue, id newValue) {
            fired += 1;
            [later invalidate];
        } initial:NO] timeout:^(SPLater *later) {
            timedOut += 1;
        } after:0];
    }
    dummy.boolean = YES;
    //let timers fire
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    STAssertEquals(fired, 1, @"should not have fired");
    STAssertEquals(timedOut, 0, @"should have timed out");
}


@end
