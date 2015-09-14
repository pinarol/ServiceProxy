#import "JSONParser.h"

@implementation JSONParser

+ (NSDictionary *)dictFromJSONFile:(NSString *)fileName {
    // Locate the file in the test bundle
    NSBundle *testBundle = [NSBundle bundleForClass:self];
    NSString *filePath = [testBundle pathForResource:fileName ofType:@"json"];
    
    // Check if the file path is valid
    if (!filePath) {
        NSLog(@"File not found: %@", fileName);
        return nil;
    }
    
    // Read the file content into NSData
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        NSLog(@"Failed to read file data: %@", fileName);
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    if (error) {
        NSLog(@"Failed to parse JSON: %@", error.localizedDescription);
        return nil;
    }
    
    return jsonDictionary;
}

@end
