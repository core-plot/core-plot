
#import "CPAxis.h"
#import "CPAxisSet.h"
#import "CPGraph.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPPlottingArea.h"

/**	@brief A container layer for the set of axes for a graph.
 **/
@implementation CPAxisSet

/**	@property axes
 *	@brief The axes in the axis set.
 **/
@synthesize axes;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		axes = [[NSArray array] retain];
        self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
    [axes release];
	[super dealloc];
}

#pragma mark -
#pragma mark Labeling

/**	@brief Updates the axis labels for each axis in the axis set.
 **/
-(void)relabelAxes
{
    for ( CPAxis *axis in self.axes ) {
        [axis setNeedsLayout];
        [axis setNeedsRelabel];
		[axis setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setAxes:(NSArray *)newAxes 
{
    if ( newAxes != axes ) {
        for ( CPAxis *axis in axes ) {
            [axis removeFromSuperlayer];
        }
        [axes release];
        axes = [newAxes retain];
		CPPlottingArea *plottingArea = (CPPlottingArea *)self.superlayer;
        for ( CPAxis *axis in axes ) {
            [self addSublayer:axis];
			axis.plottingArea = plottingArea;
        }
        [self setNeedsLayout];
		[self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxisSet;
}

-(void)layoutSublayers
{
    [super layoutSublayers];
    for ( CPAxis *axis in axes ) {
        axis.bounds = self.bounds;
        axis.anchorPoint = CGPointZero;
        axis.position = self.bounds.origin;
    }
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	// nothing to draw
}

@end
