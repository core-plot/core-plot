#import "CPTAxisSet.h"

#import "CPTAxis.h"
#import "CPTGraph.h"
#import "CPTLineStyle.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"

/**
 *	@brief A container layer for the set of axes for a graph.
 **/
@implementation CPTAxisSet

/**	@property axes
 *	@brief The axes in the axis set.
 **/
@synthesize axes;

/** @property borderLineStyle
 *	@brief The line style for the layer border.
 *	If <code>nil</code>, the border is not drawn.
 **/
@synthesize borderLineStyle;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		axes			= [[NSArray array] retain];
		borderLineStyle = nil;

		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTAxisSet *theLayer = (CPTAxisSet *)layer;

		axes			= [theLayer->axes retain];
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
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.axes forKey:@"CPTAxisSet.axes"];
	[coder encodeObject:self.borderLineStyle forKey:@"CPTAxisSet.borderLineStyle"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		axes			= [[coder decodeObjectForKey:@"CPTAxisSet.axes"] copy];
		borderLineStyle = [[coder decodeObjectForKey:@"CPTAxisSet.borderLineStyle"] copy];
	}
	return self;
}

#pragma mark -
#pragma mark Labeling

/**
 *	@brief Updates the axis labels for each axis in the axis set.
 **/
-(void)relabelAxes
{
	NSArray *theAxes = self.axes;

	[theAxes makeObjectsPerformSelector:@selector(setNeedsLayout)];
	[theAxes makeObjectsPerformSelector:@selector(setNeedsRelabel)];
}

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setAxes:(NSArray *)newAxes
{
	if ( newAxes != axes ) {
		for ( CPTAxis *axis in axes ) {
			[axis removeFromSuperlayer];
			axis.plotArea = nil;
		}
		[newAxes retain];
		[axes release];
		axes = newAxes;
		CPTPlotArea *plotArea = (CPTPlotArea *)self.superlayer;
		for ( CPTAxis *axis in axes ) {
			[self addSublayer:axis];
			axis.plotArea = plotArea;
		}
		[self setNeedsLayout];
		[self setNeedsDisplay];
	}
}

-(void)setBorderLineStyle:(CPTLineStyle *)newLineStyle
{
	if ( newLineStyle != borderLineStyle ) {
		[borderLineStyle release];
		borderLineStyle = [newLineStyle copy];
		[self setNeedsDisplay];
	}
}

///	@endcond

@end
