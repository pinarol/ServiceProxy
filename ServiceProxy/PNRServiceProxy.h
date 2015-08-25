#import <Foundation/Foundation.h>
#import "PNRServiceInvocationScope.h"

/**
 *  @note This is a private header
 */

@protocol PNRRequestPopulator;
@protocol PNRServiceConfiguration;
@protocol PNRNetworkManager;
@protocol PNRPopulatable;

/**
 *  Protocol that is implemented by a class who needs to be informed before&after service calls.
 */
@protocol PNRServiceCallInformer <NSObject>

/**
 *  This is called before the network request.
 *
 *  @return YES if we want service call to happen, false otherwise.
 */
- (BOOL)shouldProceedToService:(NSString *)serviceName method:(SEL)selector inputData:(id<PNRRequestPopulator>)request serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope;

/**
 *  This is called after the network request but before execution of completion blocks.
 *
 *  @return YES if there is no error, NO otherwise.
 */
- (BOOL)informAfterServiceBeforeCompletion:(NSString *)serviceName method:(SEL)selector responseData:(id<PNRPopulatable>)response error:(NSError**)error serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope;

/**
 *  This is called after the network request and execution of completion blocks.
 */
- (void)informAfterService:(NSString *)serviceName method:(SEL)selector responseData:(id<PNRPopulatable>)response error:(NSError *)error serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope;

@end

@class PNRService;

@interface PNRServiceProxy : NSObject

/**
 *  @param object Proxied object.
 *  @param serviceConfiguration Service configuration object to provide url & http header data info.
 *  @param serviceCallInformer Object who needs to be informed before&after service calls.
 */
- (instancetype)initWithObject:(PNRService *)object serviceConfiguration:(id<PNRServiceConfiguration>)serviceConfiguration serviceManager:(id<PNRServiceCallInformer>)serviceCallInformer;

/**
 *  @param object Proxied object.
 *  @param networkManager Custom network manager to use for service calls.
 *  @param serviceCallInformer Object who needs to be informed before&after service calls.
 */
- (instancetype)initWithObject:(PNRService *)object networkManager:(id<PNRNetworkManager>)networkManager serviceManager:(id<PNRServiceCallInformer>)serviceCallInformer;

@end
