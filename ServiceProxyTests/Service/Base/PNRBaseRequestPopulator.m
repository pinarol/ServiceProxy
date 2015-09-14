//
//  PNRBaseRequestPopulator.m
//  Forte
//
//  Created by Pinar Olguc on 27/11/2015.
//  Copyright (c) 2003-2015 Monitise Group Limited. All rights reserved.
//
//  Save to the extent permitted by law, you may not use, copy, modify,
//  distribute or create derivative works of this material or any part
//  of it without the prior written consent of Monitise Group Limited.
//  Any reproduction of this material must contain this notice.
//

#import "PNRBaseRequestPopulator.h"

@implementation PNRBaseRequestPopulator

/**
   payload to be transported through service interceptors
 */
- (NSDictionary *)userParameters
{
    return [[NSDictionary alloc] init];
}

@end
