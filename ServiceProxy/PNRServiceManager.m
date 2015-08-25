#import "PNRServiceManager.h"
#import "PNRService.h"
#import "PNRServiceProxy.h"
#import "PNRNetworkManager.h"

@interface PNRServiceManager ()<PNRServiceCallInformer>

@property (strong, nonatomic) NSHashTable *serviceInterceptorTable; //of type id<PNRServiceInterceptor>, this is configured as a weak type of collection in the getter

@end

@implementation PNRServiceManager

#pragma mark - Lifecycle

+ (instancetype)sharedManager
{
    static PNRServiceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - Getters & Setters

- (NSHashTable *)serviceInterceptorTable
{
    if (!_serviceInterceptorTable)
    {
        //NSPointerFunctionsWeakMemory makes this hashtable hold weak references
        _serviceInterceptorTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _serviceInterceptorTable;
}

#pragma mark - Public

- (id)serviceForClass:(Class)classType withCustomNetworkManager:(id<PNRNetworkManager>)networkManager
{
    NSAssert([classType isSubclassOfClass:[PNRService class]], ([NSString stringWithFormat:@"Error: %@ %@", NSStringFromClass(classType), @"is not a subclass of PNRService"]));
    PNRServiceProxy *proxy = [[PNRServiceProxy alloc] initWithObject:[[classType alloc] init] networkManager:networkManager serviceManager:self];
    return proxy;
}

- (id)serviceForClass:(Class)classType
{
    NSAssert([classType isSubclassOfClass:[PNRService class]], ([NSString stringWithFormat:@"Error: %@ %@", NSStringFromClass(classType), @"is not a subclass of PNRService"]));
    PNRServiceProxy *proxy = [[PNRServiceProxy alloc] initWithObject:[[classType alloc] init] serviceConfiguration:self.configuration serviceManager:self];
    
    return proxy;
}

- (void)addServiceInterceptor:(id<PNRServiceInterceptor>)interceptor
{
    [self.serviceInterceptorTable addObject:interceptor];
}

- (void)removeServiceInterceptor:(id<PNRServiceInterceptor>)interceptor
{
    [self.serviceInterceptorTable removeObject:interceptor];
}

#pragma mark - PNRServiceCallInformer

- (void)informAfterService:(NSString *)serviceName method:(SEL)selector responseData:(id<PNRPopulatable>)response error:(NSError *)error serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope
{
    NSHashTable *serviceInterceptorTable = [self.serviceInterceptorTable copy];
    for (id<PNRServiceInterceptor> interceptor in serviceInterceptorTable)
    {
        if ([interceptor respondsToSelector:@selector(serviceCallDidEnd:method:responseModel:error:serviceInvocationScope:)])
        {
            [interceptor serviceCallDidEnd:serviceName method:selector responseModel:response error:error serviceInvocationScope:serviceInvocationScope];
        }
    }
}

- (BOOL)informAfterServiceBeforeCompletion:(NSString *)serviceName method:(SEL)selector responseData:(id<PNRPopulatable>)response error:(NSError *__autoreleasing *)error serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope
{
    NSHashTable *serviceInterceptorTable = [self.serviceInterceptorTable copy];
    for (id<PNRServiceInterceptor> interceptor in serviceInterceptorTable)
    {
        if ([interceptor respondsToSelector:@selector(serviceCallDidEndBeforeCompletion:method:responseModel:error:serviceInvocationScope:)])
        {
            [interceptor serviceCallDidEndBeforeCompletion:serviceName method:selector responseModel:response error:error serviceInvocationScope:serviceInvocationScope];
        }
    }
    
    return (*error == nil);
}

- (BOOL)shouldProceedToService:(NSString *)serviceName method:(SEL)selector inputData:(id<PNRRequestPopulator>)request serviceInvocationScope:(PNRServiceInvocationScope *)serviceInvocationScope
{
    NSHashTable *serviceInterceptorTable = [self.serviceInterceptorTable copy];
    for (id<PNRServiceInterceptor> interceptor in serviceInterceptorTable)
    {
        if ([interceptor respondsToSelector:@selector(serviceCallShouldStart:method:requestModel:serviceInvocationScope:)])
        {
            return [interceptor serviceCallShouldStart:serviceName method:selector requestModel:request serviceInvocationScope:serviceInvocationScope];
        }
    }
    return YES;
}

@end
