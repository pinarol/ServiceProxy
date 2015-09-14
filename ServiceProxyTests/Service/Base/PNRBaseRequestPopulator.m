#import "PNRBaseRequestPopulator.h"

@implementation PNRBaseRequestPopulator

/**
   payload to be transported through service interceptors
 */
- (NSDictionary *)userParameters
{
    return [[NSDictionary alloc] init];
}

@end
