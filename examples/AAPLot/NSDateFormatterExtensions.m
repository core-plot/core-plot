#import "NSDateFormatterExtensions.h"

@implementation NSDateFormatter(APExtensions)

+(nonnull NSDateFormatter *)csvDateFormatter
{
    static NSDateFormatter *df       = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        df            = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
    });

    return df;
}

@end
