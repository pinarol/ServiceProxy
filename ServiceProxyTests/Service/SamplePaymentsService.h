#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>
#import "PNRCreatePrePaymentRecordRequest.h"
#import "PNRCreatePrePaymentRecordResponse.h"

typedef void (^PNRCreatePrePaymentRecordRequestCompletion)(NSError *error, PNRCreatePrePaymentRecordResponse *response);

@interface SamplePaymentsService : PNRService

- (void)createPrePaymentRecordWithRequest:(PNRCreatePrePaymentRecordRequest *)request completion:(PNRCreatePrePaymentRecordRequestCompletion)completion;

@end
