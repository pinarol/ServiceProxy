#import <Foundation/Foundation.h>

@class PNRServiceInfo;

/**
 *  This class is to be subclassed by service caller classes.
 */
@interface PNRService : NSObject

/**
 *  Override this class to provide info corresponding to the given service method.
 */
- (PNRServiceInfo *)serviceInfoForSelector:(SEL)selector;

@end
