#import <ServiceProxy/PNRServiceInvocationScope.h>

@protocol PNRPopulatable;
@protocol PNRNetworkManager;

/**
 *  Confirm to this protocol to provide endpoint url and httpHeaders.
 */
@protocol PNRServiceConfiguration <NSObject>

/**
 *  Implement this method to provide endpoint url to connect.<p>
 *  If users of this framework needs different url's for different conditions (Debug,Release configurations for example) then they may put that logic inside this method.
 */
- (NSURL *)endpointUrl;

/**
 *  Implement this method to provide http headers.
 */
- (NSDictionary*)httpHeaders;

@end

/**
 *  Conform to this protocol to provide info about what your request model looks like.
 */
@protocol PNRRequestPopulator <NSObject>

@optional

/**
 *  Implement this method if your request url includes variables.<p>
 *  For example: /appconnect/contents/%@/%@ <p>
 *  In this case this method should return array of 2 elements that correspond to %@ symbols. Lowest indexed array element corresponds to the left most symbol<p>
 *
 *  @note The return array must consist of NSSting elements.
 *  @note Only use %@ symbols to represent variables.
 */
- (NSArray*)urlTemplateParameters;

/**
 *  Implement this method if your request has url parameters like: /locations?minLat=23.45&maxLat=27.89 <p>
 *  Every name value pair is represented by a property of the returning PNRPopulatable object.
 */
- (id<PNRPopulatable>)urlParameters;

/**
 *  Implement this method if your request has body parameters.
 *
 *  @return PNRPopulatable object is converted to json and set as request body.
 */
- (id<PNRPopulatable>)requestBody;

/**
 *  User defined parameters that may need to be transported throught service interceptor methods. These are added to PNRServiceInvocationScope when service invocation starts.
 */
- (NSDictionary *)userParameters;

@end

/**
 *  Conform to this protocol to be able to listen to before&after service call events.
 */
@protocol PNRServiceInterceptor <NSObject>

@optional

/**
 *  This method is called just before a service call occurs.
 *
 *  @return true if we want service call to start, false otherwise.
 */
- (BOOL)serviceCallShouldStart:(NSString *)serviceName method:(SEL)selector requestModel:(id<PNRRequestPopulator>)request serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope;

/**
 *  This method is called just after the service call but before all completion blocks are executed.
 */
- (void)serviceCallDidEndBeforeCompletion:(NSString *)serviceName method:(SEL)selector responseModel:(id<PNRPopulatable>)response error:(NSError**)error serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope;

/**
 *  This method is called just after the service call and after all completion blocks are executed.
 */
- (void)serviceCallDidEnd:(NSString *)serviceName method:(SEL)selector responseModel:(id<PNRPopulatable>)response error:(NSError *)error serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope;

@end

/**
 *  Use this singleton class to: <br>
 *  1. Configure endpoint url address and httpHeaders <br>
 *  2. Get a service proxy instance for the given class <br>
 *  3. Register as PNRServiceInterceptor and listen to before&after service call events <br>
 */
@interface PNRServiceManager : NSObject

/**
 *  Configuration used by this singleton instance.<br>
 *
 *  @note If you change this configuration it affects the next http request<br>
 *  This configuration is ignored if custom network manager is used(In other words if (serviceForClass:withCustomNetworkManager:) is used).
 */
@property (strong, nonatomic) id<PNRServiceConfiguration> configuration;

/**
 *  @return The singleton instance.
 */
+ (instancetype)sharedManager;

/**
 *  @return A new service instance for given service class. Input class must be subclass of PNRService.
 */
- (id)serviceForClass:(Class)serviceClass;

/**
 *  This method provides a service object that uses a custom network manager. URL and httpHeaders in the "configuration" property are totally ignored.
 *
 *  @return A new service instance for given service class. Input class must be subclass of PNRService.
 */
- (id)serviceForClass:(Class)serviceClass withCustomNetworkManager:(id<PNRNetworkManager>)networkManager;

/**
 *  Register as a listener for before&after service calls, interceptors are hold as weak references.
 *
 *  @note If you call this method more than once with the same input object it will be added only once.
 */
- (void)addServiceInterceptor:(id<PNRServiceInterceptor>)interceptor;

/**
 *  Remove a listener registered with "addServiceInterceptor:".
 */
- (void)removeServiceInterceptor:(id<PNRServiceInterceptor>)interceptor;

@end
