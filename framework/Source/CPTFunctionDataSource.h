#import "CPTPlot.h"

@class CPTPlotRange;

/// @file

/**
 *  @brief A function called to generate plot data in a CPTFunctionDataSource datasource.
 **/
typedef double (*CPTDataSourceFunction)(double);

/**
 *  @brief An Objective-C block called to generate plot data in a CPTFunctionDataSource datasource.
 **/
typedef double (^CPTDataSourceBlock)(double);

@interface CPTFunctionDataSource : NSObject<CPTPlotDataSource>

@property (nonatomic, readonly) CPTDataSourceFunction dataSourceFunction;
@property (nonatomic, readonly) CPTDataSourceBlock dataSourceBlock;
@property (nonatomic, readonly, cpt_weak_property) __cpt_weak CPTPlot *dataPlot;

@property (nonatomic, readwrite) CGFloat resolution;
@property (nonatomic, readwrite, strong) CPTPlotRange *dataRange;

/// @name Factory Methods
/// @{
+(instancetype)dataSourceForPlot:(CPTPlot *)plot withFunction:(CPTDataSourceFunction)function;
+(instancetype)dataSourceForPlot:(CPTPlot *)plot withBlock:(CPTDataSourceBlock)block;
/// @}

/// @name Initialization
/// @{
-(instancetype)initForPlot:(CPTPlot *)plot withFunction:(CPTDataSourceFunction)function;
-(instancetype)initForPlot:(CPTPlot *)plot withBlock:(CPTDataSourceBlock)block;
/// @}

@end
