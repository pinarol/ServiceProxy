#import "PNRResponse.h"
#import "PNRPaymentRecord.h"

@interface PNRCreatePrePaymentRecordResponse : PNRResponse

@property (nonatomic, strong) PNRPaymentRecord *record;

@end
