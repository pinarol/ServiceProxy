#import "PNRServiceInfo.h"

@implementation PNRServiceInfo

+ (instancetype)serviceInfoWithUrl:(NSString *)url requestMethod:(PNRRequestMethod)requestMethod
{
    return [[PNRServiceInfo alloc] initWithUrl:url requestMethod:requestMethod];
}

- (instancetype)initWithUrl:(NSString *)url requestMethod:(PNRRequestMethod)requestMethod
{
    self = [super init];
    
    if (self)
    {
        _url = url;
        _requestMethod = requestMethod;
    }
    
    return self;
}

@end
