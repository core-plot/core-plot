
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol CPMasking

-(CGPathRef)newMaskingPath; // Caller must release

@end
