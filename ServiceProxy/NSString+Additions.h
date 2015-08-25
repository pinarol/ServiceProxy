//
//  NSString+Additions.h
//  ServiceProxy
//
//  Created by Pinar in 2015.
//

#import <Foundation/Foundation.h>

/**
 *  Category on NSString that contains validation and encoding methods.
 */
@interface NSString (ServiceProxy)

/**
 *  @return The url parameter friendly version of the string, replaces the unaccaptable characters like ;/:@$+{}<>, with %(UTF-8 hex) representation.
 */
- (NSString *)pnr_URLEncodedString;

/**
 *  Only replaces the first occurrence of a string.
 *
 *  @param stringToReplace String to be replaced.
 *  @param replacementString Replacement string.
 *  <br>Examaple:
 *  <br>abcXdefX replace X with Y becomes: abcYdefX
 */
- (NSString *)pnr_stringByReplacingFirstOccurrenceOfString:(NSString *)stringToReplace withString:(NSString *)replacementString;

@end
