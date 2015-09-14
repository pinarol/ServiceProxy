#import "PNRModel.h"

static NSString *const kFTDateTimeFormatComplete = @"yyyy-MM-dd'T'HH:mm:ssSSSZ";

@implementation PNRModel

- (Class)boundarySuperClass
{
    return [PNRModel class];
}

- (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = kFTDateTimeFormatComplete;
    });
    return dateFormatter;
}

@end
