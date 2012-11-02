
#import "SPLater.h"

@implementation SPLater
{
    SPKVO *_kvo;
    SPLaterTimeout _timeoutBlock;
    __strong id _self; // self retain during while not finished
}

+ (SPLater *)when:(id)object keyPath:(NSString *)keyPath changes:(SPLaterCallback)change initial:(BOOL)initial
{
    return [[[SPLater alloc] init] when:object keyPath:keyPath changes:change initial:initial];
}

- (SPLater *)when:(id)object keyPath:(NSString *)keyPath changes:(SPLaterCallback)change initial:(BOOL)initial
{
    _self = self;
    __weak __typeof(self) weakSelf = self;
    _kvo = [SPKVO observe:object keyPath:keyPath change:^(id oldValue, id newValue) {
        change(weakSelf, oldValue, newValue);
    } initial:initial];
    return self;
}

- (void)dealloc
{
    [self invalidate];
}

//call when finished, kvo will unregister
- (void)invalidate
{
    [_kvo invalidate];
    _timeoutBlock = nil;
    _kvo = nil;
    _self = nil;
}

- (void)doTimeout
{
    SPLaterTimeout block = _timeoutBlock;
    [self invalidate];
    if (block)
        block(self);
}

- (SPLater *)timeout:(SPLaterTimeout)timeoutBlock after:(NSTimeInterval)interval;
{
    _timeoutBlock = [timeoutBlock copy];
    [self performSelector:@selector(doTimeout) withObject:nil afterDelay:interval];
    return self;
}
@end
