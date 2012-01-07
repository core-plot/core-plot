#import "CPTGridLineGroup.h"

#import "CPTAxis.h"
#import "CPTAxisSet.h"
#import "CPTGridLines.h"
#import "CPTPlotArea.h"

/**	@brief A group of grid line layers.
 *
 *	When using separate axis layers, this layer serves as the common superlayer for the grid line layers.
 *	Otherwise, this layer handles the drawing for the grid lines. It supports mixing the two modes;
 *	some axes can use separate grid line layers while others are handled by the grid line group.
 **/
@implementation CPTGridLineGroup

/**	@property plotArea
 *  @brief The plot area that this grid line group belongs to.
 **/
@synthesize plotArea;

/**	@property major
 *	@brief If YES, draw the major grid lines, else draw the minor grid lines.
 **/
@synthesize major;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTGridLineGroup object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTGridLineGroup::plotArea plotArea @endlink = <code>nil</code>
 *	- @link CPTGridLineGroup::major major @endlink = <code>NO</code>
 *	- <code>needsDisplayOnBoundsChange</code> = <code>YES</code>
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTGridLineGroup object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		plotArea = nil;
		major	 = NO;

		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTGridLineGroup *theLayer = (CPTGridLineGroup *)layer;

		plotArea = theLayer->plotArea;
		major	 = theLayer->major;
	}
	return self;
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeConditionalObject:self.plotArea forKey:@"CPTGridLineGroup.plotArea"];
	[coder encodeBool:self.major forKey:@"CPTGridLineGroup.major"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		plotArea = [coder decodeObjectForKey:@"CPTGridLineGroup.plotArea"];
		major	 = [coder decodeBoolForKey:@"CPTGridLineGroup.major"];
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

///	@cond

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) {
		return;
	}

	for ( CPTAxis *axis in self.plotArea.axisSet.axes ) {
		if ( !axis.separateLayers ) {
			[axis drawGridLinesInContext:theContext isMajor:self.major];
		}
	}
}

///	@endcond

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setPlotArea:(CPTPlotArea *)newPlotArea
{
	if ( newPlotArea != plotArea ) {
		plotArea = newPlotArea;

		if ( plotArea ) {
			[self setNeedsDisplay];
		}
	}
}

///	@endcond

@end
