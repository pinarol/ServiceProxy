//
//  PNRSamplaClassWithArray.h
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import "PNRObjectPopulator.h"

@interface PNRSampleClassWithArray : NSObject <PNRPopulatable>

/// Array of NSString
@property (strong, nonatomic) NSArray *labelValues;

@end
