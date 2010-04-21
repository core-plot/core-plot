#import "CPPlotAreaFrame.h"
#import "CPAxisSet.h"
#import "CPPlotGroup.h"
#import "CPDefinitions.h"
#import "CPLineStyle.h"
#import "CPPlotArea.h"

///	@cond
@interface CPPlotAreaFrame()

@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;

@end
///	@endcond

#pragma mark -

/** @brief A layer drawn on top of the graph layer and behind all plot elements.
 **/
@implementation CPPlotAreaFrame

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
	if ( self = [super initWithFrame:newFrame] ) {
		plotArea = nil;
		
		CPPlotArea *newPlotArea = [[CPPlotArea alloc] init];
		self.plotArea = newPlotArea;
		[newPlotArea release];

		self.needsDisplayOnBoundsChange = YES;
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
	return CPDefaultZPositionPlotAreaFrame;
}

-(void)layoutSublayers 
{
	[super layoutSublayers];
	
	CPPlotArea *thePlotArea = self.plotArea;
	if ( thePlotArea ) {
		CGRect selfBounds = self.bounds;
		CGSize subLayerSize = selfBounds.size;
		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		
		subLayerSize.width -= self.paddingLeft + self.paddingRight + lineWidth;
		subLayerSize.width = MAX(subLayerSize.width, 0.0);
		subLayerSize.height -= self.paddingTop + self.paddingBottom + lineWidth;
		subLayerSize.height = MAX(subLayerSize.height, 0.0);
		
		CGRect subLayerBounds = thePlotArea.bounds;
		subLayerBounds.size = subLayerSize;
		thePlotArea.bounds = subLayerBounds;
		thePlotArea.anchorPoint = CGPointZero;
		thePlotArea.position = CGPointMake(selfBounds.origin.x + self.paddingLeft, selfBounds.origin.y + self.paddingBottom);
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setPlotArea:(CPPlotArea *)newPlotArea
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

-(CPAxisSet *)axisSet
{
	return self.plotArea.axisSet;
}

-(void)setAxisSet:(CPAxisSet *)newAxisSet
{
	self.plotArea.axisSet = newAxisSet;
}

-(CPPlotGroup *)plotGroup
{
	return self.plotArea.plotGroup;
}

-(void)setPlotGroup:(CPPlotGroup *)newPlotGroup
{
	self.plotArea.plotGroup = newPlotGroup;
}

@end
