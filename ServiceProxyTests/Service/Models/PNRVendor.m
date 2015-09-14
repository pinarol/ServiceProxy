#import "PNRVendor.h"

static NSString *const kFTPaymentComplexityKeySimple = @"SIMPLE";
static NSString *const kFTPaymentComplexityKeyComplex = @"COMPLEX";

@implementation PNRVendor

- (PNRPaymentComplexity)complexityEnum
{
    if ([self.complexity isEqualToString:kFTPaymentComplexityKeySimple])
    {
        return PNRPaymentComplexitySimple;
    }
    else if ([self.complexity isEqualToString:kFTPaymentComplexityKeyComplex])
    {
        return PNRPaymentComplexityComplex;
    }
    return PNRPaymentComplexityNone;
}

@end
