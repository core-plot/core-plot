#import <TargetConditionals.h>

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST

#import <Foundation/Foundation.h>

@interface CPTDecimalNumberValueTransformer : NSValueTransformer

@end

#endif
