
#import "SPKVO.h"

#include <objc/runtime.h>
@interface SPKVOWithDebug : SPKVO
@end
@implementation SPKVOWithDebug
{
    NSString *_targetInfo;
}
- (id)observe:(id)object keyPath:(NSString *)keyPath change:(SPKVOChange)change initial:(BOOL)initial
{
    _targetInfo = [object debugDescription];
    return [super observe:object keyPath:keyPath change:change initial:initial];
}

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"<SPKVO: %lx Target:%@>", (long)self, _targetInfo];
}
@end

@implementation SPKVO
{
    __weak id _target;
    NSString *_keyPath;
    SPKVOChange _block;
    BOOL _once;
    BOOL _invalidated;
    
    __strong id _self; // self retain during once
}

+ (id)observe:(id)object keyPath:(NSString *)keyPath change:(SPKVOChange)change initial:(BOOL)initial
{
    Class selfClass = [SPKVOWithDebug class];
    SPKVO *me = [[selfClass alloc] init];
    [me observe:object keyPath:keyPath change:change initial:initial];
    return me;
}

- (id)observe:(id)object keyPath:(NSString *)keyPath change:(SPKVOChange)change initial:(BOOL)initial
{
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    if (initial)
        options |= NSKeyValueObservingOptionInitial;
    
    _target = object;
    _keyPath = [keyPath copy];
    _block = [change copy];
    
    [object addObserver:self forKeyPath:keyPath options:options context:0];
    return self;
}

- (id)once
{
    _once = YES;
    //we want someone to hold us
    _self = self;
    return self;
}

- (void)invalidate
{
    NSAssert(_target, @"Target was deallocated before the observer! %@", [self debugDescription]);
    [_target removeObserver:self forKeyPath:_keyPath];
    _target = nil;
    _block = nil;
    _invalidated = YES;
    _self = nil;
}

- (void)dealloc
{
    if (!_invalidated)
        [self invalidate];
}

- (BOOL)active
{
    return !_invalidated;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    id newValue = change[NSKeyValueChangeNewKey];
    id oldValue = change[NSKeyValueChangeOldKey];
    
    if (_block)
        _block(oldValue, newValue);
    
    if (_once)
        [self invalidate];
}

@end
