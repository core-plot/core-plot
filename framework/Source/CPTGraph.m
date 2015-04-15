#import "CPTGraph.h"

#import "CPTAxis.h"
#import "CPTAxisSet.h"
#import "CPTExceptions.h"
#import "CPTGraphHostingView.h"
#import "CPTLayerAnnotation.h"
#import "CPTLegend.h"
#import "CPTMutableTextStyle.h"
#import "CPTPlot.h"
#import "CPTPlotArea.h"
#import "CPTPlotAreaFrame.h"
#import "CPTPlotGroup.h"
#import "CPTPlotSpace.h"
#import "CPTTextLayer.h"
#import "CPTTheme.h"
#import "NSCoderExtensions.h"

/** @defgroup graphAnimation Graphs
 *  @brief Graph properties that can be animated using Core Animation.
 *  @if MacOnly
 *  @since Custom layer property animation is supported on MacOS 10.6 and later.
 *  @endif
 *  @ingroup animation
 **/

NSString *const CPTGraphNeedsRedrawNotification        = @"CPTGraphNeedsRedrawNotification";
NSString *const CPTGraphDidAddPlotSpaceNotification    = @"CPTGraphDidAddPlotSpaceNotification";
NSString *const CPTGraphDidRemovePlotSpaceNotification = @"CPTGraphDidRemovePlotSpaceNotification";
NSString *const CPTGraphPlotSpaceNotificationKey       = @"CPTGraphPlotSpaceNotificationKey";

/// @cond
@interface CPTGraph()

@property (nonatomic, readwrite, strong) NSMutableArray *plots;
@property (nonatomic, readwrite, strong) NSMutableArray *plotSpaces;
@property (nonatomic, readwrite, strong) CPTLayerAnnotation *titleAnnotation;
@property (nonatomic, readwrite, strong) CPTLayerAnnotation *legendAnnotation;
@property (nonatomic, readwrite, assign) BOOL inTitleUpdate;

-(void)plotSpaceMappingDidChange:(NSNotification *)notif;
-(CGPoint)contentAnchorForRectAnchor:(CPTRectAnchor)anchor;

@end

/// @endcond

#pragma mark -

/** @brief An abstract graph class.
 *
 *  The graph is the top-level view container for a Core Plot graph. It should be hosted
 *  inside a CPTGraphHostingView.
 *
 *  A graph contains a single plot area frame (CPTPlotAreaFrame), which is the container for all of the
 *  graph elements. Use the padding properties on the graph to position the plot area frame
 *  inside the graph. All graph elements, except for titles, legends, and other annotations
 *  attached directly to the graph itself are clipped to the plot area frame.
 *
 *  The plot area (CPTPlotArea) sits inside the plot area frame. Use the padding properties on the plot
 *  area frame to position the plot area inside the plot area frame.
 *  All plots are drawn inside this area while axes, titles, and borders may fall outside.
 *  Use a plot space (CPTPlotSpace) to control the mapping between data values and
 *  plotting coordinates in the plot area. One plot space is automatically provided with
 *  a new graph; more may be added as needed.
 *
 *  @see See @ref graphAnimation "Graphs" for a list of animatable properties.
 **/
@implementation CPTGraph

/** @property __cpt_weak CPTGraphHostingView *hostingView
 *  @brief The hosting view that contains the graph.
 **/
@synthesize hostingView;

/** @property CPTAxisSet *axisSet
 *  @brief The axis set.
 **/
@dynamic axisSet;

/** @property CPTPlotAreaFrame *plotAreaFrame
 *  @brief The plot area frame.
 **/
@synthesize plotAreaFrame;

/// @cond

/** @property NSMutableArray *plots
 *  @brief An array of all plots associated with the graph.
 **/
@synthesize plots;

/** @property NSMutableArray *plotSpaces
 *  @brief An array of all plot spaces associated with the graph.
 **/
@synthesize plotSpaces;

/// @endcond

/** @property CPTPlotSpace *defaultPlotSpace
 *  @brief The default plot space.
 **/
@dynamic defaultPlotSpace;

/** @property NSArray *topDownLayerOrder
 *  @brief An array of graph layers to be drawn in an order other than the default.
 *  @see CPTPlotArea @link CPTPlotArea::topDownLayerOrder topDownLayerOrder @endlink property.
 **/
@dynamic topDownLayerOrder;

/** @property NSString *title
 *  @brief The title string.
 *
 *  Assigning a new value to this property also sets the value of the @ref attributedTitle property to @nil.
 **/
@synthesize title;

/** @property NSAttributedString *attributedTitle
 *  @brief The styled title string.
 *
 *  Assigning a new value to this property also sets the value of the @ref title property to the
 *  same string without formatting information. It also replaces the @ref titleTextStyle with
 *  a style matching the first position (location @num{0}) of the styled title.
 *  Default is @nil.
 **/
@synthesize attributedTitle;

/** @property CPTTextStyle *titleTextStyle
 *  @brief The text style of the title.
 *
 *  Assigning a new value to this property also sets the value of the @ref attributedTitle property to @nil.
 **/
@synthesize titleTextStyle;

/** @property CPTRectAnchor titlePlotAreaFrameAnchor
 *  @brief The location of the title with respect to the plot area frame.
 *  Default is #CPTRectAnchorTop.
 **/
@synthesize titlePlotAreaFrameAnchor;

/** @property CGPoint titleDisplacement
 *  @brief A vector giving the displacement of the title from the edge location.
 *  @ingroup graphAnimation
 **/
@synthesize titleDisplacement;

/** @property CPTLegend *legend
 *  @brief The graph legend.
 *  Setting this property will automatically anchor the legend to the graph and position it
 *  using the @ref legendAnchor and @ref legendDisplacement properties. This is a convenience property
 *  only—the legend may be inserted in the layer tree and positioned like any other CPTLayer
 *  if more flexibility is needed.
 **/
@synthesize legend;

/** @property CPTRectAnchor legendAnchor
 *  @brief The location of the legend with respect to the graph frame.
 *  Default is #CPTRectAnchorBottom.
 **/
@synthesize legendAnchor;

/** @property CGPoint legendDisplacement
 *  @brief A vector giving the displacement of the legend from the edge location.
 *  @ingroup graphAnimation
 **/
@synthesize legendDisplacement;

@synthesize titleAnnotation;
@synthesize legendAnnotation;
@synthesize inTitleUpdate;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTGraph object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref hostingView = @nil
 *  - @ref title = @nil
 *  - @ref attributedTitle = @nil
 *  - @ref titlePlotAreaFrameAnchor = #CPTRectAnchorTop
 *  - @ref titleTextStyle = default text style
 *  - @ref titleDisplacement = (@num{0.0}, @num{0.0})
 *  - @ref legend = @nil
 *  - @ref legendAnchor = #CPTRectAnchorBottom
 *  - @ref legendDisplacement = (@num{0.0}, @num{0.0})
 *  - @ref paddingLeft = @num{20.0}
 *  - @ref paddingTop = @num{20.0}
 *  - @ref paddingRight = @num{20.0}
 *  - @ref paddingBottom = @num{20.0}
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  The new graph will have a @ref plotAreaFrame with a frame equal to the graph&rsquo;s bounds,
 *  a @ref defaultPlotSpace created with the @link CPTGraph::newPlotSpace -newPlotSpace @endlink method,
 *  and an @ref axisSet created with the @link CPTGraph::newAxisSet -newAxisSet @endlink method.
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTGraph object.
 **/
-(instancetype)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        hostingView = nil;
        plots       = [[NSMutableArray alloc] init];

        // Margins
        self.paddingLeft   = CPTFloat(20.0);
        self.paddingTop    = CPTFloat(20.0);
        self.paddingRight  = CPTFloat(20.0);
        self.paddingBottom = CPTFloat(20.0);

        // Plot area
        CPTPlotAreaFrame *newArea = [[CPTPlotAreaFrame alloc] initWithFrame:self.bounds];
        self.plotAreaFrame = newArea;

        // Plot spaces
        plotSpaces = [[NSMutableArray alloc] init];
        CPTPlotSpace *newPlotSpace = [self newPlotSpace];
        [self addPlotSpace:newPlotSpace];

        // Axis set
        CPTAxisSet *newAxisSet = [self newAxisSet];
        self.axisSet = newAxisSet;

        // Title
        title                    = nil;
        attributedTitle          = nil;
        titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        titleTextStyle           = [CPTTextStyle textStyle];
        titleDisplacement        = CGPointZero;
        titleAnnotation          = nil;

        // Legend
        legend             = nil;
        legendAnnotation   = nil;
        legendAnchor       = CPTRectAnchorBottom;
        legendDisplacement = CGPointZero;

        inTitleUpdate = NO;

        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/// @cond

-(instancetype)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTGraph *theLayer = (CPTGraph *)layer;

        hostingView              = theLayer->hostingView;
        plotAreaFrame            = theLayer->plotAreaFrame;
        plots                    = theLayer->plots;
        plotSpaces               = theLayer->plotSpaces;
        title                    = theLayer->title;
        attributedTitle          = theLayer->attributedTitle;
        titlePlotAreaFrameAnchor = theLayer->titlePlotAreaFrameAnchor;
        titleTextStyle           = theLayer->titleTextStyle;
        titleDisplacement        = theLayer->titleDisplacement;
        titleAnnotation          = theLayer->titleAnnotation;
        legend                   = theLayer->legend;
        legendAnnotation         = theLayer->legendAnnotation;
        legendAnchor             = theLayer->legendAnchor;
        legendDisplacement       = theLayer->legendDisplacement;
        inTitleUpdate            = theLayer->inTitleUpdate;
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeConditionalObject:self.hostingView forKey:@"CPTGraph.hostingView"];
    [coder encodeObject:self.plotAreaFrame forKey:@"CPTGraph.plotAreaFrame"];
    [coder encodeObject:self.plots forKey:@"CPTGraph.plots"];
    [coder encodeObject:self.plotSpaces forKey:@"CPTGraph.plotSpaces"];
    [coder encodeObject:self.title forKey:@"CPTGraph.title"];
    [coder encodeObject:self.attributedTitle forKey:@"CPTGraph.attributedTitle"];
    [coder encodeObject:self.titleTextStyle forKey:@"CPTGraph.titleTextStyle"];
    [coder encodeInteger:self.titlePlotAreaFrameAnchor forKey:@"CPTGraph.titlePlotAreaFrameAnchor"];
    [coder encodeCPTPoint:self.titleDisplacement forKey:@"CPTGraph.titleDisplacement"];
    [coder encodeObject:self.titleAnnotation forKey:@"CPTGraph.titleAnnotation"];
    [coder encodeObject:self.legend forKey:@"CPTGraph.legend"];
    [coder encodeObject:self.legendAnnotation forKey:@"CPTGraph.legendAnnotation"];
    [coder encodeInteger:self.legendAnchor forKey:@"CPTGraph.legendAnchor"];
    [coder encodeCPTPoint:self.legendDisplacement forKey:@"CPTGraph.legendDisplacement"];

    // No need to archive these properties:
    // inTitleUpdate
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        hostingView              = [coder decodeObjectForKey:@"CPTGraph.hostingView"];
        plotAreaFrame            = [coder decodeObjectForKey:@"CPTGraph.plotAreaFrame"];
        plots                    = [[coder decodeObjectForKey:@"CPTGraph.plots"] mutableCopy];
        plotSpaces               = [[coder decodeObjectForKey:@"CPTGraph.plotSpaces"] mutableCopy];
        title                    = [[coder decodeObjectForKey:@"CPTGraph.title"] copy];
        attributedTitle          = [[coder decodeObjectForKey:@"CPTGraph.attributedTitle"] copy];
        titleTextStyle           = [[coder decodeObjectForKey:@"CPTGraph.titleTextStyle"] copy];
        titlePlotAreaFrameAnchor = (CPTRectAnchor)[coder decodeIntegerForKey : @"CPTGraph.titlePlotAreaFrameAnchor"];
        titleDisplacement        = [coder decodeCPTPointForKey:@"CPTGraph.titleDisplacement"];
        titleAnnotation          = [coder decodeObjectForKey:@"CPTGraph.titleAnnotation"];
        legend                   = [coder decodeObjectForKey:@"CPTGraph.legend"];
        legendAnnotation         = [coder decodeObjectForKey:@"CPTGraph.legendAnnotation"];
        legendAnchor             = (CPTRectAnchor)[coder decodeIntegerForKey : @"CPTGraph.legendAnchor"];
        legendDisplacement       = [coder decodeCPTPointForKey:@"CPTGraph.legendDisplacement"];

        inTitleUpdate = NO;
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)layoutAndRenderInContext:(CGContextRef)context
{
    [self reloadDataIfNeeded];
    [self.axisSet.axes makeObjectsPerformSelector:@selector(relabel)];
    [super layoutAndRenderInContext:context];
}

/// @endcond

#pragma mark -
#pragma mark Animation

/// @cond

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
    static NSSet *keys               = nil;
    static dispatch_once_t onceToken = 0;

    dispatch_once(&onceToken, ^{
        keys = [NSSet setWithArray:@[@"titleDisplacement",
                                     @"legendDisplacement"]];
    });

    if ( [keys containsObject:aKey] ) {
        return YES;
    }
    else {
        return [super needsDisplayForKey:aKey];
    }
}

/// @endcond

#pragma mark -
#pragma mark Retrieving Plots

/**
 *  @brief Makes all plots reload their data.
 **/
-(void)reloadData
{
    [self.plots makeObjectsPerformSelector:@selector(reloadData)];
    [self.plotSpaces makeObjectsPerformSelector:@selector(removeAllCategories)];
}

/**
 *  @brief Makes all plots reload their data if their data cache is out of date.
 **/
-(void)reloadDataIfNeeded
{
    [self.plots makeObjectsPerformSelector:@selector(reloadDataIfNeeded)];
}

/** @brief All plots associated with the graph.
 *  @return An array of all plots associated with the graph.
 **/
-(NSArray *)allPlots
{
    return [NSArray arrayWithArray:self.plots];
}

/** @brief Gets the plot at the given index in the plot array.
 *  @param idx An index within the bounds of the plot array.
 *  @return The plot at the given index.
 **/
-(CPTPlot *)plotAtIndex:(NSUInteger)idx
{
    return (self.plots)[idx];
}

/** @brief Gets the plot with the given identifier from the plot array.
 *  @param identifier A plot identifier.
 *  @return The plot with the given identifier or @nil if it was not found.
 **/
-(CPTPlot *)plotWithIdentifier:(id<NSCopying>)identifier
{
    for ( CPTPlot *plot in self.plots ) {
        if ( [[plot identifier] isEqual:identifier] ) {
            return plot;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Organizing Plots

/** @brief Add a plot to the default plot space.
 *  @param plot The plot.
 **/
-(void)addPlot:(CPTPlot *)plot
{
    [self addPlot:plot toPlotSpace:self.defaultPlotSpace];
}

/** @brief Add a plot to the given plot space.
 *  @param plot The plot.
 *  @param space The plot space.
 **/
-(void)addPlot:(CPTPlot *)plot toPlotSpace:(CPTPlotSpace *)space
{
    if ( plot ) {
        [self.plots addObject:plot];
        plot.plotSpace = space;
        plot.graph     = self;
        [self.plotAreaFrame.plotGroup addPlot:plot];
    }
}

/** @brief Remove a plot from the graph.
 *  @param plot The plot to remove.
 **/
-(void)removePlot:(CPTPlot *)plot
{
    if ( [self.plots containsObject:plot] ) {
        plot.plotSpace = nil;
        plot.graph     = nil;
        [self.plotAreaFrame.plotGroup removePlot:plot];
        [self.plots removeObject:plot];
    }
    else {
        [NSException raise:CPTException format:@"Tried to remove CPTPlot which did not exist."];
    }
}

/** @brief Add a plot to the default plot space at the given index in the plot array.
 *  @param plot The plot.
 *  @param idx An index within the bounds of the plot array.
 **/
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)idx
{
    [self insertPlot:plot atIndex:idx intoPlotSpace:self.defaultPlotSpace];
}

/** @brief Add a plot to the given plot space at the given index in the plot array.
 *  @param plot The plot.
 *  @param idx An index within the bounds of the plot array.
 *  @param space The plot space.
 **/
-(void)insertPlot:(CPTPlot *)plot atIndex:(NSUInteger)idx intoPlotSpace:(CPTPlotSpace *)space
{
    if ( plot ) {
        [self.plots insertObject:plot atIndex:idx];
        plot.plotSpace = space;
        plot.graph     = self;
        [self.plotAreaFrame.plotGroup insertPlot:plot atIndex:idx];
    }
}

/** @brief Remove a plot from the graph.
 *  @param identifier The identifier of the plot to remove.
 **/
-(void)removePlotWithIdentifier:(id<NSCopying>)identifier
{
    CPTPlot *plotToRemove = [self plotWithIdentifier:identifier];

    if ( plotToRemove ) {
        plotToRemove.plotSpace = nil;
        plotToRemove.graph     = nil;
        [self.plotAreaFrame.plotGroup removePlot:plotToRemove];
        [self.plots removeObjectIdenticalTo:plotToRemove];
    }
}

#pragma mark -
#pragma mark Retrieving Plot Spaces

-(CPTPlotSpace *)defaultPlotSpace
{
    return self.plotSpaces.count > 0 ? (self.plotSpaces)[0] : nil;
}

/** @brief All plot spaces associated with the graph.
 *  @return An array of all plot spaces associated with the graph.
 **/
-(NSArray *)allPlotSpaces
{
    return [NSArray arrayWithArray:self.plotSpaces];
}

/** @brief Gets the plot space at the given index in the plot space array.
 *  @param idx An index within the bounds of the plot space array.
 *  @return The plot space at the given index.
 **/
-(CPTPlotSpace *)plotSpaceAtIndex:(NSUInteger)idx
{
    return self.plotSpaces.count > idx ? (self.plotSpaces)[idx] : nil;
}

/** @brief Gets the plot space with the given identifier from the plot space array.
 *  @param identifier A plot space identifier.
 *  @return The plot space with the given identifier or @nil if it was not found.
 **/
-(CPTPlotSpace *)plotSpaceWithIdentifier:(id<NSCopying>)identifier
{
    for ( CPTPlotSpace *plotSpace in self.plotSpaces ) {
        if ( [[plotSpace identifier] isEqual:identifier] ) {
            return plotSpace;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Set Plot Area

/// @cond

-(void)setPlotAreaFrame:(CPTPlotAreaFrame *)newArea
{
    if ( plotAreaFrame != newArea ) {
        plotAreaFrame.graph = nil;
        [plotAreaFrame removeFromSuperlayer];
        plotAreaFrame = newArea;
        [self addSublayer:newArea];
        plotAreaFrame.graph = self;
        for ( CPTPlotSpace *space in self.plotSpaces ) {
            space.graph = self;
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Organizing Plot Spaces

/** @brief Add a plot space to the graph.
 *  @param space The plot space.
 **/
-(void)addPlotSpace:(CPTPlotSpace *)space
{
    [self.plotSpaces addObject:space];
    space.graph = self;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(plotSpaceMappingDidChange:)
                                                 name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                               object:space];

    [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphDidAddPlotSpaceNotification
                                                        object:self
                                                      userInfo:@{ CPTGraphPlotSpaceNotificationKey: space }
    ];
}

/** @brief Remove a plot space from the graph.
 *  @param plotSpace The plot space.
 **/
-(void)removePlotSpace:(CPTPlotSpace *)plotSpace
{
    if ( [self.plotSpaces containsObject:plotSpace] ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:CPTPlotSpaceCoordinateMappingDidChangeNotification
                                                      object:plotSpace];

        // Remove space
        plotSpace.graph = nil;
        [self.plotSpaces removeObject:plotSpace];

        // Update axes that referenced space
        for ( CPTAxis *axis in self.axisSet.axes ) {
            if ( axis.plotSpace == plotSpace ) {
                axis.plotSpace = nil;
            }
        }

        [[NSNotificationCenter defaultCenter] postNotificationName:CPTGraphDidRemovePlotSpaceNotification
                                                            object:self
                                                          userInfo:@{ CPTGraphPlotSpaceNotificationKey: plotSpace }
        ];
    }
    else {
        [NSException raise:CPTException format:@"Tried to remove CPTPlotSpace which did not exist."];
    }
}

#pragma mark -
#pragma mark Coordinate Changes in Plot Spaces

/// @cond

-(void)plotSpaceMappingDidChange:(NSNotification *)notif
{
    CPTPlotSpace *plotSpace        = notif.object;
    BOOL backgroundBandsNeedRedraw = NO;

    for ( CPTAxis *axis in self.axisSet.axes ) {
        if ( axis.plotSpace == plotSpace ) {
            [axis setNeedsRelabel];
            [axis updateAxisTitle];

            if ( !backgroundBandsNeedRedraw ) {
                backgroundBandsNeedRedraw = (axis.alternatingBandFills.count > 0) || (axis.backgroundLimitBands.count > 0);
            }
        }
    }
    for ( CPTPlot *plot in self.plots ) {
        if ( plot.plotSpace == plotSpace ) {
            [plot setNeedsDisplay];
        }
    }
    if ( backgroundBandsNeedRedraw ) {
        [self.plotAreaFrame.plotArea setNeedsDisplay];
    }
}

/// @endcond

#pragma mark -
#pragma mark Axis Set

/// @cond

-(CPTAxisSet *)axisSet
{
    return self.plotAreaFrame.axisSet;
}

-(void)setAxisSet:(CPTAxisSet *)newSet
{
    self.plotAreaFrame.axisSet = newSet;
}

/// @endcond

#pragma mark -
#pragma mark Themes

/** @brief Apply a theme to style the graph.
 *  @param theme The theme object used to style the graph.
 **/
-(void)applyTheme:(CPTTheme *)theme
{
    [theme applyThemeToGraph:self];
}

#pragma mark -
#pragma mark Legend

/// @cond

-(void)setLegend:(CPTLegend *)newLegend
{
    if ( newLegend != legend ) {
        legend = newLegend;
        CPTLayerAnnotation *theLegendAnnotation = self.legendAnnotation;
        if ( legend ) {
            if ( theLegendAnnotation ) {
                theLegendAnnotation.contentLayer = legend;
            }
            else {
                CPTLayerAnnotation *newLegendAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:self];
                newLegendAnnotation.contentLayer       = legend;
                newLegendAnnotation.displacement       = self.legendDisplacement;
                newLegendAnnotation.rectAnchor         = self.legendAnchor;
                newLegendAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.legendAnchor];
                [self addAnnotation:newLegendAnnotation];
                self.legendAnnotation = newLegendAnnotation;
            }
        }
        else {
            if ( theLegendAnnotation ) {
                [self removeAnnotation:theLegendAnnotation];
                self.legendAnnotation = nil;
            }
        }
    }
}

-(void)setLegendAnchor:(CPTRectAnchor)newLegendAnchor
{
    if ( newLegendAnchor != legendAnchor ) {
        legendAnchor = newLegendAnchor;
        CPTLayerAnnotation *theLegendAnnotation = self.legendAnnotation;
        if ( theLegendAnnotation ) {
            theLegendAnnotation.rectAnchor         = newLegendAnchor;
            theLegendAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.legendAnchor];
        }
    }
}

-(void)setLegendDisplacement:(CGPoint)newLegendDisplacement
{
    if ( !CGPointEqualToPoint(newLegendDisplacement, legendDisplacement) ) {
        legendDisplacement                 = newLegendDisplacement;
        self.legendAnnotation.displacement = newLegendDisplacement;
    }
}

-(CGPoint)contentAnchorForRectAnchor:(CPTRectAnchor)anchor
{
    CGPoint contentAnchor = CGPointZero;

    switch ( anchor ) {
        case CPTRectAnchorBottomLeft:
            contentAnchor = CGPointZero;
            break;

        case CPTRectAnchorBottom:
            contentAnchor = CPTPointMake(0.5, 0.0);
            break;

        case CPTRectAnchorBottomRight:
            contentAnchor = CPTPointMake(1.0, 0.0);
            break;

        case CPTRectAnchorLeft:
            contentAnchor = CPTPointMake(0.0, 0.5);
            break;

        case CPTRectAnchorRight:
            contentAnchor = CPTPointMake(1.0, 0.5);
            break;

        case CPTRectAnchorTopLeft:
            contentAnchor = CPTPointMake(0.0, 1.0);
            break;

        case CPTRectAnchorTop:
            contentAnchor = CPTPointMake(0.5, 1.0);
            break;

        case CPTRectAnchorTopRight:
            contentAnchor = CPTPointMake(1.0, 1.0);
            break;

        case CPTRectAnchorCenter:
            contentAnchor = CPTPointMake(0.5, 0.5);
            break;
    }

    return contentAnchor;
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setPaddingLeft:(CGFloat)newPadding
{
    if ( newPadding != self.paddingLeft ) {
        [super setPaddingLeft:newPadding];
        [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setPaddingRight:(CGFloat)newPadding
{
    if ( newPadding != self.paddingRight ) {
        [super setPaddingRight:newPadding];
        [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setPaddingTop:(CGFloat)newPadding
{
    if ( newPadding != self.paddingTop ) {
        [super setPaddingTop:newPadding];
        [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(void)setPaddingBottom:(CGFloat)newPadding
{
    if ( newPadding != self.paddingBottom ) {
        [super setPaddingBottom:newPadding];
        [self.axisSet.axes makeObjectsPerformSelector:@selector(setNeedsDisplay)];
    }
}

-(NSArray *)topDownLayerOrder
{
    return self.plotAreaFrame.plotArea.topDownLayerOrder;
}

-(void)setTopDownLayerOrder:(NSArray *)newArray
{
    self.plotAreaFrame.plotArea.topDownLayerOrder = newArray;
}

-(void)setTitle:(NSString *)newTitle
{
    if ( newTitle != title ) {
        title = [newTitle copy];

        if ( !self.inTitleUpdate ) {
            self.inTitleUpdate   = YES;
            self.attributedTitle = nil;
            self.inTitleUpdate   = NO;

            CPTLayerAnnotation *theTitleAnnotation = self.titleAnnotation;

            if ( title ) {
                if ( theTitleAnnotation ) {
                    ( (CPTTextLayer *)theTitleAnnotation.contentLayer ).text = title;
                }
                else {
                    CPTLayerAnnotation *newTitleAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:self.plotAreaFrame];
                    CPTTextLayer *newTextLayer             = [[CPTTextLayer alloc] initWithText:title style:self.titleTextStyle];
                    newTitleAnnotation.contentLayer       = newTextLayer;
                    newTitleAnnotation.displacement       = self.titleDisplacement;
                    newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor;
                    newTitleAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.titlePlotAreaFrameAnchor];
                    [self addAnnotation:newTitleAnnotation];
                    self.titleAnnotation = newTitleAnnotation;
                }
            }
            else {
                if ( theTitleAnnotation ) {
                    [self removeAnnotation:theTitleAnnotation];
                    self.titleAnnotation = nil;
                }
            }
        }
    }
}

-(void)setAttributedTitle:(NSAttributedString *)newTitle
{
    if ( newTitle != attributedTitle ) {
        attributedTitle = [newTitle copy];

        if ( !self.inTitleUpdate ) {
            self.inTitleUpdate = YES;

            CPTLayerAnnotation *theTitleAnnotation = self.titleAnnotation;

            if ( attributedTitle ) {
                self.titleTextStyle = [CPTTextStyle textStyleWithAttributes:[attributedTitle attributesAtIndex:0
                                                                                                effectiveRange:NULL]];
                self.title = [attributedTitle.string copy];

                if ( theTitleAnnotation ) {
                    ( (CPTTextLayer *)theTitleAnnotation.contentLayer ).attributedText = attributedTitle;
                }
                else {
                    CPTLayerAnnotation *newTitleAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:self.plotAreaFrame];
                    CPTTextLayer *newTextLayer             = [[CPTTextLayer alloc] initWithAttributedText:attributedTitle];
                    newTitleAnnotation.contentLayer       = newTextLayer;
                    newTitleAnnotation.displacement       = self.titleDisplacement;
                    newTitleAnnotation.rectAnchor         = self.titlePlotAreaFrameAnchor;
                    newTitleAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:self.titlePlotAreaFrameAnchor];
                    [self addAnnotation:newTitleAnnotation];
                    self.titleAnnotation = newTitleAnnotation;
                }
            }
            else {
                self.titleTextStyle = nil;
                self.title          = nil;

                if ( theTitleAnnotation ) {
                    [self removeAnnotation:theTitleAnnotation];
                    self.titleAnnotation = nil;
                }
            }

            self.inTitleUpdate = NO;
        }
    }
}

-(void)setTitleTextStyle:(CPTTextStyle *)newStyle
{
    if ( newStyle != titleTextStyle ) {
        titleTextStyle = [newStyle copy];

        if ( !self.inTitleUpdate ) {
            self.inTitleUpdate   = YES;
            self.attributedTitle = nil;
            self.inTitleUpdate   = NO;

            CPTTextLayer *titleLayer = (CPTTextLayer *)self.titleAnnotation.contentLayer;
            if ( [titleLayer isKindOfClass:[CPTTextLayer class]] ) {
                titleLayer.textStyle = titleTextStyle;
            }
        }
    }
}

-(void)setTitleDisplacement:(CGPoint)newDisplace
{
    if ( !CGPointEqualToPoint(newDisplace, titleDisplacement) ) {
        titleDisplacement = newDisplace;

        self.titleAnnotation.displacement = newDisplace;
    }
}

-(void)setTitlePlotAreaFrameAnchor:(CPTRectAnchor)newAnchor
{
    if ( newAnchor != titlePlotAreaFrameAnchor ) {
        titlePlotAreaFrameAnchor = newAnchor;

        CPTLayerAnnotation *theTitleAnnotation = self.titleAnnotation;
        if ( theTitleAnnotation ) {
            theTitleAnnotation.rectAnchor         = titlePlotAreaFrameAnchor;
            theTitleAnnotation.contentAnchorPoint = [self contentAnchorForRectAnchor:titlePlotAreaFrameAnchor];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Event Handling

/// @name User Interaction
/// @{

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly pressed the mouse button. @endif
 *  @if iOSOnly touched the screen. @endif
 *
 *
 *  The event is passed in turn to the following layers:
 *  -# All plots in reverse order (i.e., from front to back in the layer order)
 *  -# The axis set
 *  -# The plot area
 *  -# The legend
 *
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES. If none of the layers
 *  handle the event, it is passed to all plot spaces whether they handle it or not.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
            return YES;
        }
    }

    // Axes Set
    if ( [self.axisSet pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
        return YES;
    }

    // Plot area
    if ( [self.plotAreaFrame pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
        return YES;
    }

    // Legend
    if ( [self.legend pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
        return YES;
    }

    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (e.g., dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceDownEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    }

    if ( handledEvent ) {
        return YES;
    }
    else {
        return [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    }
}

/**
 *  @brief Informs the receiver that the user has
 *  @if MacOnly released the mouse button. @endif
 *  @if iOSOnly lifted their finger off the screen. @endif
 *
 *
 *  The event is passed in turn to the following layers:
 *  -# All plots in reverse order (i.e., from front to back in the layer order)
 *  -# The axis set
 *  -# The plot area
 *  -# The legend
 *
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES. If none of the layers
 *  handle the event, it is passed to all plot spaces whether they handle it or not.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    BOOL handledEvent = NO;

    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
            handledEvent = YES;
            break;
        }
    }

    // Axes Set
    if ( !handledEvent && [self.axisSet pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
        handledEvent = YES;
    }

    // Plot area
    if ( !handledEvent && [self.plotAreaFrame pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
        handledEvent = YES;
    }

    // Legend
    if ( !handledEvent && [self.legend pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
        handledEvent = YES;
    }

    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (e.g., dragging coordinate translation)
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        if ( !handledEvent || (handledEvent && space.isDragging) ) {
            BOOL handled = [space pointingDeviceUpEvent:event atPoint:interactionPoint];
            handledEvent |= handled;
        }
    }

    if ( handledEvent ) {
        return YES;
    }
    else {
        return [super pointingDeviceUpEvent:event atPoint:interactionPoint];
    }
}

/**
 *  @brief Informs the receiver that the user has moved
 *  @if MacOnly the mouse with the button pressed. @endif
 *  @if iOSOnly their finger while touching the screen. @endif
 *
 *
 *  The event is passed in turn to the following layers:
 *  -# All plots in reverse order (i.e., from front to back in the layer order)
 *  -# The axis set
 *  -# The plot area
 *  -# The legend
 *
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES. If none of the layers
 *  handle the event, it is passed to all plot spaces whether they handle it or not.
 *
 *  @param event The OS event.
 *  @param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
            return YES;
        }
    }

    // Axes Set
    if ( [self.axisSet pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
        return YES;
    }

    // Plot area
    if ( [self.plotAreaFrame pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
        return YES;
    }

    // Legend
    if ( [self.legend pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
        return YES;
    }

    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (e.g., dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceDraggedEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    }

    if ( handledEvent ) {
        return YES;
    }
    else {
        return [super pointingDeviceDraggedEvent:event atPoint:interactionPoint];
    }
}

/**
 *  @brief Informs the receiver that tracking of
 *  @if MacOnly mouse moves @endif
 *  @if iOSOnly touches @endif
 *  has been cancelled for any reason.
 *
 *
 *  The event is passed in turn to the following layers:
 *  -# All plots in reverse order (i.e., from front to back in the layer order)
 *  -# The axis set
 *  -# The plot area
 *  -# The legend
 *
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES. If none of the layers
 *  handle the event, it is passed to all plot spaces whether they handle it or not.
 *
 *  @param event The OS event.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot pointingDeviceCancelledEvent:event] ) {
            return YES;
        }
    }

    // Axes Set
    if ( [self.axisSet pointingDeviceCancelledEvent:event] ) {
        return YES;
    }

    // Plot area
    if ( [self.plotAreaFrame pointingDeviceCancelledEvent:event] ) {
        return YES;
    }

    // Legend
    if ( [self.legend pointingDeviceCancelledEvent:event] ) {
        return YES;
    }

    // Plot spaces
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceCancelledEvent:event];
        handledEvent |= handled;
    }

    if ( handledEvent ) {
        return YES;
    }
    else {
        return [super pointingDeviceCancelledEvent:event];
    }
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else

/**
 *  @brief @required Informs the receiver that the user has moved the scroll wheel.
 *
 *
 *  The event is passed in turn to the following layers:
 *  -# All plots in reverse order (i.e., from front to back in the layer order)
 *  -# The axis set
 *  -# The plot area
 *  -# The legend
 *
 *  If any layer handles the event, subsequent layers are not notified and
 *  this method immediately returns @YES. If none of the layers
 *  handle the event, it is passed to all plot spaces whether they handle it or not.
 *
 *  @param event The OS event.
 *  @param fromPoint The starting coordinates of the interaction.
 *  @param toPoint The ending coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)scrollWheelEvent:(CPTNativeEvent *)event fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint
{
    // Plots
    for ( CPTPlot *plot in [self.plots reverseObjectEnumerator] ) {
        if ( [plot scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
            return YES;
        }
    }

    // Axes Set
    if ( [self.axisSet scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
        return YES;
    }

    // Plot area
    if ( [self.plotAreaFrame scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
        return YES;
    }

    // Legend
    if ( [self.legend scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint] ) {
        return YES;
    }

    // Plot spaces
    BOOL handledEvent = NO;
    for ( CPTPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint];
        handledEvent |= handled;
    }

    if ( handledEvent ) {
        return YES;
    }
    else {
        return [super scrollWheelEvent:event fromPoint:fromPoint toPoint:toPoint];
    }
}
#endif

/// @}

@end

#pragma mark -

@implementation CPTGraph(AbstractFactoryMethods)

/** @brief Creates a new plot space for the graph.
 *  @return A new plot space.
 **/
-(CPTPlotSpace *)newPlotSpace
{
    return nil;
}

/** @brief Creates a new axis set for the graph.
 *  @return A new axis set.
 **/
-(CPTAxisSet *)newAxisSet
{
    return nil;
}

@end
