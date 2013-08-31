#import "CPTPlot.h"

@class CPTMutablePlotRange;
@class CPTPlotRange;
@class CPTPlotSpace;

/// @file

/**
 *  @brief A function called to generate plot data in a CPTFunctionDataSource datasource.
 **/
typedef double (*CPTDataSourceFunction)(double);

@interface CPTFunctionDataSource : NSObject<CPTPlotDataSource>

@property (nonatomic, readonly) CPTDataSourceFunction dataSourceFunction;
@property (nonatomic, readonly, cpt_weak_property) __cpt_weak CPTPlot *dataPlot;

@property (nonatomic, readwrite) CGFloat resolution;
@property (nonatomic, readwrite, strong) CPTPlotRange *dataRange;

/// @name Factory Methods
/// @{
+(id)dataSourceForPlot:(CPTPlot *)plot withFunction:(CPTDataSourceFunction)function;
/// @}

/// @name Initialization
/// @{
-(id)initForPlot:(CPTPlot *)plot withFunction:(CPTDataSourceFunction)function;
/// @}

@end
