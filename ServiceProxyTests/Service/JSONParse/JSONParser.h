#import <Foundation/Foundation.h>

@interface JSONParser : NSObject

// Static method to read JSON file and return NSData
+ (NSDictionary *)dictFromJSONFile:(NSString *)fileName;

@end
