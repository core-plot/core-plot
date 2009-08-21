
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

/// @file

/// @name NSDecimal Utilities
/// @{
CPInteger CPDecimalIntegerValue(NSDecimal decimalNumber);
CPFloat   CPDecimalFloatValue(NSDecimal decimalNumber);
CPDouble  CPDecimalDoubleValue(NSDecimal decimalNumber);

NSDecimal CPDecimalFromInt(CPInteger i);
NSDecimal CPDecimalFromFloat(CPFloat f);
NSDecimal CPDecimalFromDouble(CPDouble d);

NSDecimal CPDecimalAdd(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalSubtract(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalMultiply(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalDivide(NSDecimal numerator, NSDecimal denominator);

BOOL CPDecimalGreaterThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalGreaterThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalLessThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalLessThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalEquals(NSDecimal leftOperand, NSDecimal rightOperand);

NSDecimal CPDecimalFromString(NSString *stringRepresentation);
/// @}

NSRange CPExpandedRange(NSRange range, NSInteger expandBy);

CPCoordinate OrthogonalCoordinate(CPCoordinate coord);

CPRGBAColor CPRGBAColorFromCGColor(CGColorRef color);

/// @name Quartz Pixel-Alignment Functions
/// @{
CGPoint alignPointToUserSpace(CGContextRef context, CGPoint p);
CGSize alignSizeToUserSpace(CGContextRef context, CGSize s);
CGRect alignRectToUserSpace(CGContextRef context, CGRect r);
/// @}
