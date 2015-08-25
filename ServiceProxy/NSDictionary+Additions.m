#import <Foundation/Foundation.h>
#import "NSDictionary+Additions.h"

@implementation NSDictionary (ServiceProxy)

@end



@implementation NSMutableDictionary (ServiceProxy)

- (void)pnr_setNonNilObject:(id)object forKey:(NSString *)key
{
    if (object && [key length] > 0)
    {
        [self setObject:object forKey:key];
    }
}

@end
