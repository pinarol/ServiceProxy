//
//  PNRPropertyTestClass.m
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import "PNRPropertyTestClass.h"

@implementation PNRPropertyTestClass

- (Class)arrayPropertyType
{
    return [PNRSampleClass class];
}

- (Class)stringArrayPropertyType
{
    return [NSString class];
}

- (NSString *)strPropertyCustomNameDictionaryKey
{
    return @"STR_PROPERTY";
}

- (NSString *)dictionaryKeyNameOfPropertyName:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"doubleProperty"])
    {
        return @"goodDoubleProperty";
    }
    return propertyName;
}

@end
