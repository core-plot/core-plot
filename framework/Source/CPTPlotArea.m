#import "CPTPlotArea.h"

#import "CPTAxis.h"
#import "CPTAxisLabelGroup.h"
#import "CPTAxisSet.h"
#import "CPTFill.h"
#import "CPTGridLineGroup.h"
#import "CPTLineStyle.h"
#import "CPTPlotGroup.h"

static const size_t kCPTNumberOfLayers = 6; // number of primary layers to arrange

/// @cond
@interface CPTPlotArea()

@property (nonatomic, readwrite, assign) CPTGraphLayerType *bottomUpLayerOrder;
@property (nonatomic, readwrite, assign, getter = isUpdatingLayers) BOOL updatingLayers;

-(void)updateLayerOrder;
-(unsigned)indexForLayerType:(CPTGraphLayerType)layerType;

@end

/// @endcond

#pragma mark -

/** @brief A layer representing the actual plotting area of a graph.
 *
 *  All plots are drawn inside this area while axes, titles, and borders may fall outside.
 *  The layers are arranged so that the graph elements are drawn in the following order:
 *  -# Background fill
 *  -# Minor grid lines
 *  -# Major grid lines
 *  -# Background border
 *  -# Axis lines with major and minor tick marks
 *  -# Plots
 *  -# Axis labels
 *  -# Axis titles
 **/
@implementation CPTPlotArea

/** @property CPTGridLineGroup *minorGridLineGroup
 *  @brief The parent layer for all minor grid lines.
 **/
@synthesize minorGridLineGroup;

/** @property CPTGridLineGroup *majorGridLineGroup
 *  @brief The parent layer for all major grid lines.
 **/
@synthesize majorGridLineGroup;

/** @property CPTAxisSet *axisSet
 *  @brief The axis set.
 **/
@synthesize axisSet;

/** @property CPTPlotGroup *plotGroup
 *  @brief The plot group.
 **/
@synthesize plotGroup;

/** @property CPTAxisLabelGroup *axisLabelGroup
 *  @brief The parent layer for all axis labels.
 **/
@synthesize axisLabelGroup;

/** @property CPTAxisLabelGroup *axisTitleGroup
 *  @brief The parent layer for all axis titles.
 **/
@synthesize axisTitleGroup;

/** @property NSArray *topDownLayerOrder
 *  @brief An array of graph layers to be drawn in an order other than the default.
 *
 *  The array should reference the layers using the constants defined in #CPTGraphLayerType.
 *  Layers should be specified in order starting from the top layer.
 *  Only the layers drawn out of the default order need be specified; all others will
 *  automatically be placed at the bottom of the view in their default order.
 *
 *  If this property is @nil, the layers will be drawn in the default order (bottom to top):
 *  -# Minor grid lines
 *  -# Major grid lines
 *  -# Axis lines, including the tick marks
 *  -# Plots
 *  -# Axis labels
 *  -# Axis titles
 *
 *  Example usage:
 *  @code
 *  [graph setTopDownLayerOrder:[NSArray arrayWithObjects:
 *      [NSNumber numberWithInt:CPTGraphLayerTypePlots],
 *      [NSNumber numberWithInt:CPTGraphLayerTypeAxisLabels],
 *      [NSNumber numberWithInt:CPTGraphLayerTypeMajorGridLines],
 *      ..., nil]];
 *  @endcode
 **/
@synthesize topDownLayerOrder;

/** @property CPTLineStyle *borderLineStyle
 *  @brief The line style for the layer border.
 *  If @nil, the border is not drawn.
 **/
@dynamic borderLineStyle;

/** @property CPTFill *fill
 *  @brief The fill for the layer background.
 *  If @nil, the layer background is not filled.
 **/
@synthesize fill;

// Private properties
@synthesize bottomUpLayerOrder;
@synthesize updatingLayers;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPlotArea object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref minorGridLineGroup = @nil
 *  - @ref majorGridLineGroup = @nil
 *  - @ref axisSet = @nil
 *  - @ref plotGroup = @nil
 *  - @ref axisLabelGroup = @nil
 *  - @ref axisTitleGroup = @nil
 *  - @ref fill = @nil
 *  - @ref topDownLayerOrder = @nil
 *  - @ref plotGroup = a new CPTPlotGroup with the same frame rectangle
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTPlotArea object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        minorGridLineGroup = nil;
        majorGridLineGroup = nil;
        axisSet            = nil;
        plotGroup          = nil;
        axisLabelGroup     = nil;
        axisTitleGroup     = nil;
        fill               = nil;
        topDownLayerOrder  = nil;
        bottomUpLayerOrder = malloc( kCPTNumberOfLayers * sizeof(CPTGraphLayerType) );
        [self updateLayerOrder];

        CPTPlotGroup *newPlotGroup = [(CPTPlotGroup *)[CPTPlotGroup alloc] initWithFrame:newFrame];
        self.plotGroup = newPlotGroup;
        [newPlotGroup release];

        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTPlotArea *theLayer = (CPTPlotArea *)layer;

        minorGridLineGroup = [theLayer->minorGridLineGroup retain];
        majorGridLineGroup = [theLayer->majorGridLineGroup retain];
        axisSet            = [theLayer->axisSet retain];
        plotGroup          = [theLayer->plotGroup retain];
        axisLabelGroup     = [theLayer->axisLabelGroup retain];
        axisTitleGroup     = [theLayer->axisTitleGroup retain];
        fill               = [theLayer->fill retain];
        topDownLayerOrder  = [theLayer->topDownLayerOrder retain];
        bottomUpLayerOrder = malloc( kCPTNumberOfLayers * sizeof(CPTGraphLayerType) );
        memcpy( bottomUpLayerOrder, theLayer->bottomUpLayerOrder, kCPTNumberOfLayers * sizeof(CPTGraphLayerType) );
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

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.minorGridLineGroup forKey:@"CPTPlotArea.minorGridLineGroup"];
    [coder encodeObject:self.majorGridLineGroup forKey:@"CPTPlotArea.majorGridLineGroup"];
    [coder encodeObject:self.axisSet forKey:@"CPTPlotArea.axisSet"];
    [coder encodeObject:self.plotGroup forKey:@"CPTPlotArea.plotGroup"];
    [coder encodeObject:self.axisLabelGroup forKey:@"CPTPlotArea.axisLabelGroup"];
    [coder encodeObject:self.axisTitleGroup forKey:@"CPTPlotArea.axisTitleGroup"];
    [coder encodeObject:self.fill forKey:@"CPTPlotArea.fill"];
    [coder encodeObject:self.topDownLayerOrder forKey:@"CPTPlotArea.topDownLayerOrder"];

    // No need to archive these properties:
    // bottomUpLayerOrder
    // updatingLayers
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        minorGridLineGroup = [[coder decodeObjectForKey:@"CPTPlotArea.minorGridLineGroup"] retain];
        majorGridLineGroup = [[coder decodeObjectForKey:@"CPTPlotArea.majorGridLineGroup"] retain];
        axisSet            = [[coder decodeObjectForKey:@"CPTPlotArea.axisSet"] retain];
        plotGroup          = [[coder decodeObjectForKey:@"CPTPlotArea.plotGroup"] retain];
        axisLabelGroup     = [[coder decodeObjectForKey:@"CPTPlotArea.axisLabelGroup"] retain];
        axisTitleGroup     = [[coder decodeObjectForKey:@"CPTPlotArea.axisTitleGroup"] retain];
        fill               = [[coder decodeObjectForKey:@"CPTPlotArea.fill"] copy];
        topDownLayerOrder  = [[coder decodeObjectForKey:@"CPTPlotArea.topDownLayerOrder"] retain];

        bottomUpLayerOrder = malloc( kCPTNumberOfLayers * sizeof(CPTGraphLayerType) );
        [self updateLayerOrder];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    [super renderAsVectorInContext:context];

    BOOL useMask = self.masksToBounds;
    self.masksToBounds = YES;
    CGContextSaveGState(context);

    CGPathRef maskPath = self.maskingPath;
    if ( maskPath ) {
        CGContextBeginPath(context);
        CGContextAddPath(context, maskPath);
        CGContextClip(context);
    }

    [self.fill fillRect:self.bounds inContext:context];

    NSArray *theAxes = self.axisSet.axes;

    for ( CPTAxis *axis in theAxes ) {
        [axis drawBackgroundBandsInContext:context];
    }
    for ( CPTAxis *axis in theAxes ) {
        [axis drawBackgroundLimitsInContext:context];
    }

    CGContextRestoreGState(context);
    self.masksToBounds = useMask;
}

/// @endcond

#pragma mark -
#pragma mark Layout

/// @name Layout
/// @{

/**
 *  @brief Updates the layout of all sublayers. Sublayers fill the super layer&rsquo;s bounds
 *  except for the @ref plotGroup, which will fill the receiver&rsquo;s bounds.
 *
 *  This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask.
 *  Subclasses should override this method to provide a different layout of their own sublayers.
 **/
-(void)layoutSublayers
{
    [super layoutSublayers];

    CALayer *superlayer   = self.superlayer;
    CGRect sublayerBounds = [self convertRect:superlayer.bounds fromLayer:superlayer];
    sublayerBounds.origin = CGPointZero;
    CGPoint sublayerPosition = [self convertPoint:self.bounds.origin toLayer:superlayer];
    sublayerPosition = CPTPointMake(-sublayerPosition.x, -sublayerPosition.y);

    NSSet *excludedLayers = [self sublayersExcludedFromAutomaticLayout];
    for ( CALayer *subLayer in self.sublayers ) {
        if ( [excludedLayers containsObject:subLayer] ) {
            continue;
        }
        subLayer.frame = CPTRectMake(sublayerPosition.x, sublayerPosition.y, sublayerBounds.size.width, sublayerBounds.size.height);
    }

    // make the plot group the same size as the plot area to clip the plots
    CPTPlotGroup *thePlotGroup = self.plotGroup;
    if ( thePlotGroup ) {
        CGSize selfBoundsSize = self.bounds.size;
        thePlotGroup.frame = CPTRectMake(0.0, 0.0, selfBoundsSize.width, selfBoundsSize.height);
    }
}

/// @}

#pragma mark -
#pragma mark Layer ordering

/// @cond

-(void)updateLayerOrder
{
    CPTGraphLayerType *buLayerOrder = self.bottomUpLayerOrder;

    for ( size_t i = 0; i < kCPTNumberOfLayers; i++ ) {
        *(buLayerOrder++) = (CPTGraphLayerType)i;
    }

    NSArray *tdLayerOrder = self.topDownLayerOrder;
    if ( tdLayerOrder ) {
        buLayerOrder = self.bottomUpLayerOrder;

        for ( NSUInteger layerIndex = 0; layerIndex < [tdLayerOrder count]; layerIndex++ ) {
            CPTGraphLayerType layerType = (CPTGraphLayerType)[[tdLayerOrder objectAtIndex:layerIndex] intValue];
            NSUInteger i                = kCPTNumberOfLayers - layerIndex - 1;
            while ( buLayerOrder[i] != layerType ) {
                if ( i == 0 ) {
                    break;
                }
                i--;
            }
            while ( i < kCPTNumberOfLayers - layerIndex - 1 ) {
                buLayerOrder[i] = buLayerOrder[i + 1];
                i++;
            }
            buLayerOrder[kCPTNumberOfLayers - layerIndex - 1] = layerType;
        }
    }

    // force the layer hierarchy to update
    self.updatingLayers     = YES;
    self.minorGridLineGroup = self.minorGridLineGroup;
    self.majorGridLineGroup = self.majorGridLineGroup;
    self.axisSet            = self.axisSet;
    self.plotGroup          = self.plotGroup;
    self.axisLabelGroup     = self.axisLabelGroup;
    self.axisTitleGroup     = self.axisTitleGroup;
    self.updatingLayers     = NO;
}

-(unsigned)indexForLayerType:(CPTGraphLayerType)layerType
{
    CPTGraphLayerType *buLayerOrder = self.bottomUpLayerOrder;
    unsigned idx                    = 0;

    for ( size_t i = 0; i < kCPTNumberOfLayers; i++ ) {
        if ( buLayerOrder[i] == layerType ) {
            break;
        }
        switch ( buLayerOrder[i] ) {
            case CPTGraphLayerTypeMinorGridLines:
                if ( self.minorGridLineGroup ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypeMajorGridLines:
                if ( self.majorGridLineGroup ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypeAxisLines:
                if ( self.axisSet ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypePlots:
                if ( self.plotGroup ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypeAxisLabels:
                if ( self.axisLabelGroup ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypeAxisTitles:
                if ( self.axisTitleGroup ) {
                    idx++;
                }
                break;
        }
    }
    return idx;
}

/// @endcond

#pragma mark -
#pragma mark Axis set layer management

/** @brief Checks for the presence of the specified layer group and adds or removes it as needed.
 *  @param layerType The layer type being updated.
 **/
-(void)updateAxisSetLayersForType:(CPTGraphLayerType)layerType
{
    BOOL needsLayer        = NO;
    CPTAxisSet *theAxisSet = self.axisSet;

    for ( CPTAxis *axis in theAxisSet.axes ) {
        switch ( layerType ) {
            case CPTGraphLayerTypeMinorGridLines:
                if ( axis.minorGridLineStyle ) {
                    needsLayer = YES;
                }
                break;

            case CPTGraphLayerTypeMajorGridLines:
                if ( axis.majorGridLineStyle ) {
                    needsLayer = YES;
                }
                break;

            case CPTGraphLayerTypeAxisLabels:
                if ( axis.axisLabels.count > 0 ) {
                    needsLayer = YES;
                }
                break;

            case CPTGraphLayerTypeAxisTitles:
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
            case CPTGraphLayerTypeMinorGridLines:
                self.minorGridLineGroup = nil;
                break;

            case CPTGraphLayerTypeMajorGridLines:
                self.majorGridLineGroup = nil;
                break;

            case CPTGraphLayerTypeAxisLabels:
                self.axisLabelGroup = nil;
                break;

            case CPTGraphLayerTypeAxisTitles:
                self.axisTitleGroup = nil;
                break;

            default:
                break;
        }
    }
}

/** @brief Ensures that a group layer is set for the given layer type.
 *  @param layerType The layer type being updated.
 **/
-(void)setAxisSetLayersForType:(CPTGraphLayerType)layerType
{
    switch ( layerType ) {
        case CPTGraphLayerTypeMinorGridLines:
            if ( !self.minorGridLineGroup ) {
                CPTGridLineGroup *newGridLineGroup = [(CPTGridLineGroup *)[CPTGridLineGroup alloc] initWithFrame:self.bounds];
                self.minorGridLineGroup = newGridLineGroup;
                [newGridLineGroup release];
            }
            break;

        case CPTGraphLayerTypeMajorGridLines:
            if ( !self.majorGridLineGroup ) {
                CPTGridLineGroup *newGridLineGroup = [(CPTGridLineGroup *)[CPTGridLineGroup alloc] initWithFrame:self.bounds];
                self.majorGridLineGroup = newGridLineGroup;
                [newGridLineGroup release];
            }
            break;

        case CPTGraphLayerTypeAxisLabels:
            if ( !self.axisLabelGroup ) {
                CPTAxisLabelGroup *newAxisLabelGroup = [(CPTAxisLabelGroup *)[CPTAxisLabelGroup alloc] initWithFrame:self.bounds];
                self.axisLabelGroup = newAxisLabelGroup;
                [newAxisLabelGroup release];
            }
            break;

        case CPTGraphLayerTypeAxisTitles:
            if ( !self.axisTitleGroup ) {
                CPTAxisLabelGroup *newAxisTitleGroup = [(CPTAxisLabelGroup *)[CPTAxisLabelGroup alloc] initWithFrame:self.bounds];
                self.axisTitleGroup = newAxisTitleGroup;
                [newAxisTitleGroup release];
            }
            break;

        default:
            break;
    }
}

/** @brief Computes the sublayer index for the given layer type and axis.
 *  @param axis The axis of interest.
 *  @param layerType The layer type being updated.
 *  @return The sublayer index for the given layer type.
 **/
-(unsigned)sublayerIndexForAxis:(CPTAxis *)axis layerType:(CPTGraphLayerType)layerType
{
    unsigned idx = 0;

    for ( CPTAxis *currentAxis in self.axisSet.axes ) {
        if ( currentAxis == axis ) {
            break;
        }

        switch ( layerType ) {
            case CPTGraphLayerTypeMinorGridLines:
                if ( currentAxis.minorGridLineStyle ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypeMajorGridLines:
                if ( currentAxis.majorGridLineStyle ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypeAxisLabels:
                if ( currentAxis.axisLabels.count > 0 ) {
                    idx++;
                }
                break;

            case CPTGraphLayerTypeAxisTitles:
                if ( currentAxis.axisTitle ) {
                    idx++;
                }
                break;

            default:
                break;
        }
    }

    return idx;
}

#pragma mark -
#pragma mark Accessors

/// @cond

-(CPTLineStyle *)borderLineStyle
{
    return self.axisSet.borderLineStyle;
}

-(void)setBorderLineStyle:(CPTLineStyle *)newLineStyle
{
    self.axisSet.borderLineStyle = newLineStyle;
}

-(void)setFill:(CPTFill *)newFill
{
    if ( newFill != fill ) {
        [fill release];
        fill = [newFill copy];
        [self setNeedsDisplay];
    }
}

-(void)setMinorGridLineGroup:(CPTGridLineGroup *)newGridLines
{
    if ( (newGridLines != minorGridLineGroup) || self.isUpdatingLayers ) {
        [minorGridLineGroup removeFromSuperlayer];
        [newGridLines retain];
        [minorGridLineGroup release];
        minorGridLineGroup = newGridLines;
        if ( minorGridLineGroup ) {
            minorGridLineGroup.plotArea = self;
            minorGridLineGroup.major    = NO;
            [self insertSublayer:minorGridLineGroup atIndex:[self indexForLayerType:CPTGraphLayerTypeMinorGridLines]];
        }
        [self setNeedsLayout];
    }
}

-(void)setMajorGridLineGroup:(CPTGridLineGroup *)newGridLines
{
    if ( (newGridLines != majorGridLineGroup) || self.isUpdatingLayers ) {
        [majorGridLineGroup removeFromSuperlayer];
        [newGridLines retain];
        [majorGridLineGroup release];
        majorGridLineGroup = newGridLines;
        if ( majorGridLineGroup ) {
            majorGridLineGroup.plotArea = self;
            majorGridLineGroup.major    = YES;
            [self insertSublayer:majorGridLineGroup atIndex:[self indexForLayerType:CPTGraphLayerTypeMajorGridLines]];
        }
        [self setNeedsLayout];
    }
}

-(void)setAxisSet:(CPTAxisSet *)newAxisSet
{
    if ( (newAxisSet != axisSet) || self.isUpdatingLayers ) {
        [axisSet removeFromSuperlayer];
        for ( CPTAxis *axis in axisSet.axes ) {
            axis.plotArea = nil;
        }

        [newAxisSet retain];
        [axisSet release];
        axisSet = newAxisSet;
        [self updateAxisSetLayersForType:CPTGraphLayerTypeMajorGridLines];
        [self updateAxisSetLayersForType:CPTGraphLayerTypeMinorGridLines];
        [self updateAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];
        [self updateAxisSetLayersForType:CPTGraphLayerTypeAxisTitles];

        if ( axisSet ) {
            [self insertSublayer:axisSet atIndex:[self indexForLayerType:CPTGraphLayerTypeAxisLines]];
            for ( CPTAxis *axis in axisSet.axes ) {
                axis.plotArea = self;
            }
        }
        [self setNeedsLayout];
    }
}

-(void)setPlotGroup:(CPTPlotGroup *)newPlotGroup
{
    if ( (newPlotGroup != plotGroup) || self.isUpdatingLayers ) {
        [plotGroup removeFromSuperlayer];
        [newPlotGroup retain];
        [plotGroup release];
        plotGroup = newPlotGroup;
        if ( plotGroup ) {
            [self insertSublayer:plotGroup atIndex:[self indexForLayerType:CPTGraphLayerTypePlots]];
        }
        [self setNeedsLayout];
    }
}

-(void)setAxisLabelGroup:(CPTAxisLabelGroup *)newAxisLabelGroup
{
    if ( (newAxisLabelGroup != axisLabelGroup) || self.isUpdatingLayers ) {
        [axisLabelGroup removeFromSuperlayer];
        [newAxisLabelGroup retain];
        [axisLabelGroup release];
        axisLabelGroup = newAxisLabelGroup;
        if ( axisLabelGroup ) {
            [self insertSublayer:axisLabelGroup atIndex:[self indexForLayerType:CPTGraphLayerTypeAxisLabels]];
        }
        [self setNeedsLayout];
    }
}

-(void)setAxisTitleGroup:(CPTAxisLabelGroup *)newAxisTitleGroup
{
    if ( (newAxisTitleGroup != axisTitleGroup) || self.isUpdatingLayers ) {
        [axisTitleGroup removeFromSuperlayer];
        [newAxisTitleGroup retain];
        [axisTitleGroup release];
        axisTitleGroup = newAxisTitleGroup;
        if ( axisTitleGroup ) {
            [self insertSublayer:axisTitleGroup atIndex:[self indexForLayerType:CPTGraphLayerTypeAxisTitles]];
        }
        [self setNeedsLayout];
    }
}

-(void)setTopDownLayerOrder:(NSArray *)newArray
{
    if ( newArray != topDownLayerOrder ) {
        [topDownLayerOrder release];
        topDownLayerOrder = [newArray retain];
        [self updateLayerOrder];
    }
}

/// @endcond

@end
