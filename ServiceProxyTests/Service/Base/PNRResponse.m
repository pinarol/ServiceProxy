#import "PNRResponse.h"

@implementation PNRResponse

- (PNRMessage *)message
{
    return self.meta.success ? self.meta.message : self.error.message;
}

@end
