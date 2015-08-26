//
//  PNRPropertyTestClass.h
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import <Foundation/Foundation.h>
#import "PNRSampleClass.h"
#import "PNRSampleSuperClass.h"

@interface PNRPropertyTestClass : PNRSampleClass

@property (assign, nonatomic) BOOL boolProperty;
@property (strong, nonatomic) NSString *stringProperty;
@property (assign, nonatomic) NSUInteger uintegerProperty;
@property (assign, nonatomic) NSDate *dateProperty;
@property (assign, nonatomic) NSInteger integerProperty;
@property (assign, nonatomic) int intProperty;
@property (assign, nonatomic) double doubleProperty;
@property (assign, nonatomic) float floatProperty;
@property (strong, nonatomic) PNRSampleSuperClass *sampleSuperClassProperty;
@property (strong, nonatomic) PNRSampleClass *sampleClassProperty;
@property (strong, nonatomic) NSArray *arrayProperty;
@property (strong, nonatomic) NSDecimalNumber *decimalNumber;
@property (strong, nonatomic) NSArray *stringArrayProperty;

@property (assign, nonatomic) NSString *strPropertyCustomName;

- (Class)arrayPropertyType;
- (Class)stringArrayPropertyType;
- (NSString *)strPropertyCustomNameDictionaryKey;

@end
