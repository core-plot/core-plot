
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPLineStyle;
@class CPPlotSymbol;

extern NSString *CPScatterPlotBindingXValues;
extern NSString *CPScatterPlotBindingYValues;

typedef enum _CPScatterPlotField {
    CPScatterPlotFieldX,
    CPScatterPlotFieldY,
    CPScatterPlotFieldErrorMinimum,
    CPScatterPlotFieldErrorMaximum
} CPScatterPlotField;


@interface CPScatterPlot : CPPlot {
    CPNumericType numericType;
    id observedObjectForXValues;
    id observedObjectForYValues;
    NSString *keyPathForXValues;
    NSString *keyPathForYValues;
    BOOL hasErrorBars;
	CPLineStyle *dataLineStyle;
	CPPlotSymbol *defaultPlotSymbol;
    NSArray *xValues;
    NSArray *yValues;
    NSMutableArray *plotSymbols;
} 

@property (nonatomic, readwrite, assign) CPNumericType numericType;
@property (nonatomic, readwrite, assign) BOOL hasErrorBars;
@property (nonatomic, readwrite, copy) CPLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy) CPPlotSymbol *defaultPlotSymbol;

-(void)setPlotSymbol:(CPPlotSymbol *)symbol atIndex:(NSUInteger)index;

@end
