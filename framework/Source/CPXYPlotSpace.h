
#import "CPPlotRange.h"
#import "CPPlotSpace.h"
#import "CPDefinitions.h"

@interface CPXYPlotSpace : CPPlotSpace {
	CPPlotRange *xRange;
	CPPlotRange *yRange;
    CPScaleType xScaleType; // TODO: Implement scale types
    CPScaleType yScaleType; // TODO: Implement scale types
}

@property (nonatomic, readwrite, retain) CPPlotRange *xRange;
@property (nonatomic, readwrite, retain) CPPlotRange *yRange;
@property (nonatomic, readwrite, assign) CPScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPScaleType yScaleType;

@end
