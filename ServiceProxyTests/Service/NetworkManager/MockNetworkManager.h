#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockNetworkManager : NSObject <PNRNetworkManager>

@property (nonatomic, copy) NSString *mockName;

@property (nonatomic, strong) NSDictionary *inputBody;
@property (nonatomic, strong) NSString *inputURLString;

- (instancetype)initWithMockName:(NSString *)mockName;

@end

NS_ASSUME_NONNULL_END
