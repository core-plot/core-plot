
#import "CPXYGraph.h"
#import "CPXYPlotSpace.h"
#import "CPExceptions.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"

@implementation CPXYGraph

#pragma mark -
#pragma mark Init/Dealloc

// Designated
-(id)initWithFrame:(CGRect)newFrame xScaleType:(CPScaleType)newXScaleType yScaleType:(CPScaleType)newYScaleType;
{
	xScaleType = newXScaleType;
	yScaleType = newYScaleType;
    if ( self = [super initWithFrame:newFrame] ) {
		self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

-(id)initWithFrame:(CGRect)newFrame
{
    return [self initWithFrame:newFrame xScaleType:CPScaleTypeLinear yScaleType:CPScaleTypeLinear];
}

#pragma mark -
#pragma mark Factory Methods

-(CPPlotSpace *)createPlotSpace 
{
    CPXYPlotSpace *space;
    space = [[CPXYPlotSpace alloc] initWithFrame:self.bounds];
    space.xScaleType = xScaleType;
    space.yScaleType = yScaleType;
    return [space autorelease];
}

-(CPAxisSet *)createAxisSet
{
    CPXYAxisSet *newAxisSet = [[CPXYAxisSet alloc] initWithFrame:self.bounds];
    newAxisSet.xAxis.plotSpace = self.defaultPlotSpace;
    newAxisSet.yAxis.plotSpace = self.defaultPlotSpace;
    return [newAxisSet autorelease];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[super renderAsVectorInContext:theContext];	// draw background fill
}

@end
