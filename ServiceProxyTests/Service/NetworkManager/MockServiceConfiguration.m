//
//  MockServiceConfiguration.m
//  ServiceProxyTests
//
//  Created by Pinar on 14.09.2024.
//

#import "MockServiceConfiguration.h"

@implementation MockServiceConfiguration

- (NSURL *)endpointUrl { 
    return [[NSURL alloc] initWithString: @"https://api.test.com"];
}

- (NSDictionary *)httpHeaders { 
    return [[NSDictionary alloc] init];
}

@end
