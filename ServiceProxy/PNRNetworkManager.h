//
//  PNRNetworkManager.h
//  ServiceProxy
//
//  Created by Pinar Olguc in 2015.
//

#import <Foundation/Foundation.h>
#import <PNRServiceInfo.h>

typedef void(^PNRRequestCompletion)(NSError *error, id data);

@protocol PNRNetworkManager <NSObject>

/// Make a request.
/// - Parameters:
///   - URLString: String representation of full URL including query parameters and encoded.
///   - method: HTTP method.
///   - body: HTTP body.
///   - completion: The completion handler to call after the request finishes.
- (NSString *)requestWithURLString:(NSString *)URLString
                            method:(PNRRequestMethod)method
                          httpBody:(NSDictionary *)body
                        completion:(PNRRequestCompletion)completion;

@end
