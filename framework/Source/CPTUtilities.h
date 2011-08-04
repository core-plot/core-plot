#import <Foundation/Foundation.h>
#import "CPTDefinitions.h"

/// @file

#if __cplusplus
extern "C" {
#endif

/// @name Convert NSDecimal to primitive types
/// @{
int8_t CPTDecimalCharValue(NSDecimal decimalNumber);
int16_t CPTDecimalShortValue(NSDecimal decimalNumber);
int32_t CPTDecimalLongValue(NSDecimal decimalNumber);
int64_t CPTDecimalLongLongValue(NSDecimal decimalNumber);
int CPTDecimalIntValue(NSDecimal decimalNumber);
NSInteger CPTDecimalIntegerValue(NSDecimal decimalNumber);

uint8_t CPTDecimalUnsignedCharValue(NSDecimal decimalNumber);
uint16_t CPTDecimalUnsignedShortValue(NSDecimal decimalNumber);
uint32_t CPTDecimalUnsignedLongValue(NSDecimal decimalNumber);
uint64_t CPTDecimalUnsignedLongLongValue(NSDecimal decimalNumber);
unsigned int CPTDecimalUnsignedIntValue(NSDecimal decimalNumber);
NSUInteger CPTDecimalUnsignedIntegerValue(NSDecimal decimalNumber);

float CPTDecimalFloatValue(NSDecimal decimalNumber);
double CPTDecimalDoubleValue(NSDecimal decimalNumber);
CGFloat CPTDecimalCGFloatValue(NSDecimal decimalNumber);

NSString * CPTDecimalStringValue(NSDecimal decimalNumber);
/// @}

/// @name Convert primitive types to NSDecimal
/// @{
NSDecimal CPTDecimalFromChar(int8_t i);
NSDecimal CPTDecimalFromShort(int16_t i);
NSDecimal CPTDecimalFromLong(int32_t i);
NSDecimal CPTDecimalFromLongLong(int64_t i);
NSDecimal CPTDecimalFromInt(int i);
NSDecimal CPTDecimalFromInteger(NSInteger i);

NSDecimal CPTDecimalFromUnsignedChar(uint8_t i);
NSDecimal CPTDecimalFromUnsignedShort(uint16_t i);
NSDecimal CPTDecimalFromUnsignedLong(uint32_t i);
NSDecimal CPTDecimalFromUnsignedLongLong(uint64_t i);
NSDecimal CPTDecimalFromUnsignedInt(unsigned int i);
NSDecimal CPTDecimalFromUnsignedInteger(NSUInteger i);

NSDecimal CPTDecimalFromFloat(float f);
NSDecimal CPTDecimalFromDouble(double d);
NSDecimal CPTDecimalFromCGFloat(CGFloat f);

NSDecimal CPTDecimalFromString(NSString *stringRepresentation);
/// @}

/// @name NSDecimal arithmetic
/// @{
NSDecimal CPTDecimalAdd(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalSubtract(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalMultiply(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalDivide(NSDecimal numerator, NSDecimal denominator);
/// @}

/// @name NSDecimal comparison
/// @{
BOOL CPTDecimalGreaterThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalGreaterThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalLessThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalLessThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalEquals(NSDecimal leftOperand, NSDecimal rightOperand);
/// @}

/// @name NSDecimal utilities
/// @{
NSDecimal CPTDecimalNaN(void);
/// @}

/// @name Ranges
/// @{
NSRange CPTExpandedRange(NSRange range, NSInteger expandBy);
/// @}

/// @name Coordinates
/// @{
CPTCoordinate CPTOrthogonalCoordinate(CPTCoordinate coord);
/// @}

/// @name Gradient colors
/// @{
CPTRGBAColor CPTRGBAColorFromCGColor(CGColorRef color);
/// @}

/// @name Quartz Pixel-Alignment Functions
/// @{
CGPoint CPTAlignPointToUserSpace(CGContextRef context, CGPoint p);
CGSize CPTAlignSizeToUserSpace(CGContextRef context, CGSize s);
CGRect CPTAlignRectToUserSpace(CGContextRef context, CGRect r);
/// @}

/// @name String formatting for Core Graphics structs
/// @{
NSString *CPTStringFromPoint(CGPoint p);
NSString *CPTStringFromSize(CGSize s);
NSString *CPTStringFromRect(CGRect r);
/// @}

#if __cplusplus
}
#endif
