
#import <Foundation/Foundation.h>
#import "CPDefinitions.h"
#import "CPPlotRange.h"

CPInteger CPDecimalIntegerValue(NSDecimal decimalNumber);
CPFloat   CPDecimalFloatValue(NSDecimal decimalNumber);
CPDouble  CPDecimalDoubleValue(NSDecimal decimalNumber);

NSDecimal CPDecimalFromInt(CPInteger i);
NSDecimal CPDecimalFromFloat(CPFloat f);
NSDecimal CPDecimalFromDouble(CPDouble d);

CPPlotRange* CPMakePlotRange(CPDouble location, CPDouble length);