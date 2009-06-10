
#import "CPXYGraph.h"
#import "CPXYPlotSpace.h"
#import "CPExceptions.h"
#import "CPXYAxisSet.h"
#import "CPXYAxis.h"

@interface CPXYGraph()

@property (nonatomic, readwrite, assign) CPScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPScaleType yScaleType;

@end

@implementation CPXYGraph

@synthesize xScaleType;
@synthesize yScaleType;

#pragma mark -
#pragma mark Init/Dealloc

// Designated
-(id)initWithFrame:(CGRect)newFrame xScaleType:(CPScaleType)newXScaleType yScaleType:(CPScaleType)newYScaleType;
{
    if ( self = [super initWithFrame:newFrame] ) {
		self.xScaleType = newXScaleType;
		self.yScaleType = newYScaleType;
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

-(CPPlotSpace *)newPlotSpace 
{
    CPXYPlotSpace *space;
    space = [[CPXYPlotSpace alloc] initWithFrame:self.bounds];
    space.xScaleType = xScaleType;
    space.yScaleType = yScaleType;
    return space;
}

-(CPAxisSet *)newAxisSet
{
    CPXYAxisSet *newAxisSet = [[CPXYAxisSet alloc] initWithFrame:self.bounds];
    newAxisSet.xAxis.plotSpace = self.defaultPlotSpace;
    newAxisSet.yAxis.plotSpace = self.defaultPlotSpace;
    return newAxisSet;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[super renderAsVectorInContext:theContext];	// draw background fill
}

@end
