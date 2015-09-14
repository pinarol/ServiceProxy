#import "PNRCreatePrePaymentRecordRequest.h"

@implementation PNRCreatePrePaymentRecordRequest

- (Class)valuesType
{
    return [PNRPaymentFieldValue class];
}

@end
