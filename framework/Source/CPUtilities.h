#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

/// @file

/// @name Convert NSDecimal to primitive types
/// @{
int8_t CPDecimalCharValue(NSDecimal decimalNumber);
int16_t CPDecimalShortValue(NSDecimal decimalNumber);
int32_t CPDecimalLongValue(NSDecimal decimalNumber);
int64_t CPDecimalLongLongValue(NSDecimal decimalNumber);
int CPDecimalIntValue(NSDecimal decimalNumber);
NSInteger CPDecimalIntegerValue(NSDecimal decimalNumber);

uint8_t CPDecimalUnsignedCharValue(NSDecimal decimalNumber);
uint16_t CPDecimalUnsignedShortValue(NSDecimal decimalNumber);
uint32_t CPDecimalUnsignedLongValue(NSDecimal decimalNumber);
uint64_t CPDecimalUnsignedLongLongValue(NSDecimal decimalNumber);
unsigned int CPDecimalUnsignedIntValue(NSDecimal decimalNumber);
NSUInteger CPDecimalUnsignedIntegerValue(NSDecimal decimalNumber);

float CPDecimalFloatValue(NSDecimal decimalNumber);
double CPDecimalDoubleValue(NSDecimal decimalNumber);

NSString * CPDecimalStringValue(NSDecimal decimalNumber);
/// @}

/// @name Convert primitive types to NSDecimal
/// @{
NSDecimal CPDecimalFromChar(int8_t i);
NSDecimal CPDecimalFromShort(int16_t i);
NSDecimal CPDecimalFromLong(int32_t i);
NSDecimal CPDecimalFromLongLong(int64_t i);
NSDecimal CPDecimalFromInt(int i);
NSDecimal CPDecimalFromInteger(NSInteger i);

NSDecimal CPDecimalFromUnsignedChar(uint8_t i);
NSDecimal CPDecimalFromUnsignedShort(uint16_t i);
NSDecimal CPDecimalFromUnsignedLong(uint32_t i);
NSDecimal CPDecimalFromUnsignedLongLong(uint64_t i);
NSDecimal CPDecimalFromUnsignedInt(unsigned int i);
NSDecimal CPDecimalFromUnsignedInteger(NSUInteger i);

NSDecimal CPDecimalFromFloat(float f);
NSDecimal CPDecimalFromDouble(double d);

NSDecimal CPDecimalFromString(NSString *stringRepresentation);
/// @}

/// @name NSDecimal arithmetic
/// @{
NSDecimal CPDecimalAdd(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalSubtract(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalMultiply(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPDecimalDivide(NSDecimal numerator, NSDecimal denominator);
/// @}

/// @name NSDecimal comparison
/// @{
BOOL CPDecimalGreaterThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalGreaterThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalLessThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalLessThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPDecimalEquals(NSDecimal leftOperand, NSDecimal rightOperand);
/// @}

/// @name NSDecimal utilities
/// @{
NSDecimal CPDecimalNaN(void);
/// @}

/// @name Ranges
/// @{
NSRange CPExpandedRange(NSRange range, NSInteger expandBy);
/// @}

/// @name Coordinates
/// @{
CPCoordinate CPOrthogonalCoordinate(CPCoordinate coord);
/// @}

/// @name Gradient colors
/// @{
CPRGBAColor CPRGBAColorFromCGColor(CGColorRef color);
/// @}

/// @name Quartz Pixel-Alignment Functions
/// @{
CGPoint CPAlignPointToUserSpace(CGContextRef context, CGPoint p);
CGSize CPAlignSizeToUserSpace(CGContextRef context, CGSize s);
CGRect CPAlignRectToUserSpace(CGContextRef context, CGRect r);
/// @}

/// @name String formatting for Core Graphics structs
/// @{
NSString *CPStringFromPoint(CGPoint p);
NSString *CPStringFromSize(CGSize s);
NSString *CPStringFromRect(CGRect r);
/// @}
