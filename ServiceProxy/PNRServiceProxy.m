#import <Foundation/Foundation.h>
#import "PNRServiceProxy.h"
#import "PNRBlockDescription.h"
#import "PNRServiceInfo.h"
#import "PNRServiceManager.h"
#import "PNRService.h"
#import "PNRServiceInvocationScope.h"
#import "PNRObjectPopulator.h"
#import "PNRNetworkManager.h"
#import "NSString+Additions.h"

typedef void (^PNRServiceResponseCompletion)(NSError *error, id<PNRPopulatable> response);
static NSInteger const kPNRServiceProxyMethodFirstArgumentIndex = 2;
static NSInteger const kPNRServiceProxyMethodSecondArgumentIndex = 3;
static NSInteger const kPNRServiceProxyResponseClassNameStartIndex = 2;
static NSInteger const kPNRServiceProxyResponseClassNameIndexFromEnd = 3;

/**
   Replaces occurrences of a string with elements of array sequentially.
   e.g. abcXdefXghiX replace X with array [K,L] becomes: abcKdefLghiX
 */
@interface NSString (PNRServiceProxy)

- (NSString *)pnr_replaceOccurrencesOfString:(NSString *)stringToReplace withArrayElements:(NSArray *)arguments;
+ (BOOL)pnr_isStringValidAndNonEmpty:(NSString *)string;

@end

@interface PNRServiceProxy ()

@property (copy, nonatomic) NSURL *endpointURL;
@property (strong, nonatomic) NSDictionary *httpHeaders;
@property (strong, nonatomic) PNRService *object;
@property (strong, nonatomic) id<PNRNetworkManager> networkManager;
@property (strong, nonatomic) id<PNRServiceCallInformer> serviceCallInformer;
@property (strong, nonatomic) id<PNRServiceConfiguration> serviceConfiguration;

@end

@implementation PNRServiceProxy

#pragma mark - Lifecycle

- (instancetype)initWithObject:(PNRService *)object serviceConfiguration:(id<PNRServiceConfiguration>)serviceConfiguration serviceManager:(id<PNRServiceCallInformer>)serviceCallInformer
{
    NSParameterAssert(object);
    // Don't call [super init], as NSProxy does not recognize -init.
    self.object = object;
    self.serviceCallInformer = serviceCallInformer;
    self.endpointURL = [serviceConfiguration endpointUrl];
    self.httpHeaders = [serviceConfiguration httpHeaders];
    self.serviceConfiguration = serviceConfiguration;
    return self;
}

- (instancetype)initWithObject:(PNRService *)object networkManager:(id<PNRNetworkManager>)networkManager serviceManager:(id<PNRServiceCallInformer>)serviceCallInformer
{
    NSParameterAssert(object);
    // Don't call [super init], as NSProxy does not recognize -init.
    self.object = object;
    self.networkManager = networkManager;
    self.serviceCallInformer = serviceCallInformer;
    return self;
}


#pragma mark - NSProxy

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [self.object methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    PNRServiceInfo *serviceInfo = [self.object serviceInfoForSelector:invocation.selector];
    NSObject<PNRRequestPopulator> *requestObj = [self extractRequestObjectFromInvocation:invocation];
    NSString *responseClassName = [self extractResponseClassNameFromInvocation:invocation];
    PNRServiceResponseCompletion completionBlock = [self extractCompletionBlockPointerFromInvocation:invocation];
    NSString *url = [self buildUrlWithRequestModel:requestObj withServiceInfo:serviceInfo];
    NSDictionary *requestBodyDict = [self buildBodyWithRequestModel:requestObj withServiceInfo:serviceInfo];

    PNRServiceInvocationScope *serviceInvocationScope = [PNRServiceInvocationScope new];
    [self buildServiceInvocationScope:requestObj serviceInvocationScope:serviceInvocationScope];

    BOOL proceed = [self.serviceCallInformer shouldProceedToService:NSStringFromClass([self.object class]) method:invocation.selector inputData:requestObj serviceInvocationScope:serviceInvocationScope];

    if (proceed)
    {
        void (^PNRServiceProxyResponseCompletion)(NSError *error, NSDictionary *data) = ^(NSError *error, NSDictionary *data) {
            [self handleResponseWithError:error serviceInvocationScope:serviceInvocationScope responseData:data responseClassName:responseClassName responseBlock:completionBlock method:invocation.selector];
        };
        
        [[self networkManager] requestWithURLString:url method:serviceInfo.requestMethod httpBody:requestBodyDict completion:PNRServiceProxyResponseCompletion];
    }
    //[invocation invokeWithTarget:self.object]; //if the target method needs to be called in the future uncomment here
}

#pragma mark - Helpers

- (void)handleResponseWithError:(NSError *)error serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope responseData:(NSDictionary *)data responseClassName:(NSString *)className responseBlock:(PNRServiceResponseCompletion)completionBlock method:(SEL)selector
{
    id<PNRPopulatable> response;
    if (!error)
    {
        Class responseClass = NSClassFromString(className);
        NSAssert([[[responseClass alloc] init] conformsToProtocol:@protocol(PNRPopulatable)], ([NSString stringWithFormat:@"%@ must conform to protocol PNRPopulatable", NSStringFromClass(responseClass)]));
        response = [[responseClass alloc] init];
        response = [PNRObjectPopulator pnr_populateObject:response withDictionary:data];
    }

    [self.serviceCallInformer informAfterServiceBeforeCompletion:NSStringFromClass([self.object class]) method:selector responseData:response error:&error serviceInvocationScope:serviceInvocationScope];

    if (completionBlock)
    {
        completionBlock(error, response);
    }
    [self.serviceCallInformer informAfterService:NSStringFromClass([self.object class]) method:selector responseData:response error:error serviceInvocationScope:serviceInvocationScope];
}

- (NSString *)buildUrlWithRequestModel:(id<PNRRequestPopulator>)requestObj withServiceInfo:(PNRServiceInfo *)serviceInfo
{
    NSMutableString *url = [NSMutableString stringWithString:serviceInfo.url];
    if ([requestObj respondsToSelector:@selector(urlTemplateParameters)])
    {
        if ([requestObj urlTemplateParameters])
        {
            url = [NSMutableString stringWithString:[serviceInfo.url pnr_replaceOccurrencesOfString:@"%@" withArrayElements:[requestObj urlTemplateParameters]]];
        }
    }
    if ([requestObj respondsToSelector:@selector(urlParameters)])
    {
        id urlParameterObject = [requestObj urlParameters];
        if (urlParameterObject)
        {
            NSAssert([urlParameterObject conformsToProtocol:@protocol(PNRPopulatable)], ([NSString stringWithFormat:@"%@ must conform to protocol PNRPopulatable", NSStringFromClass([[requestObj urlParameters] class])]));
            
            NSString *urlParameters = [PNRObjectPopulator pnr_urlParameterRepresentationOfObject:urlParameterObject];
            if ([NSString pnr_isStringValidAndNonEmpty: urlParameters])
            {
                [url appendString:@"/?"];
                [url appendString:urlParameters];
            }
        }
    }
    return url;
}

- (void)buildServiceInvocationScope:(id<PNRRequestPopulator>)requestObj serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope
{
    if ([requestObj respondsToSelector:@selector(userParameters)])
    {
        [serviceInvocationScope.userParameters addEntriesFromDictionary:[requestObj userParameters]];
    }
}

- (NSDictionary *)buildBodyWithRequestModel:(id<PNRRequestPopulator>)requestObj withServiceInfo:(PNRServiceInfo *)serviceInfo
{
    NSDictionary *requestBodyDict = nil;
    if ([requestObj respondsToSelector:@selector(requestBody)])
    {
        NSAssert([[requestObj requestBody] conformsToProtocol:@protocol(PNRPopulatable)], ([NSString stringWithFormat:@"%@ must conform to protocol PNRPopulatable", NSStringFromClass([[requestObj requestBody] class])]));

        requestBodyDict = [PNRObjectPopulator pnr_dictionaryRepresentationOfObject:[requestObj requestBody]];
    }
    return requestBodyDict;
}

- (NSString *)extractResponseClassNameFromInvocation:(NSInvocation *)invocation
{
    PNRServiceResponseCompletion successBlock = [self extractCompletionBlockPointerFromInvocation:invocation];
    PNRBlockDescription *blockDescription = [[PNRBlockDescription alloc] initWithBlock:successBlock];
    NSMethodSignature *signature = blockDescription.blockSignature;
    NSString *responseClassName = [NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:kPNRServiceProxyMethodFirstArgumentIndex]];
    responseClassName = [responseClassName substringWithRange:NSMakeRange(kPNRServiceProxyResponseClassNameStartIndex, [responseClassName length] - kPNRServiceProxyResponseClassNameIndexFromEnd)];
    return responseClassName;
}

- (PNRServiceResponseCompletion)extractCompletionBlockPointerFromInvocation:(NSInvocation *)invocation
{
    void *successBlockPointer;
    [invocation getArgument:&successBlockPointer atIndex:kPNRServiceProxyMethodSecondArgumentIndex];
    PNRServiceResponseCompletion successBlock = (__bridge PNRServiceResponseCompletion)successBlockPointer;
    return successBlock;
}

- (id<PNRRequestPopulator>)extractRequestObjectFromInvocation:(NSInvocation *)invocation
{
    __unsafe_unretained id firstArgument = nil;
    [invocation getArgument:&firstArgument atIndex:kPNRServiceProxyMethodFirstArgumentIndex];
    return firstArgument;
}

@end

@implementation NSString (PNRServiceProxy)

- (NSString *)pnr_replaceOccurrencesOfString:(NSString *)stringToReplace withArrayElements:(NSArray *)arguments
{
    NSString *result = [self copy];
    for (NSUInteger i = 0; i < [arguments count]; i++)
    {
        if (![arguments[i] isKindOfClass:[NSString class]])
        {
            NSException *invalidArgumentException = [[NSException alloc] initWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"object at index:[%lu] must have been kind of class NSString but it is: %@", (unsigned long)i, NSStringFromClass([arguments[i] class])] userInfo:@{}];
            [invalidArgumentException raise];
            return nil;
        }
        result = [result pnr_stringByReplacingFirstOccurrenceOfString:stringToReplace withString:arguments[i]];
    }
    return result;
}

+ (BOOL)pnr_isStringValidAndNonEmpty:(NSString *)string
{
    // Checking for the string class here to detect NSNull strings coming from the server and any other objects passed to that method.
    if (string == nil || ![string isKindOfClass:[NSString class]] || string.length == 0)
    {
        return NO;
    }
    return YES;
}

@end
