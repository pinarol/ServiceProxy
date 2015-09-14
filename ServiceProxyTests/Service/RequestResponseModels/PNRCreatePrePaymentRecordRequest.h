#import "PNRBaseRequestPopulator.h"
#import "PNRPaymentFieldValue.h"
#import "PNRRequestBody.h"

@interface PNRCreatePrePaymentRecordRequest : PNRRequestBody

@property (nonatomic, strong) NSArray<PNRPaymentFieldValue *> *values;
@property (nonatomic, strong) NSNumber *vendorId;

@end
