#import "CPAxis.h"
#import "CPAxisLabelGroup.h"
#import "CPAxisSet.h"
#import "CPFill.h"
#import "CPGridLineGroup.h"
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

		CPPlotGroup *newPlotGroup = [(CPPlotGroup *)[CPPlotGroup alloc] initWithFrame:newFrame];
		self.plotGroup = newPlotGroup;
		[newPlotGroup release];

		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPPlotArea *theLayer = (CPPlotArea *)layer;
		
		minorGridLineGroup = [theLayer->minorGridLineGroup retain];
		majorGridLineGroup = [theLayer->majorGridLineGroup retain];
		axisSet = [theLayer->axisSet retain];
		plotGroup = [theLayer->plotGroup retain];
		axisLabelGroup = [theLayer->axisLabelGroup retain];
		axisTitleGroup = [theLayer->axisTitleGroup retain];
		fill = [theLayer->fill retain];
		topDownLayerOrder = [theLayer->topDownLayerOrder retain];
		bottomUpLayerOrder = malloc(kCPNumberOfLayers * sizeof(CPGraphLayerType));
		memcpy(bottomUpLayerOrder, theLayer->bottomUpLayerOrder, kCPNumberOfLayers * sizeof(CPGraphLayerType));
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

-(void)finalize
{
	free(bottomUpLayerOrder);
	[super finalize];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	[super renderAsVectorInContext:context];
	
	[self.fill fillRect:self.bounds inContext:context];
	
	NSArray *theAxes = self.axisSet.axes;
	
	for ( CPAxis *axis in theAxes ) {
		[axis drawBackgroundBandsInContext:context];
	}
	for ( CPAxis *axis in theAxes ) {
		[axis drawBackgroundLimitsInContext:context];
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
	[super layoutSublayers];
    
	CALayer *superlayer = self.superlayer;
	CGRect sublayerBounds = [self convertRect:superlayer.bounds fromLayer:superlayer];
	sublayerBounds.origin = CGPointZero;
	CGPoint sublayerPosition = [self convertPoint:self.bounds.origin toLayer:superlayer];
	sublayerPosition = CGPointMake(-sublayerPosition.x, -sublayerPosition.y);
	
    NSSet *excludedLayers = [self sublayersExcludedFromAutomaticLayout];
	for (CALayer *subLayer in self.sublayers) {
    	if ( [excludedLayers containsObject:subLayer] ) continue;
		subLayer.frame = CGRectMake(sublayerPosition.x, sublayerPosition.y, sublayerBounds.size.width, sublayerBounds.size.height);
	}
	
	// make the plot group the same size as the plot area to clip the plots
	CPPlotGroup *thePlotGroup = self.plotGroup;
	if ( thePlotGroup ) {
		CGSize selfBoundsSize = self.bounds.size;
		thePlotGroup.frame = CGRectMake(0.0, 0.0, selfBoundsSize.width, selfBoundsSize.height);
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
			while ( buLayerOrder[i] != layerType ) {
				if ( i == 0 ) break;
				i--;
			}
			while ( i < kCPNumberOfLayers - layerIndex - 1 ) {
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
	return index;
}

#pragma mark -
#pragma mark Axis set layer management

/**	@brief Checks for the presence of the specified layer group and adds or removes it as needed.
 *	@param layerType The layer type being updated.
 **/
-(void)updateAxisSetLayersForType:(CPGraphLayerType)layerType
{
	BOOL needsLayer = NO;
	CPAxisSet *theAxisSet = self.axisSet;
	for ( CPAxis *axis in theAxisSet.axes ) {
		switch ( layerType ) {
			case CPGraphLayerTypeMinorGridLines:
				if ( axis.minorGridLineStyle ) {
					needsLayer = YES;
				}
				break;
			case CPGraphLayerTypeMajorGridLines:
				if ( axis.majorGridLineStyle ) {
					needsLayer = YES;
				}
				break;
			case CPGraphLayerTypeAxisLabels:
				if ( axis.axisLabels.count > 0 ) {
					needsLayer = YES;
				}
				break;
			case CPGraphLayerTypeAxisTitles:
				if ( axis.axisTitle ) {
					needsLayer = YES;
				}
				break;
			default:
				break;
		}
	}
	
	if ( needsLayer ) {
		[self setAxisSetLayersForType:layerType];
	}
	else {
		switch ( layerType ) {
			case CPGraphLayerTypeMinorGridLines:
				self.minorGridLineGroup = nil;
				break;
			case CPGraphLayerTypeMajorGridLines:
				self.majorGridLineGroup = nil;
				break;
			case CPGraphLayerTypeAxisLabels:
				self.axisLabelGroup = nil;
				break;
			case CPGraphLayerTypeAxisTitles:
				self.axisTitleGroup = nil;
				break;
			default:
				break;
		}
	}

}

/**	@brief Ensures that a group layer is set for the given layer type.
 *	@param layerType The layer type being updated.
 **/
-(void)setAxisSetLayersForType:(CPGraphLayerType)layerType
{
	switch ( layerType ) {
		case CPGraphLayerTypeMinorGridLines:
			if ( !self.minorGridLineGroup ) {
				CPGridLineGroup *newGridLineGroup = [(CPGridLineGroup *)[CPGridLineGroup alloc] initWithFrame:self.bounds];
				self.minorGridLineGroup = newGridLineGroup;
				[newGridLineGroup release];
			}
			break;
		case CPGraphLayerTypeMajorGridLines:
			if ( !self.majorGridLineGroup ) {
				CPGridLineGroup *newGridLineGroup = [(CPGridLineGroup *)[CPGridLineGroup alloc] initWithFrame:self.bounds];
				self.majorGridLineGroup = newGridLineGroup;
				[newGridLineGroup release];
			}
			break;
		case CPGraphLayerTypeAxisLabels:
			if ( !self.axisLabelGroup ) {
				CPAxisLabelGroup *newAxisLabelGroup = [(CPAxisLabelGroup *)[CPAxisLabelGroup alloc] initWithFrame:self.bounds];
				self.axisLabelGroup = newAxisLabelGroup;
				[newAxisLabelGroup release];
			}
			break;
		case CPGraphLayerTypeAxisTitles:
			if ( !self.axisTitleGroup ) {
				CPAxisLabelGroup *newAxisTitleGroup = [(CPAxisLabelGroup *)[CPAxisLabelGroup alloc] initWithFrame:self.bounds];
				self.axisTitleGroup = newAxisTitleGroup;
				[newAxisTitleGroup release];
			}
			break;
		default:
			break;
	}
}

-(unsigned)sublayerIndexForAxis:(CPAxis *)axis layerType:(CPGraphLayerType)layerType
{
	unsigned index = 0;
	
	for ( CPAxis *currentAxis in self.graph.axisSet.axes ) {
		if ( currentAxis == axis ) break;
		
		switch ( layerType ) {
			case CPGraphLayerTypeMinorGridLines:
				if ( currentAxis.minorGridLineStyle ) index++;
				break;
			case CPGraphLayerTypeMajorGridLines:
				if ( currentAxis.majorGridLineStyle ) index++;
				break;
			case CPGraphLayerTypeAxisLabels:
				if ( currentAxis.axisLabels.count > 0 ) index++;
				break;
			case CPGraphLayerTypeAxisTitles:
				if ( currentAxis.axisTitle ) index++;
				break;
			default:
				break;
		}
	}
	
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

-(void)setMinorGridLineGroup:(CPGridLineGroup *)newGridLines
{
	if ( (newGridLines != minorGridLineGroup) || self.isUpdatingLayers ) {
		[minorGridLineGroup removeFromSuperlayer];
		[newGridLines retain];
		[minorGridLineGroup release];
		minorGridLineGroup = newGridLines;
		if ( minorGridLineGroup ) {
			minorGridLineGroup.plotArea = self;
			minorGridLineGroup.major = NO;
			[self insertSublayer:minorGridLineGroup atIndex:[self indexForLayerType:CPGraphLayerTypeMinorGridLines]];
		}
        [self setNeedsLayout];
	}	
}

-(void)setMajorGridLineGroup:(CPGridLineGroup *)newGridLines
{
	if ( (newGridLines != majorGridLineGroup) || self.isUpdatingLayers ) {
		[majorGridLineGroup removeFromSuperlayer];
		[newGridLines retain];
		[majorGridLineGroup release];
		majorGridLineGroup = newGridLines;
		if ( majorGridLineGroup ) {
			majorGridLineGroup.plotArea = self;
			majorGridLineGroup.major = YES;
			[self insertSublayer:majorGridLineGroup atIndex:[self indexForLayerType:CPGraphLayerTypeMajorGridLines]];
		}
        [self setNeedsLayout];
	}	
}

-(void)setAxisSet:(CPAxisSet *)newAxisSet
{
	if ( (newAxisSet != axisSet) || self.isUpdatingLayers ) {
		[axisSet removeFromSuperlayer];
		for ( CPAxis *axis in axisSet.axes ) {
			axis.plotArea = nil;
		}
		
		[newAxisSet retain];
		[axisSet release];
		axisSet = newAxisSet;
		[self updateAxisSetLayersForType:CPGraphLayerTypeMajorGridLines];
		[self updateAxisSetLayersForType:CPGraphLayerTypeMinorGridLines];
		[self updateAxisSetLayersForType:CPGraphLayerTypeAxisLabels];
		[self updateAxisSetLayersForType:CPGraphLayerTypeAxisTitles];
		
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
