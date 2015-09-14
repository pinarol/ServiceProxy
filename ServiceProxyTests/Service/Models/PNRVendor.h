#import "PNRModel.h"

typedef NS_ENUM(NSUInteger, PNRPaymentComplexity)
{
    PNRPaymentComplexityNone,
    PNRPaymentComplexitySimple,
    PNRPaymentComplexityComplex
};

@interface PNRVendor : PNRModel

@property (nonatomic, strong) NSNumber *vendorId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *complexity;

- (PNRPaymentComplexity)complexityEnum;

@end
