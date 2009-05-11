
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

CPInteger CPDecimalIntegerValue(NSDecimal decimalNumber);
CPFloat   CPDecimalFloatValue(NSDecimal decimalNumber);
CPDouble  CPDecimalDoubleValue(NSDecimal decimalNumber);

NSDecimal CPDecimalFromInt(CPInteger i);
NSDecimal CPDecimalFromFloat(CPFloat f);
NSDecimal CPDecimalFromDouble(CPDouble d);

NSRange CPExpandedRange(NSRange range, NSInteger expandBy);

#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
#else
CGColorRef CPNewCGColorFromNSColor(NSColor *nsColor);

CPRGBColor CPRGBColorFromNSColor(NSColor *nsColor);
#endif

CPRGBColor CPRGBColorFromCGColor(CGColorRef color);
