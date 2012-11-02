
/*
 Most of docs in SPKVO.h applies here as well
 
 */
#import <Foundation/Foundation.h>
#import "SPKVO.h"


@class SPLater;
typedef void(^SPLaterCallback)(SPLater *later, id oldValue, id newValue);
typedef void(^SPLaterTimeout)(SPLater *later);

@interface SPLater : NSObject
+ (SPLater *)when:(id)object keyPath:(NSString *)keyPath changes:(SPLaterCallback)change initial:(BOOL)initial;
- (SPLater *)when:(id)object keyPath:(NSString *)keyPath changes:(SPLaterCallback)change initial:(BOOL)initial;

//call when finished, kvo will unregister
- (void)invalidate;

- (SPLater *)timeout:(SPLaterTimeout)timeoutBlock after:(NSTimeInterval)interval;
@end
