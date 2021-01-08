#import "CPTPlot.h"

@class CPTPlotRange;

/// @file


/**
 *  @brief An Objective-C block called to generate plot data in a CPTFieldFunctionDataSource datasource.
 **/
typedef double (^CPTFieldDataSourceBlock)(double, double);

/**
 *  @brief An Objective-C block called to generate plot data in a CPTContourFunctionDataSource datasource.
 **/
typedef double (^CPTContourDataSourceBlock)(double, double);

@interface CPTFieldFunctionDataSource : NSObject<CPTPlotDataSource>

@property (nonatomic, readonly, nullable) CPTFieldDataSourceBlock dataSourceBlockX;
@property (nonatomic, readonly, nullable) CPTFieldDataSourceBlock dataSourceBlockY;
@property (nonatomic, readonly, nullable) CPTContourDataSourceBlock dataSourceBlock;
@property (nonatomic, readonly, nonnull) CPTPlot *dataPlot;

@property (nonatomic, readwrite) CGFloat resolutionX;
@property (nonatomic, readwrite, strong, nullable) CPTPlotRange *dataXRange;
@property (nonatomic, readwrite) CGFloat resolutionY;
@property (nonatomic, readwrite, strong, nullable) CPTPlotRange *dataYRange;

/// @name Factory Methods
/// @{

+(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withBlockX:(nonnull CPTFieldDataSourceBlock) blockX withBlockY:(nullable CPTFieldDataSourceBlock) blockY NS_SWIFT_NAME(init(for:withBlockX:withBlockY:) );

+(nonnull instancetype)dataSourceForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTContourDataSourceBlock)block NS_SWIFT_NAME(init(for:withBlock:) );

/// @}

/// @name Initialization
/// @{

-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot withBlockX:(nonnull CPTFieldDataSourceBlock) blockX withBlockY:(nullable CPTFieldDataSourceBlock) blockY NS_SWIFT_NAME(init(for:withBlockX:withBlockY:) );

-(nonnull instancetype)initForPlot:(nonnull CPTPlot *)plot withBlock:(nonnull CPTContourDataSourceBlock)block NS_SWIFT_NAME(init(for:withBlock:) );

/// @}

/// @name Accessors
/// @{

-(NSUInteger)getDataXCount;
-(NSUInteger)getDataYCount;

/// @}

@end
