#import "CPPlotArea.h"
#import "CPAxisSet.h"
#import "CPPlotGroup.h"
#import "CPDefinitions.h"
#import "CPLineStyle.h"
#import "CPPlottingArea.h"

/** @brief A layer drawn on top of the graph layer and behind all plot elements.
 **/
@implementation CPPlotArea

/** @property plottingArea
 *	@brief The plotting area.
 **/
@synthesize plottingArea;

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
	if ( self = [super initWithFrame:newFrame] ) {
		plottingArea = nil;
		
		CPPlottingArea *newPlottingArea = [[CPPlottingArea alloc] init];
		self.plottingArea = newPlottingArea;
		[newPlottingArea release];

		self.needsDisplayOnBoundsChange = YES;
}
	return self;
}

-(void)dealloc
{
	[plottingArea release];
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
	
	CPPlottingArea *thePlottingArea = self.plottingArea;
	if ( thePlottingArea ) {
		CGRect selfBounds = self.bounds;
		CGSize subLayerSize = selfBounds.size;
		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		
		subLayerSize.width -= self.paddingLeft + self.paddingRight + lineWidth;
		subLayerSize.width = MAX(subLayerSize.width, 0.0f);
		subLayerSize.height -= self.paddingTop + self.paddingBottom + lineWidth;
		subLayerSize.height = MAX(subLayerSize.height, 0.0f);
		
		CGRect subLayerBounds = thePlottingArea.bounds;
		subLayerBounds.size = subLayerSize;
		thePlottingArea.bounds = subLayerBounds;
		thePlottingArea.anchorPoint = CGPointZero;
		thePlottingArea.position = CGPointMake(selfBounds.origin.x + self.paddingLeft, selfBounds.origin.y + self.paddingBottom);
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setPlottingArea:(CPPlottingArea *)newPlottingArea
{
	if ( newPlottingArea != plottingArea ) {
		[plottingArea removeFromSuperlayer];
		[plottingArea release];
		plottingArea = [newPlottingArea retain];
		if ( plottingArea ) {
			[self insertSublayer:plottingArea atIndex:0];
		}
        [self setNeedsLayout];
	}	
}

-(CPAxisSet *)axisSet
{
	return self.plottingArea.axisSet;
}

-(void)setAxisSet:(CPAxisSet *)newAxisSet
{
	self.plottingArea.axisSet = newAxisSet;
}

-(CPPlotGroup *)plotGroup
{
	return self.plottingArea.plotGroup;
}

-(void)setPlotGroup:(CPPlotGroup *)newPlotGroup
{
	self.plottingArea.plotGroup = newPlotGroup;
}

@end
