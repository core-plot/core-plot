
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
/// @}

NSRange CPExpandedRange(NSRange range, NSInteger expandBy);

CPCoordinate OrthogonalCoordinate(CPCoordinate coord);

CPRGBAColor CPRGBAColorFromCGColor(CGColorRef color);

// Quartz pixel-alignment functions (drawn from Programming with Quartz by D. Gelphman, B. Laden)
CGPoint alignPointToUserSpace(CGContextRef context, CGPoint p);
CGSize alignSizeToUserSpace(CGContextRef context, CGSize s);
CGRect alignRectToUserSpace(CGContextRef context, CGRect r);

