#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>
#import "PNRModel.h"
#import "PNRBaseRequestPopulator.h"

/**
   To be extended by request models which only consists of the request body
 */
@interface PNRRequestBody : PNRBaseRequestPopulator

@end
