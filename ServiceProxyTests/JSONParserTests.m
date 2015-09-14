#import <XCTest/XCTest.h>
#import "JSONParser.h"

@interface JSONParserTests : XCTestCase

@end

@implementation JSONParserTests

- (void)testParse {
    NSDictionary *dict = [JSONParser dictFromJSONFile:@"CreatePrePaymentRecordResponse1"];
    XCTAssertNotNil(dict);
}

@end
