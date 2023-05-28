#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>

/** @category NSNumber(CPTExtensions)
 *  @brief Core Plot extensions to NSNumber.
 *
 *  @see NSNumber
 **/
@interface NSNumber(CPTExtensions)

+(nonnull instancetype)numberWithCGFloat:(CGFloat)number;

-(CGFloat)cgFloatValue;
-(nonnull instancetype)initWithCGFloat:(CGFloat)number;

-(nonnull NSDecimalNumber *)decimalNumber;

@end
