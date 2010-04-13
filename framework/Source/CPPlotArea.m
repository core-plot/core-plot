#import "CPAxis.h"
#import "CPAxisLabelGroup.h"
#import "CPAxisSet.h"
#import "CPFill.h"
#import "CPLineStyle.h"
#import "CPPlotFrame.h"
#import "CPPlotGroup.h"
#import "CPPlotArea.h"

/** @brief A layer representing the actual plotting area of a graph.
 *	
 *	All plots are drawn inside this area while axes, titles, and borders may fall outside.
 *	The layers are arranged so that the graph elements are drawn in the following order:
 *	-# Background fill
 *	-# Minor grid lines
 *	-# Major grid lines
 *	-# Background border
 *	-# Axis lines with major and minor tick marks
 *	-# Plots
 *	-# Axis labels
 *	-# Axis titles
 **/
@implementation CPPlotArea

/** @property minorGridLineGroup
 *	@brief The parent layer for all minor grid lines.
 **/
@synthesize minorGridLineGroup;

/** @property majorGridLineGroup
 *	@brief The parent layer for all major grid lines.
 **/
@synthesize majorGridLineGroup;

/** @property plotFrame
 *	@brief The plot frame layer.
 **/
@synthesize plotFrame;

/** @property axisSet
 *	@brief The axis set.
 **/
@synthesize axisSet;

/** @property plotGroup
 *	@brief The plot group.
 **/
@synthesize plotGroup;

/** @property axisLabelGroup
 *	@brief The parent layer for all axis labels.
 **/
@synthesize axisLabelGroup;

/** @property axisTitleGroup
 *	@brief The parent layer for all axis titles.
 **/
@synthesize axisTitleGroup;

/** @property borderLineStyle 
 *	@brief The line style for the layer border.
 *	If nil, the border is not drawn.
 **/
@dynamic borderLineStyle;

/** @property fill 
 *	@brief The fill for the layer background.
 *	If nil, the layer background is not filled.
 **/
@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		minorGridLineGroup = nil;
		majorGridLineGroup = nil;
		plotFrame = nil;
		axisSet = nil;
		plotGroup = nil;
		axisLabelGroup = nil;
		axisTitleGroup = nil;
		fill = nil;
		
		CPLayer *newGridLines = [[CPLayer alloc] init];
		self.minorGridLineGroup = newGridLines;
		[newGridLines release];
		
		newGridLines = [[CPLayer alloc] init];
		self.majorGridLineGroup = newGridLines;
		[newGridLines release];
		
		CPPlotFrame *newPlotFrame = [[CPPlotFrame alloc] init];
		self.plotFrame = newPlotFrame;
		[newPlotFrame release];
		
		CPPlotGroup *newPlotGroup = [[CPPlotGroup alloc] init];
		self.plotGroup = newPlotGroup;
		[newPlotGroup release];
		
		CPAxisLabelGroup *newAxisLabelGroup = [[CPAxisLabelGroup alloc] init];
		self.axisLabelGroup = newAxisLabelGroup;
		[newAxisLabelGroup release];
		
		CPAxisLabelGroup *newAxisTitleGroup = [[CPAxisLabelGroup alloc] init];
		self.axisTitleGroup = newAxisTitleGroup;
		[newAxisTitleGroup release];
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	[minorGridLineGroup release];
	[majorGridLineGroup release];
	[plotFrame release];
	[axisSet release];
	[plotGroup release];
	[axisLabelGroup release];
	[axisTitleGroup release];
	[fill release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.fill ) {
		[super renderAsVectorInContext:context];
		
		[self.fill fillRect:self.bounds inContext:context];
	}
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotAreaFrame;
}

-(void)layoutSublayers
{
	CALayer *superlayer = self.superlayer;
	CGRect sublayerBounds = [self convertRect:superlayer.bounds fromLayer:superlayer];
	sublayerBounds.origin = CGPointZero;
	CGPoint sublayerPosition = [self convertPoint:self.bounds.origin toLayer:superlayer];
	sublayerPosition = CGPointMake(-sublayerPosition.x, -sublayerPosition.y);
	
	for (CALayer *subLayer in self.sublayers) {
		subLayer.bounds = sublayerBounds;
		subLayer.anchorPoint = CGPointZero;
		subLayer.position = sublayerPosition;
	}
}

#pragma mark -
#pragma mark Accessors

-(CPLineStyle *)borderLineStyle
{
	return self.plotFrame.borderLineStyle;
}

-(void)setBorderLineStyle:(CPLineStyle *)newLineStyle
{
	self.plotFrame.borderLineStyle = newLineStyle;
}

-(void)setMinorGridLineGroup:(CPLayer *)newGridLines
{
	if ( newGridLines != minorGridLineGroup ) {
		[minorGridLineGroup removeFromSuperlayer];
		[minorGridLineGroup release];
		minorGridLineGroup = [newGridLines retain];
		if ( minorGridLineGroup ) {
			[self insertSublayer:minorGridLineGroup atIndex:0];
		}
        [self setNeedsLayout];
	}	
}

-(void)setMajorGridLineGroup:(CPLayer *)newGridLines
{
	if ( newGridLines != majorGridLineGroup ) {
		[majorGridLineGroup removeFromSuperlayer];
		[majorGridLineGroup release];
		majorGridLineGroup = [newGridLines retain];
		if ( majorGridLineGroup ) {
			NSUInteger index = 0;
			if ( self.minorGridLineGroup ) index++;
			[self insertSublayer:majorGridLineGroup atIndex:index];
		}
        [self setNeedsLayout];
	}	
}

-(void)setPlotFrame:(CPPlotFrame *)newPlotFrame
{
	if ( newPlotFrame != plotFrame ) {
		[plotFrame removeFromSuperlayer];
		[plotFrame release];
		plotFrame = [newPlotFrame retain];
		if ( plotFrame ) {
			NSUInteger index = 0;
			if ( self.minorGridLineGroup ) index++;
			if ( self.majorGridLineGroup ) index++;
			[self insertSublayer:plotFrame atIndex:index];
		}
        [self setNeedsLayout];
	}	
}

-(void)setAxisSet:(CPAxisSet *)newAxisSet
{
	if ( newAxisSet != axisSet ) {
		[axisSet removeFromSuperlayer];
		[axisSet release];
		axisSet = [newAxisSet retain];
		if ( axisSet ) {
			NSUInteger index = 0;
			if ( self.minorGridLineGroup ) index++;
			if ( self.majorGridLineGroup ) index++;
			if ( self.plotFrame ) index++;
			[self insertSublayer:axisSet atIndex:index];
			for ( CPAxis *axis in axisSet.axes ) {
				axis.plotArea = self;
			}
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
			NSUInteger index = 0;
			if ( self.minorGridLineGroup ) index++;
			if ( self.majorGridLineGroup ) index++;
			if ( self.plotFrame ) index++;
			if ( self.axisSet ) index++;
			[self insertSublayer:plotGroup atIndex:index];
		}
        [self setNeedsLayout];
	}	
}

-(void)setAxisLabelGroup:(CPAxisLabelGroup *)newAxisLabelGroup
{
	if ( newAxisLabelGroup != axisLabelGroup ) {
		[axisLabelGroup removeFromSuperlayer];
		[axisLabelGroup release];
		axisLabelGroup = [newAxisLabelGroup retain];
		if ( axisLabelGroup ) {
			NSUInteger index = 0;
			if ( self.minorGridLineGroup ) index++;
			if ( self.majorGridLineGroup ) index++;
			if ( self.plotFrame ) index++;
			if ( self.axisSet ) index++;
			if ( self.plotGroup ) index++;
			[self insertSublayer:axisLabelGroup atIndex:index];
		}
        [self setNeedsLayout];
	}	
}

-(void)setAxisTitleGroup:(CPAxisLabelGroup *)newAxisTitleGroup
{
	if ( newAxisTitleGroup != axisTitleGroup ) {
		[axisTitleGroup removeFromSuperlayer];
		[axisTitleGroup release];
		axisTitleGroup = [newAxisTitleGroup retain];
		if ( axisTitleGroup ) {
			NSUInteger index = 0;
			if ( self.minorGridLineGroup ) index++;
			if ( self.majorGridLineGroup ) index++;
			if ( self.plotFrame ) index++;
			if ( self.axisSet ) index++;
			if ( self.plotGroup ) index++;
			if ( self.axisLabelGroup ) index++;
			[self insertSublayer:axisTitleGroup atIndex:index];
		}
        [self setNeedsLayout];
	}	
}

@end
