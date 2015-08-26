//
//  PNRPropertyTestInvalidClass.h
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import "PNRPropertyTestClass.h"

@interface PNRPropertyTestInvalidClass : PNRPropertyTestClass

@property (strong, nonatomic) NSArray *dateArrayProperty;

- (Class)dateArrayPropertyType;

@end
