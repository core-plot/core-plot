#import "CPPlotArea.h"
#import "CPAxisSet.h"
#import "CPPlotGroup.h"
#import "CPDefinitions.h"
#import "CPLineStyle.h"

/** @brief A layer drawn on top of the graph layer and behind all plot elements.
 **/
@implementation CPPlotArea

/** @property axisSet
 *	@brief The axis set.
 **/
@synthesize axisSet;

/** @property plotGroup
 *	@brief The plot group.
 **/
@synthesize plotGroup;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		axisSet = nil;
		plotGroup = nil;
		
		CPPlotGroup *newPlotGroup = [[CPPlotGroup alloc] init];
		self.plotGroup = newPlotGroup;
		[newPlotGroup release];

		self.needsDisplayOnBoundsChange = YES;
}
	return self;
}

-(void)dealloc
{
	[axisSet release];
	[plotGroup release];
	[super dealloc];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotArea;
}

-(void)layoutSublayers 
{
	[super layoutSublayers];
	
	CGFloat inset = self.borderLineStyle.lineWidth;
	CGRect sublayerBounds = CGRectInset(self.bounds, inset, inset);

	CPAxisSet *theAxisSet = self.axisSet;
	if ( theAxisSet ) {
		// Set the bounds so that the axis set coordinates coincide with the 
		// plot area drawing coordinates.
		theAxisSet.bounds =	 sublayerBounds;
		theAxisSet.anchorPoint = CGPointZero;
		theAxisSet.position = sublayerBounds.origin;
	}
	
	CPPlotGroup *thePlotGroup = self.plotGroup;
	if ( thePlotGroup ) {
		// Set the bounds so that the plot group coordinates coincide with the 
		// plot area drawing coordinates.
		thePlotGroup.bounds = sublayerBounds;
		thePlotGroup.anchorPoint = CGPointZero;
		thePlotGroup.position = sublayerBounds.origin;
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setAxisSet:(CPAxisSet *)newAxisSet
{
	if ( newAxisSet != axisSet ) {
		[axisSet removeFromSuperlayer];
		[axisSet release];
		axisSet = [newAxisSet retain];
		if ( axisSet ) {
			[self insertSublayer:axisSet atIndex:0];
		}
        [self setNeedsLayout];
	}	
}

-(void)setPlotGroup:(CPPlotGroup *)newPlotGroup
{
	if ( newPlotGroup != plotGroup ) {
		[plotGroup removeFromSuperlayer];
		[plotGroup release];
		plotGroup = [newPlotGroup retain];
		if ( plotGroup ) {
			[self insertSublayer:plotGroup below:self.axisSet];
		}
        [self setNeedsLayout];
	}	
}

@end
