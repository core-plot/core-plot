
#import <Foundation/Foundation.h>

typedef enum  {
    CPNumericTypeInteger,
    CPNumericTypeFloat,
    CPNumericTypeDouble
} CPNumericType;

typedef struct _CPPlotRange {
    NSDecimal location;
    NSDecimal length;
} CPPlotRange;

typedef enum _CPErrorBarType {
    CPErrorBarTypeCustom,
    CPErrorBarTypeConstantRatio,
    CPErrorBarTypeConstantValue
} CPErrorBarType;