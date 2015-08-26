//
//  PNRPropertyInspectorTests.m
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import <XCTest/XCTest.h>
#import "NSObject+PNRPropertyInspector.h"
#import "PNRSampleClass.h"
#import "PNRPropertyTestClass.h"

@interface PNRPropertyInspectorTests : XCTestCase

@property (strong, nonatomic) PNRPropertyTestClass *sampleObject;

@end

@implementation PNRPropertyInspectorTests

- (void)setUp
{
    [super setUp];
    self.sampleObject = [PNRPropertyTestClass new];
    
    // Put setup code here; it will be run once, before the first test case.
}

- (void)testAllPropertyNames
{
    NSArray *names = [self.sampleObject pnr_allPropertyNames];
    
    XCTAssertTrue([names count] == 15);
    XCTAssertTrue([names containsObject:@"boolProperty"]);
    XCTAssertTrue([names containsObject:@"dateProperty"]);
    XCTAssertTrue([names containsObject:@"stringProperty"]);
    XCTAssertTrue([names containsObject:@"strProperty"]);
    XCTAssertTrue([names containsObject:@"uintegerProperty"]);
    XCTAssertTrue([names containsObject:@"integerProperty"]);
    XCTAssertTrue([names containsObject:@"intProperty"]);
    XCTAssertTrue([names containsObject:@"doubleProperty"]);
    XCTAssertTrue([names containsObject:@"floatProperty"]);
    XCTAssertTrue([names containsObject:@"sampleSuperClassProperty"]);
    XCTAssertTrue([names containsObject:@"sampleClassProperty"]);
    
}

- (void)testClassNameOfPropertyWithName
{
    NSString *propertyName = [self.sampleObject pnr_classNameOfPropertyWithName:@"boolProperty"];
    XCTAssertTrue(!propertyName);//because this is not a class type
    propertyName = [self.sampleObject pnr_classNameOfPropertyWithName:@"sampleSuperClassProperty"];
    XCTAssertTrue([propertyName isEqualToString:NSStringFromClass([PNRSampleSuperClass class])]);
    Class classType = [self.sampleObject pnr_classTypeOfPropertyWithName:@"sampleSuperClassProperty"];
    XCTAssertTrue(classType == [PNRSampleSuperClass class]);
}

- (void)testIteratePropertiesWithBlock
{
    NSMutableArray *array = [NSMutableArray new];
    [self.sampleObject pnr_iteratePropertiesWithBlock:^(NSString *propertyName) {
        [array addObject:propertyName];
    }];
    XCTAssertTrue([array count] == 14);
}

- (void)testTypeCheckMethods
{
    XCTAssertFalse([self.sampleObject pnr_isPropertyIntegerWithName:@"uintegerProperty"]);
    XCTAssertTrue([self.sampleObject pnr_isPropertyIntegerWithName:@"integerProperty"]);
    XCTAssertTrue([self.sampleObject pnr_isPropertyIntegerWithName:@"intProperty"]);
    
    XCTAssertFalse([self.sampleObject pnr_isPropertyBoolWithName:@"uintegerProperty"]);
    XCTAssertTrue([self.sampleObject pnr_isPropertyBoolWithName:@"boolProperty"]);
    
    XCTAssertFalse([self.sampleObject pnr_isPropertyCGFloatWithName:@"uintegerProperty"]);
    
    XCTAssertFalse([self.sampleObject pnr_isPropertyDoubleWithName:@"floatProperty"]);
    XCTAssertTrue([self.sampleObject pnr_isPropertyDoubleWithName:@"doubleProperty"]);
    
    XCTAssertFalse([self.sampleObject pnr_isPropertyFloatWithName:@"uintegerProperty"]);
    XCTAssertTrue([self.sampleObject pnr_isPropertyFloatWithName:@"floatProperty"]);
    
    XCTAssertFalse([self.sampleObject pnr_isPropertyUnsignedIntegerWithName:@"integerProperty"]);
    XCTAssertTrue([self.sampleObject pnr_isPropertyUnsignedIntegerWithName:@"uintegerProperty"]);
    
    XCTAssertTrue([self.sampleObject pnr_propertyWithName:@"sampleClassProperty" isExactTypeOfClass:[PNRSampleClass class]]);
    XCTAssertFalse([self.sampleObject pnr_propertyWithName:@"sampleClassProperty" isExactTypeOfClass:[PNRSampleSuperClass class]]);
    
    XCTAssertTrue([self.sampleObject pnr_propertyWithName:@"sampleClassProperty" isKindOfClass:[PNRSampleClass class]]);
    XCTAssertTrue([self.sampleObject pnr_propertyWithName:@"sampleClassProperty" isKindOfClass:[PNRSampleSuperClass class]]);
    
    XCTAssertFalse([[self.sampleObject class] pnr_isPropertyIntegerWithName:@"uintegerProperty"]);
    XCTAssertTrue([[self.sampleObject class] pnr_isPropertyIntegerWithName:@"integerProperty"]);
}

@end
