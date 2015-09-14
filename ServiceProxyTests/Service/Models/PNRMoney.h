#import "PNRModel.h"
#import "PNRNumber.h"

@interface PNRMoney : PNRNumber

/**
   Amount formatted with currency according to locale
 */
@property (nonatomic, copy) NSString *formattedAmountWithCurrency;

/**
   Currency
 */
@property (nonatomic, copy) NSString *currency;

@end
