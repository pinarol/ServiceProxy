#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>
#import "PNRModel.h"
#import "PNRMessage.h"

/**
   PNRMeta defines response’s meta data. If the result data is an array, an integer called “count” is added into meta data. Pagination can be added if applicable.
 */
@interface PNRMeta : PNRModel

/**
   Success state of the network response.
   - Error is only shown when success is false.
   - Result is only shown when success is true and the underlying endpoint returns data. Some endpoints only return boolean responses
 */
@property (nonatomic, assign) BOOL success;

/**
   If this is true we need to logout because this parameter is true when server ended its session.
 */
@property (nonatomic, assign) BOOL logout;

/**
   Returns the element count when result data is an array. Needed only if there is a pagination.
 */
@property (nonatomic, assign) NSInteger count;

/**
 *  Message which contains title and subtitle, can be displayed as feedback
 */
@property (nonatomic, strong) PNRMessage *message;

@end
