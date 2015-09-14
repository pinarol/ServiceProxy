# ServiceProxy

ServiceProxy API allows you to write REST API calls with minimal code. No boilerplate guaranteed.

Write ZERO code to,
- Serialize the request from an object.
- Deserialize the response into an object.
- Even making the actual network call!

Example:

SamplePaymentsService.h

```
typedef void (^PNRCreatePrePaymentRecordRequestCompletion)(NSError *error, PNRCreatePrePaymentRecordResponse *response);

@interface SamplePaymentsService : PNRService

// Declare your service call. What kind of request it takes and what kind of response it returns.
- (void)createPrePaymentRecordWithRequest:(PNRCreatePrePaymentRecordRequest *)request completion:(PNRCreatePrePaymentRecordRequestCompletion)completion;

@end
```

SamplePaymentsService.m

```

@implementation SamplePaymentsService

- (void)createPrePaymentRecordWithRequest:(PNRCreatePrePaymentRecordRequest *)request completion:(__strong PNRCreatePrePaymentRecordRequestCompletion)completion {


   // Yes, you are seeing right. There's no code here!
   // Because you don't need any. This is the magic of ServiceProxy.


}

- (PNRServiceInfo *)serviceInfoForSelector:(SEL)selector
{
    if (selector == @selector(createPrePaymentRecordWithRequest:completion:))
    {   // return the endpoint and the HTTP method
        return [[PNRServiceInfo alloc] initWithUrl:@"payment/pre-record" requestMethod:PNRRequestMethodPOST];
    }
    return nil;
}

```

Sample response:

```

@interface PNRCreatePrePaymentRecordResponse : PNRResponse

@property (nonatomic, strong) PNRPaymentRecord *record;

@end

@implementation PNRCreatePrePaymentRecordResponse

   // You are seeing right. There's no code here as well! 
   // No need for any parsing or JSON mapping.

@end

```

How do i make the actual service call?

Configure your PNRServiceManager just once with a simple config object that conforms to `PNRServiceConfiguration`. Here, you pass your host url and stuff.
```
    [PNRServiceManager sharedManager].configuration = [MockServiceConfiguration new];
```

Create your `SamplePaymentsService` with the help of `PNRServiceManager`. Pass a network manager that conforms to `PNRNetworkManager`.

```
    SamplePaymentsService *service = [[PNRServiceManager sharedManager] serviceForClass:[SamplePaymentsService self] withCustomNetworkManager:myNetworkManager.shared];
```

That's it. Now you can call your service.
```
    // Build your request as necessary.
    PNRCreatePrePaymentRecordRequest *request = [PNRCreatePrePaymentRecordRequest new];
    request.values = ...;
    request.vendorId = ...;
    
    // Make the request.
    [service createPrePaymentRecordWithRequest:request completion:^(NSError *error, PNRCreatePrePaymentRecordResponse *response) {
    

        // response is fully parsed as `PNRCreatePrePaymentRecordResponse` and ready to use! Like magic!

        
    }];
```

### Okay. But how does it work?

All this works with the help of Objective-C runtime and [NSProxy](https://developer.apple.com/documentation/foundation/nsproxy). Basically, every service call is handled by the `PNRServiceProxy` and its `forwardInvocation:` method. It reads your method's invocation data to learn what your response and request object are, what completion should be called after the network call, etc. It serializes the request, makes the request; and once it finishes, populates the response for you!

Check out the unit tests(`ServiceManagerTests`) to see the real life `SamplePaymentsService` implementation.
