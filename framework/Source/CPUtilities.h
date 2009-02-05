
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

CPInteger NSDecimalIntegerValue(NSDecimal decimalNumber);
CPFloat   NSDecimalFloatValue(NSDecimal decimalNumber);
CPDouble  NSDecimalDoubleValue(NSDecimal decimalNumber);

NSDecimal NSDecimalFromInt(CPInteger i);
NSDecimal NSDecimalFromFloat(CPFloat f);
NSDecimal NSDecimalFromDouble(CPDouble d);
