
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPLineStyle;

extern NSString * const CPErrorPlotBindingXValues;
extern NSString * const CPErrorPlotBindingHighValues;
extern NSString * const CPErrorPlotBindingLowValues;

typedef enum _CPErrorPlotField {
    CPRangePlotFieldX,		///< X values.
    CPRangePlotFieldY,		///< Y values.
	CPRangePlotFieldHigh,	///< relative High values.
	CPRangePlotFieldLow	,	///< relative Low values.
	CPRangePlotFieldLeft,	///< relative Left values.
	CPRangePlotFieldRight,	///< relative Right values.
} CPErrorPlotField;

struct CGPointError {
	CGFloat x;
	CGFloat y;
	CGFloat high;
	CGFloat low;
	CGFloat left;
	CGFloat right;
};
typedef struct CGPointError CGPointError;

@interface CPRangePlot : CPPlot {
	CPLineStyle *dataLineStyle;
	CGFloat barWidth, gapHeight, gapWidth;
}
@property (nonatomic, readwrite, copy) CPLineStyle *dataLineStyle;
@property (nonatomic, readwrite) CGFloat barWidth, gapHeight, gapWidth;
-(void)renderAsVectorInContext:(CGContextRef)context;

@end
