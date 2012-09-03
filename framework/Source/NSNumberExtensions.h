#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/** @category NSNumber(CPTExtensions)
 *  @brief Core Plot extensions to NSNumber.
 **/
@interface NSNumber(CPTExtensions)

+(NSNumber *)numberWithCGFloat:(CGFloat)number;

-(CGFloat)cgFloatValue;
-(id)initWithCGFloat:(CGFloat)number;

-(NSDecimalNumber *)decimalNumber;

@end
