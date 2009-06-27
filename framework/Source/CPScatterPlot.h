
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPLineStyle;
@class CPPlotSymbol;

extern NSString * const CPScatterPlotBindingXValues;
extern NSString * const CPScatterPlotBindingYValues;

typedef enum _CPScatterPlotField {
    CPScatterPlotFieldX,
    CPScatterPlotFieldY
} CPScatterPlotField;

@protocol CPScatterPlotDataSource <CPPlotDataSource>
@optional
-(CPPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)index;  // TODO: Replace setPlotSymbol:atIndex: with this data source method
@end 

@interface CPScatterPlot : CPPlot {
    id observedObjectForXValues;
    id observedObjectForYValues;
    NSString *keyPathForXValues;
    NSString *keyPathForYValues;
	CPLineStyle *dataLineStyle;
	CPPlotSymbol *defaultPlotSymbol;
    NSArray *xValues;
    NSArray *yValues;
    NSMutableArray *plotSymbols;
} 

@property (nonatomic, readwrite, copy) CPLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy) CPPlotSymbol *defaultPlotSymbol;

-(void)setPlotSymbol:(CPPlotSymbol *)symbol atIndex:(NSUInteger)index;

@end
