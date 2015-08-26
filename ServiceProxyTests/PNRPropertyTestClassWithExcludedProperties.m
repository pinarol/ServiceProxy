//
//  PNRPropertyTestClassWithExcludedProperties.m
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import "PNRPropertyTestClassWithExcludedProperties.h"

@implementation PNRPropertyTestClassWithExcludedProperties

- (NSArray *)excludedPropertyNames
{
    return @[@"boolProperty", @"stringProperty", @"uintegerProperty"];
}

@end
