#import "PNRServiceInvocationScope.h"

@interface PNRServiceInvocationScope ()

@property (strong, nonatomic, readwrite) NSString *identifier;

@end

@implementation PNRServiceInvocationScope

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _identifier = [PNRServiceInvocationScope generateUUIDString];
    }
    
    return self;
}

#pragma mark - Getters & Setters

- (NSMutableDictionary *)userParameters
{
    if (!_userParameters)
    {
        _userParameters = [[NSMutableDictionary alloc] init];
    }
    return _userParameters;
}


+ (NSString *)generateUUIDString
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault); // Create a new UUID which you own
    NSString *uuidString = CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid)); // Create a new CFStringRef (toll-free bridged to NSString) that you own and transfer ownership of the string to ARC
    CFRelease(uuid); // Release the UUID
    
    return uuidString;
}

@end
