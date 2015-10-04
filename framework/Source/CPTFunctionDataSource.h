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

@property (nonatomic, readonly, nullable) CPTDataSourceFunction dataSourceFunction;
@property (nonatomic, readonly, nullable) CPTDataSourceBlock dataSourceBlock;
@property (nonatomic, readonly, nonnull) CPTPlot *dataPlot;

@property (nonatomic, readwrite) CGFloat resolution;
@property (nonatomic, readwrite, strong, nullable) CPTPlotRange *dataRange;

/// @name Factory Methods
/// @{
+(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withFunction:(nonnull CPTDataSourceFunction)function;
+(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTDataSourceBlock)block;
/// @}

/// @name Initialization
/// @{
-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot withFunction:(nonnull CPTDataSourceFunction)function;
-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTDataSourceBlock)block;
/// @}

@end
