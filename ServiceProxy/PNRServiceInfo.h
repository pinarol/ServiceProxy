#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PNRRequestMethod)
{
    PNRRequestMethodGET = 0,
    PNRRequestMethodPOST,
    PNRRequestMethodPUT,
    PNRRequestMethodDELETE,
    PNRRequestMethodPATCH,
    PNRRequestMethodHEAD,
    PNRRequestMethodOPTIONS,
    PNRRequestMethodTRACE
};

@interface PNRServiceInfo : NSObject

/**
 *  @return Created PNRServiceInfo object with given relative url and request method.
 */
+ (instancetype)serviceInfoWithUrl:(NSString *)url requestMethod:(PNRRequestMethod)requestMethod;

/**
 *  @return Initialized PNRServiceInfo object with given relative url and request method.
 */
- (instancetype)initWithUrl:(NSString *)url requestMethod:(PNRRequestMethod)requestMethod;

/**
 *  Service relative url.
 */
@property (strong, nonatomic) NSString *url;

/**
 *  HTTP request method.
 */
@property (assign, nonatomic) PNRRequestMethod requestMethod;

@end
