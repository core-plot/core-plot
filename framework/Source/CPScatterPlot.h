
#import <Foundation/Foundation.h>
#import "CPPlot.h"
#import "CPDefinitions.h"

@class CPLineStyle;
@class CPPlotSymbol;
@class CPScatterPlot;
@class CPFill;

extern NSString * const CPScatterPlotBindingXValues;
extern NSString * const CPScatterPlotBindingYValues;
extern NSString * const CPScatterPlotBindingPlotSymbols;

typedef enum _CPScatterPlotField {
    CPScatterPlotFieldX,
    CPScatterPlotFieldY
} CPScatterPlotField;

@protocol CPScatterPlotDataSource <CPPlotDataSource>

@optional
// Implement one of the following to add plot symbols
-(NSArray *)symbolsForScatterPlot:(CPScatterPlot *)plot;
-(CPPlotSymbol *)symbolForScatterPlot:(CPScatterPlot *)plot recordIndex:(NSUInteger)index;

@end 

@interface CPScatterPlot : CPPlot {
    id observedObjectForXValues;
    id observedObjectForYValues;
    id observedObjectForPlotSymbols;
    NSString *keyPathForXValues;
    NSString *keyPathForYValues;
    NSString *keyPathForPlotSymbols;
	CPLineStyle *dataLineStyle;
	CPPlotSymbol *plotSymbol;
    CPFill *areaFill;
    NSDecimalNumber *areaBaseValue;
    NSArray *xValues;
    NSArray *yValues;
    NSArray *plotSymbols;
} 

@property (nonatomic, readwrite, copy) CPLineStyle *dataLineStyle;
@property (nonatomic, readwrite, copy) CPPlotSymbol *plotSymbol;
@property (nonatomic, readwrite, copy) CPFill *areaFill;
@property (nonatomic, readwrite, copy) NSDecimalNumber *areaBaseValue;

@end
