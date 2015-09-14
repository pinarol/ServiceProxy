#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>
#import "PNRModel.h"
#import "PNRMessage.h"

@interface PNRErrorModel : PNRModel
/**
   Error code determined in the service specs
   @note you shouldn't access this property directly. Use integerCode instead.
 */
@property (nonatomic, readonly, copy) NSString *code;

/**
 *  Error code corresponding integer value of code.
 */
@property (nonatomic, readonly, assign) NSInteger integerCode;

/**
   Message returned from service call
 */
@property (nonatomic, readonly, copy) PNRMessage *message;

@end
