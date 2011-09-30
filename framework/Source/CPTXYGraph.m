#import "CPTExceptions.h"
#import "CPTXYAxis.h"
#import "CPTXYAxisSet.h"
#import "CPTXYGraph.h"
#import "CPTXYPlotSpace.h"

/**	@cond */
@interface CPTXYGraph()

@property (nonatomic, readwrite, assign) CPTScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType yScaleType;

@end

/**	@endcond */

#pragma mark -

/**	@brief A graph using a cartesian (X-Y) plot space.
 **/
@implementation CPTXYGraph

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

/** @brief Initializes a newly allocated CPTXYGraph object with the provided frame rectangle and scale types.
 *
 *	This is the designated initializer.
 *
 *	@param newFrame The frame rectangle.
 *	@param newXScaleType The scale type for the x-axis.
 *	@param newYScaleType The scale type for the y-axis.
 *  @return The initialized CPTXYGraph object.
 **/
-(id)initWithFrame:(CGRect)newFrame xScaleType:(CPTScaleType)newXScaleType yScaleType:(CPTScaleType)newYScaleType;
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		xScaleType = newXScaleType;
		yScaleType = newYScaleType;
	}
	return self;
}

-(id)initWithFrame:(CGRect)newFrame
{
	return [self initWithFrame:newFrame xScaleType:CPTScaleTypeLinear yScaleType:CPTScaleTypeLinear];
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTXYGraph *theLayer = (CPTXYGraph *)layer;

		xScaleType = theLayer->xScaleType;
		yScaleType = theLayer->yScaleType;
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeInteger:self.xScaleType forKey:@"CPTXYGraph.xScaleType"];
	[coder encodeInteger:self.yScaleType forKey:@"CPTXYGraph.yScaleType"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		xScaleType = [coder decodeIntegerForKey:@"CPTXYGraph.xScaleType"];
		yScaleType = [coder decodeIntegerForKey:@"CPTXYGraph.yScaleType"];
	}
	return self;
}

#pragma mark -
#pragma mark Factory Methods

-(CPTPlotSpace *)newPlotSpace
{
	CPTXYPlotSpace *space = [[CPTXYPlotSpace alloc] init];

	space.xScaleType = self.xScaleType;
	space.yScaleType = self.yScaleType;
	return space;
}

-(CPTAxisSet *)newAxisSet
{
	CPTXYAxisSet *newAxisSet = [(CPTXYAxisSet *)[CPTXYAxisSet alloc] initWithFrame:self.bounds];

	newAxisSet.xAxis.plotSpace = self.defaultPlotSpace;
	newAxisSet.yAxis.plotSpace = self.defaultPlotSpace;
	return newAxisSet;
}

@end
