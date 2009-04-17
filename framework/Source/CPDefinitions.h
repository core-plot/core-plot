
#import <Foundation/Foundation.h>

typedef NSInteger CPInteger;
typedef CGFloat   CPFloat;
typedef double    CPDouble;

typedef enum  _CPNumericType {
    CPNumericTypeInteger,
    CPNumericTypeFloat,
    CPNumericTypeDouble
} CPNumericType;

typedef enum _CPErrorBarType {
    CPErrorBarTypeCustom,
    CPErrorBarTypeConstantRatio,
    CPErrorBarTypeConstantValue
} CPErrorBarType;

typedef enum _CPScaleType {
    CPScaleTypeLinear,
    CPScaleTypeLogN,
    CPScaleTypeLog10,
    CPScaleTypeAngular
} CPScaleType;

// Plot symbols
typedef enum _CPPlotSymbolType {
    CPPlotSymbolTypeNone,
    CPPlotSymbolTypeRectangle,
    CPPlotSymbolTypeEllipse,
    CPPlotSymbolTypeDiamond,
	CPPlotSymbolTypeTriangle,
	CPPlotSymbolTypeStar,
	CPPlotSymbolTypePentagon,
	CPPlotSymbolTypeHexagon,
	CPPlotSymbolTypeCross,
	CPPlotSymbolTypePlus,
	CPPlotSymbolTypeDash,
	CPPlotSymbolTypeSnow
} CPPlotSymbolType;
