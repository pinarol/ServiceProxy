//
//  NSDictionary+Additions.h
//  ServiceProxy
//
//  Created by Pinar in 2015.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ServiceProxy)

@end


/**
 *  Extension for NSDictionary to set validated values.
 */
@interface NSMutableDictionary (ServiceProxy)

/**
 *  Sets object for key if object is not nil.
 *
 *  @param object Object to set.
 *
 *  @param key Key to associate object with.
 */
- (void)pnr_setNonNilObject:(id)object forKey:(NSString *)key;

@end

