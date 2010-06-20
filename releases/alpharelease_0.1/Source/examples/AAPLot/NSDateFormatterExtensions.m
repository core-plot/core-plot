
#import "NSDateFormatterExtensions.h"

@implementation NSDateFormatter (APExtensions)

+(NSDateFormatter *)csvDateFormatter
{
    static NSDateFormatter *df = nil;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
    }
    return df;
}

@end

