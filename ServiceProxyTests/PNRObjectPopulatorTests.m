//
//  PNRObjectPopulatorTests.m
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import <XCTest/XCTest.h>
#import "PNRObjectPopulator.h"
#import "PNRPropertyTestClass.h"
#import "PNRSampleClassWithArray.h"
#import "PNRPropertyTestClassWithExcludedProperties.h"
#import "PNRPropertyTestInvalidClass.h"

@interface PNRObjectPopulatorTests : XCTestCase

@property (strong, nonatomic) PNRPropertyTestClass *sampleObject;

@end

@implementation PNRObjectPopulatorTests

- (void)setUp
{
    self.sampleObject = [PNRPropertyTestClass new];
    self.sampleObject.boolProperty = YES;
    self.sampleObject.integerProperty = 19;
    PNRSampleClass *newObj = [PNRSampleClass new];
    newObj.strProperty = @"str";
    self.sampleObject.sampleClassProperty = newObj;
    
    [super setUp];
}

- (void)testDictionaryRepresentationOfObject
{
    NSDictionary *dict = [PNRObjectPopulator pnr_dictionaryRepresentationOfObject:self.sampleObject];
    XCTAssertTrue([[dict valueForKey:@"boolProperty"] isEqualToNumber:@1]);
    XCTAssertTrue([[dict valueForKey:@"integerProperty"] isEqualToNumber:@19]);
    XCTAssertTrue([[dict valueForKey:@"sampleClassProperty"] isKindOfClass:[NSDictionary class]]);
    
    NSDictionary *dict2 = [dict valueForKey:@"sampleClassProperty"];
    XCTAssertTrue([[dict2 valueForKey:@"strProperty"] isEqualToString:@"str"]);
}

- (void)testPopulateWithDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@2 forKey:@"integerProperty"];
    [dict setObject:@"asd" forKey:@"stringProperty"];
    [dict setObject:@1 forKey:@"boolProperty"];
    [dict setObject:@(1.23) forKey:@"goodDoubleProperty"];
    
    NSMutableDictionary *dict2 = [NSMutableDictionary new];
    [dict2 setObject:@"qwe" forKey:@"strProperty"];
    
    [dict setObject:dict2 forKey:@"sampleClassProperty"];
    
    PNRPropertyTestClass *populatableObject = [PNRPropertyTestClass new];
    [PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict];
    
    XCTAssertTrue(populatableObject.integerProperty == 2);
    XCTAssertTrue([populatableObject.stringProperty isEqualToString:@"asd"]);
    XCTAssertTrue(populatableObject.boolProperty == YES);
    XCTAssertTrue([populatableObject.sampleClassProperty.strProperty isEqualToString:@"qwe"]);
    XCTAssertTrue(populatableObject.doubleProperty == 1.23);
}

- (void)testDictionaryRepresentationOfObjectCustomPropertyName
{
    PNRPropertyTestClass *sampleObject = [PNRPropertyTestClass new];
    sampleObject.strPropertyCustomName = @"str1";
    
    NSDictionary *dict = [PNRObjectPopulator pnr_dictionaryRepresentationOfObject:sampleObject];
    XCTAssertTrue([[dict valueForKey:@"STR_PROPERTY"] isEqualToString:@"str1"]);
}

- (void)testUrlParameterRepresentation
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    
    PNRPropertyTestClass *sampleObject = [PNRPropertyTestClass new];
    sampleObject.doubleProperty = 555555555555.55;
    sampleObject.floatProperty = 0.4;
    sampleObject.intProperty = -2;
    sampleObject.dateProperty = [dateFormatter dateFromString:@"2014-08-28T00:00:00.000+03:00"];
    
    NSString *urlParameter = [PNRObjectPopulator pnr_urlParameterRepresentationOfObject:sampleObject];
    XCTAssertTrue([urlParameter isEqualToString:@"boolProperty=false&uintegerProperty=0&dateProperty=2014-08-27T21%3A00%3A00.000%2B0000&integerProperty=0&intProperty=-2&goodDoubleProperty=555555555555.55&floatProperty=0.4"]);
}

- (void)testArrayProperty
{
    PNRSampleClass *arrayItem1 = [PNRSampleClass new];
    [arrayItem1 setStrProperty:@"str1"];
    
    PNRSampleClass *arrayItem2 = [PNRSampleClass new];
    [arrayItem2 setStrProperty:@"str2"];
    
    NSArray *arrayProperty = [NSArray arrayWithObjects:arrayItem1, arrayItem2, nil];
    
    [self.sampleObject setArrayProperty:arrayProperty];
    
    NSDictionary *dict = [PNRObjectPopulator pnr_dictionaryRepresentationOfObject:self.sampleObject];
    XCTAssertTrue([[dict valueForKey:@"arrayProperty"] isKindOfClass:[NSArray class]]);
    NSArray *arr = [dict valueForKey:@"arrayProperty"];
    NSDictionary *sample1 = [arr objectAtIndex:0];
    NSDictionary *sample2 = [arr objectAtIndex:1];
    XCTAssertTrue([[sample1 valueForKey:@"strProperty"] isEqualToString:@"str1"]);
    XCTAssertTrue([[sample2 valueForKey:@"strProperty"] isEqualToString:@"str2"]);
}

- (void)testArrayPropertyForPopulation
{
    NSMutableDictionary *dict1 = [NSMutableDictionary new];
    [dict1 setObject:@"strProperty1" forKey:@"strProperty"];
    
    NSMutableDictionary *dict2 = [NSMutableDictionary new];
    [dict2 setObject:@"strProperty2" forKey:@"strProperty"];
    
    NSArray *arrayProperty = [NSArray arrayWithObjects:dict1, dict2, nil];
    
    NSMutableDictionary *dict3 = [NSMutableDictionary new];
    [dict3 setObject:arrayProperty forKey:@"arrayProperty"];
    
    PNRPropertyTestClass *populatableObject = [PNRPropertyTestClass new];
    [PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict3];
    
    XCTAssertTrue([[populatableObject.arrayProperty objectAtIndex:0] isKindOfClass:[PNRSampleClass class]]);
    XCTAssertTrue([[populatableObject.arrayProperty objectAtIndex:1] isKindOfClass:[PNRSampleClass class]]);
    PNRSampleClass *item1 = [populatableObject.arrayProperty objectAtIndex:0];
    PNRSampleClass *item2 = [populatableObject.arrayProperty objectAtIndex:1];
    
    XCTAssertTrue([[item1 strProperty] isEqualToString:@"strProperty1"]);
    XCTAssertTrue([[item2 strProperty] isEqualToString:@"strProperty2"]);
}

- (void)testArrayPropertyOfNSString
{
    NSMutableDictionary *dict1 = [NSMutableDictionary new];
    NSArray *stringArr = [NSArray arrayWithObjects:@"labelVal1", @"labelVal2", nil];
    [dict1 setObject:stringArr forKey:@"labelValues"];
    PNRSampleClassWithArray *populatableObject = [PNRSampleClassWithArray new];
    [PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict1];
    XCTAssertTrue([populatableObject.labelValues[0] isEqualToString:@"labelVal1"]);
    XCTAssertTrue([populatableObject.labelValues[1] isEqualToString:@"labelVal2"]);
    
}

- (void)testExcludedProperties
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@YES forKey:@"boolProperty"];                       //will be excluded
    [dict setObject:@2 forKey:@"uintegerProperty"];                     //will be excluded
    [dict setObject:@"asd" forKey:@"stringProperty"];                   //will be excluded
    [dict setObject:@[[PNRSampleClass new]] forKey:@"arrayProperty"];   //won't be excluded
    
    PNRPropertyTestClassWithExcludedProperties *populatableObject = [PNRPropertyTestClassWithExcludedProperties new];
    [PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict];
    
    XCTAssertFalse(populatableObject.boolProperty == YES);
    XCTAssertFalse(populatableObject.uintegerProperty == 2);
    XCTAssertFalse([populatableObject.stringProperty isEqualToString:@"asd"]);
    XCTAssertTrue(populatableObject.arrayProperty.count == 1);
    XCTAssertTrue([[populatableObject.arrayProperty firstObject] isKindOfClass:[PNRSampleClass class]]);
    
    NSDictionary *dictionaryRepresentation = [PNRObjectPopulator pnr_dictionaryRepresentationOfObject:populatableObject];
    
    XCTAssertFalse([dictionaryRepresentation[@"boolProperty"] isEqual:@YES]);
    XCTAssertFalse([dictionaryRepresentation[@"uintegerProperty"] isEqual:@2]);
    XCTAssertFalse([dictionaryRepresentation[@"stringProperty"] isEqual:@"asd"]);
    XCTAssertTrue([dictionaryRepresentation[@"arrayProperty"] isKindOfClass:[NSArray class]]);
    NSArray *arrayProperty = dictionaryRepresentation[@"arrayProperty"];
    XCTAssertTrue(arrayProperty.count == 1);
    XCTAssertTrue([[arrayProperty firstObject] isKindOfClass:[NSDictionary class]]);
}

- (void)testDecimalField
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@YES forKey:@"boolProperty"];
    [dict setObject:@"2.66" forKey:@"decimalNumber"];
    PNRPropertyTestClass *populatableObject = [PNRPropertyTestClass new];
    [PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict];
    XCTAssertTrue([populatableObject.decimalNumber isEqualToNumber:@2.66]);
    NSDictionary *dictionaryRepresentation = [PNRObjectPopulator pnr_dictionaryRepresentationOfObject:populatableObject];
    XCTAssertTrue([dictionaryRepresentation[@"decimalNumber"] isEqualToNumber:@2.66]);
}

- (void)testIntegerField
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:@"2" forKey:@"uintegerProperty"];
    PNRPropertyTestClass *populatableObject = [PNRPropertyTestClass new];
    [PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict];
    XCTAssertTrue(populatableObject.uintegerProperty == 2);
}

- (void)testStringArrayPropertyPopulateObject
{
    NSArray *stringArray = @[@"this", @"is", @"array"];

    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:stringArray forKey:@"stringArrayProperty"];

    PNRPropertyTestClass *populatableObject = [PNRPropertyTestClass new];

    [PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict];
    
    XCTAssertTrue([populatableObject.stringArrayProperty[0] isEqualToString:@"this"]);
    XCTAssertTrue([populatableObject.stringArrayProperty[1] isEqualToString:@"is"]);
    XCTAssertTrue([populatableObject.stringArrayProperty[2] isEqualToString:@"array"]);
}
- (void)testStringArrayPropertyPopulateDictionary
{
    NSArray *stringArray = @[@"this", @"is",@"array"];

    PNRPropertyTestClass *populatableObject = [PNRPropertyTestClass new];
    populatableObject.stringArrayProperty = stringArray;

    NSDictionary *dict = [PNRObjectPopulator pnr_dictionaryRepresentationOfObject:populatableObject];
    
    XCTAssertTrue([[dict valueForKey:@"stringArrayProperty"][0] isEqualToString:@"this"]);
    XCTAssertTrue([[dict valueForKey:@"stringArrayProperty"][1] isEqualToString:@"is"]);
    XCTAssertTrue([[dict valueForKey:@"stringArrayProperty"][2] isEqualToString:@"array"]);
}

- (void)testInvalidClassPopulateDictionary
{
    NSArray *array = @[[NSDate new]];
    
    PNRPropertyTestInvalidClass *populatableObject = [PNRPropertyTestInvalidClass new];
    populatableObject.dateArrayProperty = array;
    
    XCTAssertThrows([PNRObjectPopulator pnr_dictionaryRepresentationOfObject:populatableObject]);
}

- (void)testInvalidClassPopulateObject
{
    NSArray *array = @[[NSDate new]];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:array forKey:@"dateArrayProperty"];
    
    PNRPropertyTestInvalidClass *populatableObject = [PNRPropertyTestInvalidClass new];
    XCTAssertThrows([PNRObjectPopulator pnr_populateObject:populatableObject withDictionary:dict]);
}
@end
