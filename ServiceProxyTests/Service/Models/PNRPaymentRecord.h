#import "PNRModel.h"
#import "PNRVendor.h"
#import "PNRMoney.h"

@interface PNRPaymentRecord : PNRModel

@property (nonatomic, strong) NSNumber *recordId;
@property (nonatomic, strong) PNRVendor *vendor;
@property (nonatomic, strong) NSString *recordDescription;
@property (nonatomic, strong) NSString *paymentAmountLabel;
@property (nonatomic, strong) PNRMoney *paymentAmount;

@end
