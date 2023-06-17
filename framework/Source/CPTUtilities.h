/// @file

#ifdef CPT_IS_FRAMEWORK
#import <CorePlot/CPTDefinitions.h>
#else
#import "CPTDefinitions.h"
#endif

#pragma clang assume_nonnull begin

@class CPTLineStyle;

#ifdef __cplusplus
#if __cplusplus
extern "C" {
#endif
#endif

/// @name Convert NSDecimal to Primitive Types
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

NSString *__nonnull CPTDecimalStringValue(NSDecimal decimalNumber);

/// @}

/// @name Convert Primitive Types to NSDecimal
/// @{
NSDecimal CPTDecimalFromChar(int8_t anInt);
NSDecimal CPTDecimalFromShort(int16_t anInt);
NSDecimal CPTDecimalFromLong(int32_t anInt);
NSDecimal CPTDecimalFromLongLong(int64_t anInt);
NSDecimal CPTDecimalFromInt(int i);
NSDecimal CPTDecimalFromInteger(NSInteger i);

NSDecimal CPTDecimalFromUnsignedChar(uint8_t i);
NSDecimal CPTDecimalFromUnsignedShort(uint16_t i);
NSDecimal CPTDecimalFromUnsignedLong(uint32_t i);
NSDecimal CPTDecimalFromUnsignedLongLong(uint64_t i);
NSDecimal CPTDecimalFromUnsignedInt(unsigned int i);
NSDecimal CPTDecimalFromUnsignedInteger(NSUInteger i);

NSDecimal CPTDecimalFromFloat(float aFloat);
NSDecimal CPTDecimalFromDouble(double aDouble);
NSDecimal CPTDecimalFromCGFloat(CGFloat aCGFloat);

NSDecimal CPTDecimalFromString(NSString *__nonnull stringRepresentation);

/// @}

/// @name NSDecimal Arithmetic
/// @{
NSDecimal CPTDecimalAdd(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalSubtract(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalMultiply(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalDivide(NSDecimal numerator, NSDecimal denominator);

/// @}

/// @name NSDecimal Comparison
/// @{
BOOL CPTDecimalGreaterThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalGreaterThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalLessThan(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalLessThanOrEqualTo(NSDecimal leftOperand, NSDecimal rightOperand);
BOOL CPTDecimalEquals(NSDecimal leftOperand, NSDecimal rightOperand);

/// @}

/// @name NSDecimal Utilities
/// @{
NSDecimal CPTDecimalNaN(void);
NSDecimal CPTDecimalMin(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalMax(NSDecimal leftOperand, NSDecimal rightOperand);
NSDecimal CPTDecimalAbs(NSDecimal value);

/// @}

/// @name Ranges
/// @{
NSRange CPTExpandedRange(NSRange range, NSInteger expandBy);

/// @}

/// @name Coordinates
/// @{
CPTCoordinate CPTOrthogonalCoordinate(CPTCoordinate coord);

/// @}

/// @name Gradient Colors
/// @{
CPTRGBAColor CPTRGBAColorFromCGColor(__nonnull CGColorRef color);

/// @}

/// @name Quartz Pixel-Alignment Functions
/// @{

/**
 *  @fn CPTAlignPointFunction
 *  @brief A function called to align a point in a @ref CGContextRef.
 *
 *  @param  context The graphics context.
 *  @param  point   The point in user space.
 *  @return         The device aligned point in user space.
 **/
typedef CGPoint (*CPTAlignPointFunction)(__nonnull CGContextRef context, CGPoint point);

/**
 *  @fn CPTAlignSizeFunction
 *  @brief A function called to align a size in a @ref CGContextRef.
 *
 *  @param  context The graphics context.
 *  @param  size    The size in user space.
 *  @return         The device aligned size in user space.
 **/
typedef CGSize (*CPTAlignSizeFunction)(__nonnull CGContextRef context, CGSize size);

/**
 *  @fn CPTAlignRectFunction
 *  @brief A function called to align a rectangle in a @ref CGContextRef.
 *
 *  @param  context The graphics context.
 *  @param  rect    The rectangle in user space.
 *  @return         The device aligned rectangle in user space.
 **/
typedef CGRect (*CPTAlignRectFunction)(__nonnull CGContextRef context, CGRect rect);

CGPoint CPTAlignPointToUserSpace(__nonnull CGContextRef context, CGPoint point);
CGSize CPTAlignSizeToUserSpace(__nonnull CGContextRef context, CGSize size);
CGRect CPTAlignRectToUserSpace(__nonnull CGContextRef context, CGRect rect);

CGPoint CPTAlignIntegralPointToUserSpace(__nonnull CGContextRef context, CGPoint point);
CGRect CPTAlignIntegralRectToUserSpace(__nonnull CGContextRef context, CGRect rect);

CGRect CPTAlignBorderedRectToUserSpace(__nonnull CGContextRef context, CGRect rect, CPTLineStyle *__nonnull borderLineStyle);

/// @}

/// @name String Formatting for Core Graphics Structs
/// @{
NSString *__nonnull CPTStringFromPoint(CGPoint point);
NSString *__nonnull CPTStringFromSize(CGSize size);
NSString *__nonnull CPTStringFromRect(CGRect rect);
NSString *__nonnull CPTStringFromVector(CGVector vector);

/// @}

/// @name CGPoint Utilities
/// @{
CGFloat squareOfDistanceBetweenPoints(CGPoint point1, CGPoint point2);

/// @}

/// @name Edge Inset Utilities
/// @{
CPTEdgeInsets CPTEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right);
BOOL CPTEdgeInsetsEqualToEdgeInsets(CPTEdgeInsets insets1, CPTEdgeInsets insets2);

/// @}

/// @name Log Modulus Definition
/// @{
double CPTLogModulus(double value);
double CPTInverseLogModulus(double value);

/// @}

#ifdef __cplusplus
#if __cplusplus
}
#endif
#endif

#pragma clang assume_nonnull end
