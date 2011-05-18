#import "CPTPlotAreaFrame.h"
#import "CPTAxisSet.h"
#import "CPTPlotGroup.h"
#import "CPTDefinitions.h"
#import "CPTLineStyle.h"
#import "CPTPlotArea.h"

/**	@cond */
@interface CPTPlotAreaFrame()

@property (nonatomic, readwrite, retain) CPTPlotArea *plotArea;

@end
/**	@endcond */

#pragma mark -

/** @brief A layer drawn on top of the graph layer and behind all plot elements.
 **/
@implementation CPTPlotAreaFrame

/** @property plotArea
 *	@brief The plot area.
 **/
@synthesize plotArea;

/** @property axisSet
 *	@brief The axis set.
 **/
@dynamic axisSet;

/** @property plotGroup
 *	@brief The plot group.
 **/
@dynamic plotGroup;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		plotArea = nil;
		
		CPTPlotArea *newPlotArea = [(CPTPlotArea *)[CPTPlotArea alloc] initWithFrame:newFrame];
		self.plotArea = newPlotArea;
		[newPlotArea release];

		self.needsDisplayOnBoundsChange = YES;
}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTPlotAreaFrame *theLayer = (CPTPlotAreaFrame *)layer;
		
		plotArea = [theLayer->plotArea retain];
	}
	return self;
}

-(void)dealloc
{
	[plotArea release];
	[super dealloc];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPTDefaultZPositionPlotAreaFrame;
}

-(void)layoutSublayers 
{
	CPTPlotArea *thePlotArea = self.plotArea;
	if ( thePlotArea ) {
		CGFloat leftPadding = self.paddingLeft;
		CGFloat bottomPadding = self.paddingBottom;

		CGRect selfBounds = self.bounds;
		CGSize subLayerSize = selfBounds.size;
		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		
		subLayerSize.width -= leftPadding + self.paddingRight + lineWidth;
		subLayerSize.width = MAX(subLayerSize.width, 0.0);
		subLayerSize.height -= self.paddingTop + bottomPadding + lineWidth;
		subLayerSize.height = MAX(subLayerSize.height, 0.0);
		
		thePlotArea.frame = CGRectMake(leftPadding, bottomPadding, subLayerSize.width, subLayerSize.height);
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setPlotArea:(CPTPlotArea *)newPlotArea
{
	if ( newPlotArea != plotArea ) {
		[plotArea removeFromSuperlayer];
		[plotArea release];
		plotArea = [newPlotArea retain];
		if ( plotArea ) {
			[self insertSublayer:plotArea atIndex:0];
		}
        [self setNeedsLayout];
	}	
}

-(CPTAxisSet *)axisSet
{
	return self.plotArea.axisSet;
}

-(void)setAxisSet:(CPTAxisSet *)newAxisSet
{
	self.plotArea.axisSet = newAxisSet;
}

-(CPTPlotGroup *)plotGroup
{
	return self.plotArea.plotGroup;
}

-(void)setPlotGroup:(CPTPlotGroup *)newPlotGroup
{
	self.plotArea.plotGroup = newPlotGroup;
}

@end
