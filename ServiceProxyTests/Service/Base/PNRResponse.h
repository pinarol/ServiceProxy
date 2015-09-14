#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>
#import "PNRModel.h"
#import "PNRErrorModel.h"
#import "PNRMeta.h"

/**
   Base for all network response classes
 */
@interface PNRResponse : PNRModel

/**
   Error object for this response
 */
@property (nonatomic, readonly, strong) PNRErrorModel *error;

/**
   Meta data for this response
 */
@property (nonatomic, readonly, strong) PNRMeta *meta;

/**
   Returns the contained message due to success state
 */
- (PNRMessage *)message;

@end
