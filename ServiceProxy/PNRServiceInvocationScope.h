#import <Foundation/Foundation.h>

/**
 *  This class contains variables that needs to be passed through the same service invocation instance(in other words same request).
 */
@interface PNRServiceInvocationScope : NSObject

/**
 *  Unique identifier representing this invocation.
 */
@property (strong, nonatomic, readonly) NSString *identifier;

/**
 *  User defined parameters.
 */
@property (strong, nonatomic) NSMutableDictionary *userParameters;

@end
