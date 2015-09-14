#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <ServiceProxy/ServiceProxy.h>
#import "MockServiceConfiguration.h"
#import "MockNetworkManager.h"
#import "SamplePaymentsService.h"

@interface ServiceManagerTests : XCTestCase

@end

@implementation ServiceManagerTests

- (void)setUp {
    [PNRServiceManager sharedManager].configuration = [MockServiceConfiguration new];
    
}

- (void)testSamplePaymentsService {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Async Operation"];
    
    // Create a DummyNetworkManager that doesn't touch the network.
    // Use `CreatePrePaymentRecordResponse1.json` as the response.
    MockNetworkManager *networkManager = [[MockNetworkManager alloc] initWithMockName:@"CreatePrePaymentRecordResponse1"];
   
    // Create the service. Even though `SamplePaymentsService` contains no implementation code, 
    // it's capable of making a request and parsing the response. This is the magic of the ServiceProxy API.
    SamplePaymentsService *service = [[PNRServiceManager sharedManager] serviceForClass:[SamplePaymentsService self] withCustomNetworkManager:networkManager];
    
    // Prepare the request object
    PNRCreatePrePaymentRecordRequest *request = [PNRCreatePrePaymentRecordRequest new];
    
    PNRPaymentFieldValue *fieldValue1 = [PNRPaymentFieldValue new];
    fieldValue1.value = @"val1";
    fieldValue1.fieldId = @1;
    
    PNRPaymentFieldValue *fieldValue2 = [PNRPaymentFieldValue new];
    fieldValue2.value = @"val2";
    fieldValue2.fieldId = @2;
    
    request.values = @[fieldValue1, fieldValue2];
    request.vendorId = @123;
    
    // Send the dummy request.
    [service createPrePaymentRecordWithRequest:request completion:^(NSError *error, PNRCreatePrePaymentRecordResponse *response) {
        // Check if `PNRCreatePrePaymentRecordRequest` was successfully converted into a dictionary inside the service proxy.
        XCTAssertEqual(((NSArray *)networkManager.inputBody[@"values"]).count, 2);
        XCTAssertNotNil(networkManager.inputBody[@"vendorId"]);

        // Check if `PNRCreatePrePaymentRecordResponse` was successfully populated from the response by the service proxy.
        XCTAssertEqual(response.record.recordId.intValue, 4);
        XCTAssertTrue([response.record.recordDescription isEqualToString: @"Payment record"]);
        XCTAssertTrue([response.record.paymentAmountLabel isEqualToString: @"123 451 234 512,00 KZT"]);
        XCTAssertTrue([response.record.vendor.name isEqualToString: @"vodafone"]);
        XCTAssertTrue([response.record.paymentAmount.amount isEqualToNumber: @123451234512]);
        XCTAssertTrue([response.record.paymentAmount.currency isEqualToString: @"KZT"]);
        [expectation fulfill];
    }];
    [self waitForExpectations: @[expectation] timeout: 5.0];
}

@end
