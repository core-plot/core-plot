#import "CPTAnnotation.h"

@class CPTPlotSpace;

@interface CPTPlotSpaceAnnotation : CPTAnnotation

@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *anchorPlotPoint;
@property (nonatomic, readonly, nonnull) CPTPlotSpace *plotSpace;

-(nonnull instancetype)initWithPlotSpace:(nonnull CPTPlotSpace *)space anchorPlotPoint:(nullable CPTNumberArray *)plotPoint NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end
