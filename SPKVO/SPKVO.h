
/*
 
 Simple to use KVO wrapper
 
 Usage:
 id observation = [SPKVO observe:object keyPath:@"value" change:^(id oldValue, id newValue){} initial:NO];
 
 Memory management - ARC:
    The observation holds a weak reference to target, which means the observation will 
    notice if target deallocs before the observation and throw an assert.
 
    Hold a strong reference to the observation for as long as you need it.
    Hold a weak reference if you reference the holder in the block (retain cycle)
 
 Retian cycles:
    Use a weak ivar reference to the observation
    @property (nonatomic, weak) SPKVO *observation;
 
    Use a weak reference to self in the block
    __weak __typeof(self) weakSelf = self;
    _observation = [SPKVO observe:object keyPath:@"value" change:^(id oldValue, id newValue){
        [self something];
    } initial:NO]
 
 Once:
    [[SPKVO observe:object keyPath:@"value" change:^(id oldValue, id newValue){} initial:NO] once];
    The observation will only fire once, then disappear.
    It will hold a strong reference to itself until receiving the OKV or invalidated.
    Does not make sense to use if initial is used.
 
 */


#import <Foundation/Foundation.h>

typedef void(^SPKVOChange)(id oldValue, id newValue);

@interface SPKVO : NSObject
@property (nonatomic, readonly) BOOL active;

+ (SPKVO *)observe:(id)object keyPath:(NSString *)keyPath change:(SPKVOChange)change initial:(BOOL)initial;
- (id)observe:(id)object keyPath:(NSString *)keyPath change:(SPKVOChange)change initial:(BOOL)initial;

- (id)once;
@end
