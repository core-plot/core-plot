#import "CPAxis.h"
#import "CPAxisLabelGroup.h"
#import "CPAxisSet.h"
#import "CPFill.h"
#import "CPLineStyle.h"
#import "CPPlotGroup.h"
#import "CPPlotArea.h"

static const int kCPNumberOfLayers = 6;	// number of primary layers to arrange

///	@cond
@interface CPPlotArea()

@property (nonatomic, readwrite, assign) CPGraphLayerType *bottomUpLayerOrder;
@property (nonatomic, readwrite, assign, getter=isUpdatingLayers) BOOL updatingLayers;

-(void)updateLayerOrder;
-(unsigned)indexForLayerType:(CPGraphLayerType)layerType;

@end
///	@endcond

#pragma mark -

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

/** @property topDownLayerOrder
 *	@brief An array of graph layers to be drawn in an order other than the default.
 *
 *	The array should reference the layers using the constants defined in #CPGraphLayerType.
 *	Layers should be specified in order starting from the top layer.
 *	Only the layers drawn out of the default order need be specified; all others will
 *	automatically be placed at the bottom of the view in their default order.
 *
 *	If this property is nil, the layers will be drawn in the default order (bottom to top):
 *	-# Minor grid lines
 *	-# Major grid lines
 *	-# Axis lines, including the tick marks
 *	-# Plots
 *	-# Axis labels
 *	-# Axis titles
 *
 *	Example usage:
 *	<code>[graph setTopDownLayerOrder:[NSArray arrayWithObjects:
 *	[NSNumber numberWithInt:CPGraphLayerTypePlots],
 *	[NSNumber numberWithInt:CPGraphLayerTypeAxisLabels],
 *	[NSNumber numberWithInt:CPGraphLayerTypeMajorGridLines],
 *	..., nil]];</code> 
 **/
@synthesize topDownLayerOrder;

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

// Private properties
@synthesize bottomUpLayerOrder;
@synthesize updatingLayers;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		minorGridLineGroup = nil;
		majorGridLineGroup = nil;
		axisSet = nil;
		plotGroup = nil;
		axisLabelGroup = nil;
		axisTitleGroup = nil;
		fill = nil;
		topDownLayerOrder = nil;
		bottomUpLayerOrder = malloc(kCPNumberOfLayers * sizeof(CPGraphLayerType));
		[self updateLayerOrder];
		
		CPLayer *newGridLines = [(CPLayer *)[CPLayer alloc] initWithFrame:newFrame];
		self.minorGridLineGroup = newGridLines;
		[newGridLines release];
		
		newGridLines = [(CPLayer *)[CPLayer alloc] initWithFrame:newFrame];
		self.majorGridLineGroup = newGridLines;
		[newGridLines release];
		
		CPPlotGroup *newPlotGroup = [(CPPlotGroup *)[CPPlotGroup alloc] initWithFrame:newFrame];
		self.plotGroup = newPlotGroup;
		[newPlotGroup release];
		
		CPAxisLabelGroup *newAxisLabelGroup = [(CPAxisLabelGroup *)[CPAxisLabelGroup alloc] initWithFrame:newFrame];
		self.axisLabelGroup = newAxisLabelGroup;
		[newAxisLabelGroup release];
		
		CPAxisLabelGroup *newAxisTitleGroup = [(CPAxisLabelGroup *)[CPAxisLabelGroup alloc] initWithFrame:newFrame];
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
	[axisSet release];
	[plotGroup release];
	[axisLabelGroup release];
	[axisTitleGroup release];
	[fill release];
	[topDownLayerOrder release];
	free(bottomUpLayerOrder);
	
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
	return CPDefaultZPositionPlotArea;
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
	
	// make the plot group the same size as the plot area to clip the plots
	CPPlotGroup *thePlotGroup = self.plotGroup;
	if ( thePlotGroup ) {
		thePlotGroup.bounds = self.bounds;
		thePlotGroup.position = CGPointZero;
	}
}

#pragma mark -
#pragma mark Layer ordering

-(void)updateLayerOrder
{
	CPGraphLayerType *buLayerOrder = self.bottomUpLayerOrder;
	for ( int i = 0; i < kCPNumberOfLayers; i++ ) {
		*(buLayerOrder++) = i;
	}
	
	NSArray *tdLayerOrder = self.topDownLayerOrder;
	if ( tdLayerOrder ) {
		buLayerOrder = self.bottomUpLayerOrder;
		
		for ( NSUInteger layerIndex = 0; layerIndex < [tdLayerOrder count]; layerIndex++ ) {
			CPGraphLayerType layerType = [[tdLayerOrder objectAtIndex:layerIndex] intValue];
			NSUInteger i = kCPNumberOfLayers - layerIndex - 1;
			while ( (i >= 0) && (buLayerOrder[i] != layerType) ) {
				i--;
			}
			while ( (i >= 0) && (i < kCPNumberOfLayers - layerIndex - 1) ) {
				buLayerOrder[i] = buLayerOrder[i + 1];
				i++;
			}
			buLayerOrder[kCPNumberOfLayers - layerIndex - 1] = layerType;
		}
	}
	
	// force the layer hierarchy to update
	self.updatingLayers = YES;
	self.minorGridLineGroup = self.minorGridLineGroup;
	self.majorGridLineGroup = self.majorGridLineGroup;
	self.axisSet = self.axisSet;
	self.plotGroup = self.plotGroup;
	self.axisLabelGroup = self.axisLabelGroup;
	self.axisTitleGroup = self.axisTitleGroup;
	self.updatingLayers = NO;
}

-(unsigned)indexForLayerType:(CPGraphLayerType)layerType
{
	CPGraphLayerType *buLayerOrder = self.bottomUpLayerOrder;
	unsigned index = 0;
	
	for ( NSInteger i = 0; i < kCPNumberOfLayers; i++ ) {
		if ( buLayerOrder[i] == layerType ) {
			break;
		}
		switch ( buLayerOrder[i] ) {
			case CPGraphLayerTypeMinorGridLines:
				if ( self.minorGridLineGroup ) index++;
				break;
			case CPGraphLayerTypeMajorGridLines:
				if ( self.majorGridLineGroup ) index++;
				break;
			case CPGraphLayerTypeAxisLines:
				if ( self.axisSet ) index++;
				break;
			case CPGraphLayerTypePlots:
				if ( self.plotGroup ) index++;
				break;
			case CPGraphLayerTypeAxisLabels:
				if ( self.axisLabelGroup ) index++;
				break;
			case CPGraphLayerTypeAxisTitles:
				if ( self.axisTitleGroup ) index++;
				break;
		}
	}
	NSLog(@"index for layer type %d = %u", layerType, index);
	return index;
}

#pragma mark -
#pragma mark Accessors

-(CPLineStyle *)borderLineStyle
{
	return self.axisSet.borderLineStyle;
}

-(void)setBorderLineStyle:(CPLineStyle *)newLineStyle
{
	self.axisSet.borderLineStyle = newLineStyle;
}

-(void)setMinorGridLineGroup:(CPLayer *)newGridLines
{
	if ( (newGridLines != minorGridLineGroup) || self.isUpdatingLayers ) {
		[minorGridLineGroup removeFromSuperlayer];
		[newGridLines retain];
		[minorGridLineGroup release];
		minorGridLineGroup = newGridLines;
		if ( minorGridLineGroup ) {
			[self insertSublayer:minorGridLineGroup atIndex:[self indexForLayerType:CPGraphLayerTypeMinorGridLines]];
		}
        [self setNeedsLayout];
	}	
}

-(void)setMajorGridLineGroup:(CPLayer *)newGridLines
{
	if ( (newGridLines != majorGridLineGroup) || self.isUpdatingLayers ) {
		[majorGridLineGroup removeFromSuperlayer];
		[newGridLines retain];
		[majorGridLineGroup release];
		majorGridLineGroup = newGridLines;
		if ( majorGridLineGroup ) {
			[self insertSublayer:majorGridLineGroup atIndex:[self indexForLayerType:CPGraphLayerTypeMajorGridLines]];
		}
        [self setNeedsLayout];
	}	
}

-(void)setAxisSet:(CPAxisSet *)newAxisSet
{
	if ( (newAxisSet != axisSet) || self.isUpdatingLayers ) {
		[axisSet removeFromSuperlayer];
		[newAxisSet retain];
		[axisSet release];
		axisSet = newAxisSet;
		if ( axisSet ) {
			[self insertSublayer:axisSet atIndex:[self indexForLayerType:CPGraphLayerTypeAxisLines]];
			for ( CPAxis *axis in axisSet.axes ) {
				axis.plotArea = self;
			}
		}
        [self setNeedsLayout];
	}
}

-(void)setPlotGroup:(CPPlotGroup *)newPlotGroup
{
	if ( (newPlotGroup != plotGroup) || self.isUpdatingLayers ) {
		[plotGroup removeFromSuperlayer];
		[newPlotGroup retain];
		[plotGroup release];
		plotGroup = newPlotGroup;
		if ( plotGroup ) {
			[self insertSublayer:plotGroup atIndex:[self indexForLayerType:CPGraphLayerTypePlots]];
		}
        [self setNeedsLayout];
	}	
}

-(void)setAxisLabelGroup:(CPAxisLabelGroup *)newAxisLabelGroup
{
	if ( (newAxisLabelGroup != axisLabelGroup) || self.isUpdatingLayers ) {
		[axisLabelGroup removeFromSuperlayer];
		[newAxisLabelGroup retain];
		[axisLabelGroup release];
		axisLabelGroup = newAxisLabelGroup;
		if ( axisLabelGroup ) {
			[self insertSublayer:axisLabelGroup atIndex:[self indexForLayerType:CPGraphLayerTypeAxisLabels]];
		}
        [self setNeedsLayout];
	}	
}

-(void)setAxisTitleGroup:(CPAxisLabelGroup *)newAxisTitleGroup
{
	if ( (newAxisTitleGroup != axisTitleGroup) || self.isUpdatingLayers ) {
		[axisTitleGroup removeFromSuperlayer];
		[newAxisTitleGroup retain];
		[axisTitleGroup release];
		axisTitleGroup = newAxisTitleGroup;
		if ( axisTitleGroup ) {
			[self insertSublayer:axisTitleGroup atIndex:[self indexForLayerType:CPGraphLayerTypeAxisTitles]];
		}
        [self setNeedsLayout];
	}	
}

-(void)setTopDownLayerOrder:(NSArray *)newArray
{
	if ( newArray != topDownLayerOrder) {
		[topDownLayerOrder release];
		topDownLayerOrder = [newArray retain];
		[self updateLayerOrder];
	}
}

@end
