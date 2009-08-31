
#import "CPXYGraph.h"
#import "CPXYPlotSpace.h"
#import "CPExceptions.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"

///	@cond
@interface CPXYGraph()

@property (nonatomic, readwrite, assign) CPScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPScaleType yScaleType;

@end
///	@endcond

/**	@brief A graph using a cartesian (X-Y) plot space.
 **/
@implementation CPXYGraph

/**	@property xScaleType
 *	@brief The scale type for the x-axis.
 **/
@synthesize xScaleType;

/**	@property yScaleType
 *	@brief The scale type for the y-axis.
 **/
@synthesize yScaleType;

#pragma mark -
#pragma mark Init/Dealloc

/** @brief Initializes a newly allocated CPXYGraph object with the provided frame rectangle and scale types.
 *
 *	This is the designated initializer.
 *
 *	@param newFrame The frame rectangle.
 *	@param newXScaleType The scale type for the x-axis.
 *	@param newYScaleType The scale type for the y-axis.
 *  @return The initialized CPXYGraph object.
 **/
-(id)initWithFrame:(CGRect)newFrame xScaleType:(CPScaleType)newXScaleType yScaleType:(CPScaleType)newYScaleType;
{
    if ( self = [super initWithFrame:newFrame] ) {
		xScaleType = newXScaleType;
		yScaleType = newYScaleType;
    }
    return self;
}

-(id)initWithFrame:(CGRect)newFrame
{
    return [self initWithFrame:newFrame xScaleType:CPScaleTypeLinear yScaleType:CPScaleTypeLinear];
}

#pragma mark -
#pragma mark Factory Methods

-(CPPlotSpace *)newPlotSpace 
{
    CPXYPlotSpace *space;
    space = [[CPXYPlotSpace alloc] init];
    space.xScaleType = self.xScaleType;
    space.yScaleType = self.yScaleType;
    return space;
}

-(CPAxisSet *)newAxisSet
{
    CPXYAxisSet *newAxisSet = [(CPXYAxisSet *)[CPXYAxisSet alloc] initWithFrame:self.bounds];
    newAxisSet.xAxis.plotSpace = self.defaultPlotSpace;
    newAxisSet.yAxis.plotSpace = self.defaultPlotSpace;
    return newAxisSet;
}

@end
