//
//  PNRVendor.m
//  Forte
//
//  Created by Pinar Olguc on 16/02/2016.
//  Copyright (c) 2003-2016 Monitise Group Limited. All rights reserved.
//
//  Save to the extent permitted by law, you may not use, copy, modify,
//  distribute or create derivative works of this material or any part
//  of it without the prior written consent of Monitise Group Limited.
//  Any reproduction of this material must contain this notice.
//

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
