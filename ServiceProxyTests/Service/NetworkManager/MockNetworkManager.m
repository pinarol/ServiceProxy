#import "MockNetworkManager.h"
#import "JSONParser.h"
@implementation MockNetworkManager

- (instancetype)initWithMockName:(NSString *)mockName {
    self = [super init];
    
    if (self)
    {
        _mockName = mockName;
    }
    
    return self;
}

- (NSString *)requestWithURLString:(NSString *)URLString
                            method:(PNRRequestMethod)method
                          httpBody:(NSDictionary *)body
                        completion:(PNRRequestCompletion)completion {
    self.inputBody = body;
    self.inputURLString = URLString;
    NSDictionary *dict = [JSONParser dictFromJSONFile:self.mockName];
    completion(nil, dict);
    return @"taskID";
}

@end
