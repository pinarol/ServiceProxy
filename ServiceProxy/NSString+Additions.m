#import "NSString+Additions.h"

static NSString *const kPNRFoundationCharactersToReplaceInURL = @";/:@$+{}<>,";

@implementation NSString (ServiceProxy)


- (NSString *)pnr_URLEncodedString
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet characterSetWithCharactersInString: kPNRFoundationCharactersToReplaceInURL]];
}

- (NSString *)pnr_stringByReplacingFirstOccurrenceOfString:(NSString *)stringToReplace withString:(NSString *)replacementString
{
    NSString *result = [self copy];
    NSRange rOriginal = [self rangeOfString:stringToReplace];
    
    if (rOriginal.location != NSNotFound)
    {
        result = [self stringByReplacingCharactersInRange:rOriginal withString:replacementString];
    }
    
    return result;
}

@end
