#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>
#import "PNRModel.h"

@interface PNRMessage : PNRModel

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, copy) NSString *extra;

@end
