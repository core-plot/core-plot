#import "CPTAnnotation.h"

@class CPTPlotSpace;

@interface CPTPlotSpaceAnnotation : CPTAnnotation

@property (nonatomic, readwrite, copy, nullable) NSArray *anchorPlotPoint;
@property (nonatomic, readonly, nonnull) CPTPlotSpace *plotSpace;

-(nonnull instancetype)initWithPlotSpace:(nonnull CPTPlotSpace *)space anchorPlotPoint:(nullable NSArray *)plotPoint NS_DESIGNATED_INITIALIZER;
-(nonnull instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end
