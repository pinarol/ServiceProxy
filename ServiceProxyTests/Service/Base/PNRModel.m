//
//  PNRModel.m
//  Forte
//
//  Created by Yigitcan Yurtsever on 02/10/15.
//  Copyright (c) 2003-2015 Monitise Group Limited. All rights reserved.
//
//  Save to the extent permitted by law, you may not use, copy, modify,
//  distribute or create derivative works of this material or any part
//  of it without the prior written consent of Monitise Group Limited.
//  Any reproduction of this material must contain this notice.
//

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
