
#import <Cocoa/Cocoa.h>


@interface NSDecimalNumber (CPExtensions)

+(NSDecimalNumber *)decimalNumberWithNumber:(NSNumber *)number;

-(CGFloat)floatValue;

@end
