
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

CPInteger CPDecimalIntegerValue(NSDecimal decimalNumber);
CPFloat   CPDecimalFloatValue(NSDecimal decimalNumber);
CPDouble  CPDecimalDoubleValue(NSDecimal decimalNumber);

NSDecimal CPDecimalFromInt(CPInteger i);
NSDecimal CPDecimalFromFloat(CPFloat f);
NSDecimal CPDecimalFromDouble(CPDouble d);

NSRange CPExpandedRange(NSRange range, NSInteger expandBy);

CPCoordinate OrthogonalCoordinate(CPCoordinate coord);

CPRGBAColor CPRGBAColorFromCGColor(CGColorRef color);
