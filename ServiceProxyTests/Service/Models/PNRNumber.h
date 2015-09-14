#import "PNRModel.h"

@interface PNRNumber : PNRModel

@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, copy) NSString *formattedAmount;

@end
