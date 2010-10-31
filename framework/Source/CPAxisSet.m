#import "CPAxis.h"
#import "CPAxisSet.h"
#import "CPGraph.h"
#import "CPLineStyle.h"
#import "CPPlotSpace.h"
#import "CPPlotArea.h"

/**	@brief A container layer for the set of axes for a graph.
 **/
@implementation CPAxisSet

/**	@property axes
 *	@brief The axes in the axis set.
 **/
@synthesize axes;

/** @property borderLineStyle 
 *	@brief The line style for the layer border.
 *	If nil, the border is not drawn.
 **/
@synthesize borderLineStyle;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		axes = [[NSArray array] retain];
		borderLineStyle = nil;
		
        self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPAxisSet *theLayer = (CPAxisSet *)layer;
		
		axes = [theLayer->axes retain];
		borderLineStyle = [theLayer->borderLineStyle retain];
	}
	return self;
}

-(void)dealloc
{
    [axes release];
	[borderLineStyle release];
	[super dealloc];
}

#pragma mark -
#pragma mark Labeling

/**	@brief Updates the axis labels for each axis in the axis set.
 **/
-(void)relabelAxes
{
	NSArray *theAxes = self.axes;
	[theAxes makeObjectsPerformSelector:@selector(setNeedsLayout)];
	[theAxes makeObjectsPerformSelector:@selector(setNeedsRelabel)];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxisSet;
}

#pragma mark -
#pragma mark Accessors

-(void)setAxes:(NSArray *)newAxes 
{
    if ( newAxes != axes ) {
        for ( CPAxis *axis in axes ) {
            [axis removeFromSuperlayer];
			axis.plotArea = nil;
        }
		[newAxes retain];
        [axes release];
        axes = newAxes;
		CPPlotArea *plotArea = (CPPlotArea *)self.superlayer;
        for ( CPAxis *axis in axes ) {
            [self addSublayer:axis];
			axis.plotArea = plotArea;
        }
        [self setNeedsLayout];
		[self setNeedsDisplay];
    }
}

-(void)setBorderLineStyle:(CPLineStyle *)newLineStyle
{
	if ( newLineStyle != borderLineStyle ) {
		borderLineStyle.delegate = nil;
		[borderLineStyle release];
		borderLineStyle = [newLineStyle copy];
		borderLineStyle.delegate = self;
		[self setNeedsDisplay];
	}
}

@end
