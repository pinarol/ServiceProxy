#import <Foundation/Foundation.h>
#import "SamplePaymentsService.h"

static NSString *const kFTPreCreatePaymentRecordEndpoint = @"payment/pre-record";

@implementation SamplePaymentsService

- (PNRServiceInfo *)serviceInfoForSelector:(SEL)selector
{
    if (selector == @selector(createPrePaymentRecordWithRequest:completion:))
    {
        return [[PNRServiceInfo alloc] initWithUrl:kFTPreCreatePaymentRecordEndpoint requestMethod:PNRRequestMethodPOST];
    }
    return nil;
}

- (void)createPrePaymentRecordWithRequest:(PNRCreatePrePaymentRecordRequest *)request completion:(__strong PNRCreatePrePaymentRecordRequestCompletion)completion {
}

@end
