#import "CPGraph.h"
#import "CPExceptions.h"
#import "CPPlot.h"
#import "CPPlotArea.h"
#import "CPPlotAreaFrame.h"
#import "CPTextStyle.h"
#import "CPPlotSpace.h"
#import "CPFill.h"
#import "CPAxisSet.h"
#import "CPAxis.h"
#import "CPTheme.h"
#import "CPLayerAnnotation.h"
#import "CPTextLayer.h"

NSString * const CPGraphNeedsRedrawNotification = @"CPGraphNeedsRedrawNotification";

///	@cond
@interface CPGraph()

@property (nonatomic, readwrite, retain) NSMutableArray *plots;
@property (nonatomic, readwrite, retain) NSMutableArray *plotSpaces;
@property (nonatomic, readwrite, retain) CPLayerAnnotation *titleAnnotation;

-(void)plotSpaceMappingDidChange:(NSNotification *)notif;

@end
///	@endcond

#pragma mark -

/**	@brief An abstract graph class.
 *	@todo More documentation needed 
 **/
@implementation CPGraph

/**	@property axisSet
 *	@brief The axis set.
 **/
@dynamic axisSet;

/**	@property plotAreaFrame
 *	@brief The plot area frame.
 **/
@synthesize plotAreaFrame;

/**	@property plots
 *	@brief An array of all plots associated with the graph.
 **/
@synthesize plots;

/**	@property plotSpaces
 *	@brief An array of all plot spaces associated with the graph.
 **/
@synthesize plotSpaces;

/**	@property defaultPlotSpace
 *	@brief The default plot space.
 **/
@dynamic defaultPlotSpace;

/** @property topDownLayerOrder
 *	@brief An array of graph layers to be drawn in an order other than the default.
 *	@see CPPlotArea#topDownLayerOrder
 **/
@dynamic topDownLayerOrder;

/**	@property title
 *	@brief The title string. 
 *  Default is nil.
 **/
@synthesize title;

/**	@property titleTextStyle
 *	@brief The text style of the title.
 **/
@synthesize titleTextStyle;

/**	@property titlePlotAreaFrameAnchor
 *	@brief The location of the title with respect to the plot area frame.
 *  Default is top center.
 **/
@synthesize titlePlotAreaFrameAnchor;

/**	@property titleDisplacement
 *	@brief A vector giving the displacement of the title from the edge location.
 **/
@synthesize titleDisplacement;

@synthesize titleAnnotation;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		plots = [[NSMutableArray alloc] init];
        
        // Margins
        self.paddingLeft = 20.0;
        self.paddingTop = 20.0;
        self.paddingRight = 20.0;
        self.paddingBottom = 20.0;
        
        // Plot area
        CPPlotAreaFrame *newArea = [(CPPlotAreaFrame *)[CPPlotAreaFrame alloc] initWithFrame:self.bounds];
        self.plotAreaFrame = newArea;
        [newArea release];

        // Plot spaces
		plotSpaces = [[NSMutableArray alloc] init];
        CPPlotSpace *newPlotSpace = [self newPlotSpace];
        [self addPlotSpace:newPlotSpace];
        [newPlotSpace release];

        // Axis set
		CPAxisSet *newAxisSet = [self newAxisSet];
		self.axisSet = newAxisSet;
		[newAxisSet release];
        
        // Title
        title = nil;
        titlePlotAreaFrameAnchor = CPRectAnchorTop;
        titleTextStyle = [[CPTextStyle textStyle] retain];
        titleDisplacement = CGPointZero;
		titleAnnotation = nil;

		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPGraph *theLayer = (CPGraph *)layer;
		
		plotAreaFrame = [theLayer->plotAreaFrame retain];
		plots = [theLayer->plots retain];
		plotSpaces = [theLayer->plotSpaces retain];
		title = [theLayer->title retain];
		titlePlotAreaFrameAnchor = theLayer->titlePlotAreaFrameAnchor;
		titleTextStyle = [theLayer->titleTextStyle retain];
		titleDisplacement = theLayer->titleDisplacement;
		titleAnnotation = [theLayer->titleAnnotation retain];
	}
	return self;
}

-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[plotAreaFrame release];
	[plots release];
	[plotSpaces release];
    [title release];
    [titleTextStyle release];
    [titleAnnotation release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Retrieving Plots

/**	@brief Makes all plots reload their data.
 **/
-(void)reloadData
{
    [self.plots makeObjectsPerformSelector:@selector(reloadData)];
}

/**	@brief Makes all plots reload their data if their data cache is out of date.
 **/
-(void)reloadDataIfNeeded
{
    [self.plots makeObjectsPerformSelector:@selector(reloadDataIfNeeded)];
}

/**	@brief All plots associated with the graph.
 *	@return An array of all plots associated with the graph. 
 **/
-(NSArray *)allPlots 
{    
	return [NSArray arrayWithArray:self.plots];
}

/**	@brief Gets the plot at the given index in the plot array.
 *	@param index An index within the bounds of the plot array.
 *	@return The plot at the given index.
 **/
-(CPPlot *)plotAtIndex:(NSUInteger)index
{
    return [self.plots objectAtIndex:index];
}

/**	@brief Gets the plot with the given identifier.
 *	@param identifier A plot identifier.
 *	@return The plot with the given identifier.
 **/
-(CPPlot *)plotWithIdentifier:(id <NSCopying>)identifier 
{
	for (CPPlot *plot in self.plots) {
        if ( [[plot identifier] isEqual:identifier] ) return plot;
	}
    return nil;
}

#pragma mark -
#pragma mark Organizing Plots

/**	@brief Add a plot to the default plot space.
 *	@param plot The plot.
 **/
-(void)addPlot:(CPPlot *)plot
{
	[self addPlot:plot toPlotSpace:self.defaultPlotSpace];
}

/**	@brief Add a plot to the given plot space.
 *	@param plot The plot.
 *	@param space The plot space.
 **/
-(void)addPlot:(CPPlot *)plot toPlotSpace:(CPPlotSpace *)space
{
	if ( plot ) {
		[self.plots addObject:plot];
		plot.plotSpace = space;
        plot.graph = self;
		[self.plotAreaFrame.plotGroup addPlot:plot];
	}
}

/**	@brief Remove a plot from the graph.
 *	@param plot The plot to remove.
 **/
-(void)removePlot:(CPPlot *)plot
{
    if ( [self.plots containsObject:plot] ) {
		[self.plots removeObject:plot];
        plot.plotSpace = nil;
        plot.graph = nil;
		[self.plotAreaFrame.plotGroup removePlot:plot];
    }
    else {
        [NSException raise:CPException format:@"Tried to remove CPPlot which did not exist."];
    }
}

/**	@brief Add a plot to the default plot space at the given index in the plot array.
 *	@param plot The plot.
 *	@param index An index within the bounds of the plot array.
 **/
-(void)insertPlot:(CPPlot* )plot atIndex:(NSUInteger)index 
{
	[self insertPlot:plot atIndex:index intoPlotSpace:self.defaultPlotSpace];
}

/**	@brief Add a plot to the given plot space at the given index in the plot array.
 *	@param plot The plot.
 *	@param index An index within the bounds of the plot array.
 *	@param space The plot space.
 **/
-(void)insertPlot:(CPPlot* )plot atIndex:(NSUInteger)index intoPlotSpace:(CPPlotSpace *)space
{
	if (plot) {
		[self.plots insertObject:plot atIndex:index];
		plot.plotSpace = space;
        plot.graph = self;
		[self.plotAreaFrame.plotGroup addPlot:plot];
	}
}

/**	@brief Remove a plot from the graph.
 *	@param identifier The identifier of the plot to remove.
 **/
-(void)removePlotWithIdentifier:(id <NSCopying>)identifier 
{
	CPPlot* plotToRemove = [self plotWithIdentifier:identifier];
	if (plotToRemove) {
		plotToRemove.plotSpace = nil;
        plotToRemove.graph = nil;
		[self.plotAreaFrame.plotGroup removePlot:plotToRemove];
		[self.plots removeObjectIdenticalTo:plotToRemove];
	}
}

#pragma mark -
#pragma mark Retrieving Plot Spaces

-(CPPlotSpace *)defaultPlotSpace {
    return ( self.plotSpaces.count > 0 ? [self.plotSpaces objectAtIndex:0] : nil );
}

/**	@brief All plot spaces associated with the graph.
 *	@return An array of all plot spaces associated with the graph. 
 **/
-(NSArray *)allPlotSpaces
{
	return [NSArray arrayWithArray:self.plotSpaces];
}

/**	@brief Gets the plot space at the given index in the plot space array.
 *	@param index An index within the bounds of the plot space array.
 *	@return The plot space at the given index.
 **/
-(CPPlotSpace *)plotSpaceAtIndex:(NSUInteger)index
{
	return ( self.plotSpaces.count > index ? [self.plotSpaces objectAtIndex:index] : nil );
}

/**	@brief Gets the plot space with the given identifier.
 *	@param identifier A plot space identifier.
 *	@return The plot space with the given identifier.
 **/
-(CPPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier
{
	for (CPPlotSpace *plotSpace in self.plotSpaces) {
        if ( [[plotSpace identifier] isEqual:identifier] ) return plotSpace;
	}
    return nil;	
}

#pragma mark -
#pragma mark Set Plot Area

-(void)setPlotAreaFrame:(CPPlotAreaFrame *)newArea 
{
    if ( plotAreaFrame != newArea ) {
    	plotAreaFrame.graph = nil;
    	[plotAreaFrame removeFromSuperlayer];
        [plotAreaFrame release];
        plotAreaFrame = [newArea retain];
        [self addSublayer:newArea];
        plotAreaFrame.graph = self;
		for ( CPPlotSpace *space in self.plotSpaces ) {
            space.graph = self;
        }
    }
}

#pragma mark -
#pragma mark Organizing Plot Spaces

/**	@brief Add a plot space to the graph.
 *	@param space The plot space.
 **/
-(void)addPlotSpace:(CPPlotSpace *)space
{
	[self.plotSpaces addObject:space];
    space.graph = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(plotSpaceMappingDidChange:) name:CPPlotSpaceCoordinateMappingDidChangeNotification object:space];
}

/**	@brief Remove a plot space from the graph.
 *	@param plotSpace The plot space.
 **/
-(void)removePlotSpace:(CPPlotSpace *)plotSpace
{
	if ( [self.plotSpaces containsObject:plotSpace] ) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CPPlotSpaceCoordinateMappingDidChangeNotification object:plotSpace];

        // Remove space
		plotSpace.graph = nil;
		[self.plotSpaces removeObject:plotSpace];
        
        // Update axes that referenced space
        for ( CPAxis *axis in self.axisSet.axes ) {
            if ( axis.plotSpace == plotSpace ) axis.plotSpace = nil;
        }
    }
    else {
        [NSException raise:CPException format:@"Tried to remove CPPlotSpace which did not exist."];
    }
}

#pragma mark -
#pragma mark Coordinate Changes in Plot Spaces

-(void)plotSpaceMappingDidChange:(NSNotification *)notif 
{
	CPPlotSpace *plotSpace = notif.object;
	
	for ( CPAxis *axis in self.axisSet.axes ) {
		if ( axis.plotSpace == plotSpace ) {
			[axis setNeedsRelabel];
		}
	}
	for ( CPPlot *plot in self.plots ) {
		if ( plot.plotSpace == plotSpace ) {
			[plot setNeedsDisplay];
		}
	}
}

#pragma mark -
#pragma mark Axis Set

-(CPAxisSet *)axisSet
{
	return self.plotAreaFrame.axisSet;
}

-(void)setAxisSet:(CPAxisSet *)newSet
{
	self.plotAreaFrame.axisSet = newSet;
}

#pragma mark -
#pragma mark Themes

/**	@brief Apply a theme to style the graph.
 *	@param theme The theme object used to style the graph.
 **/
-(void)applyTheme:(CPTheme *)theme 
{
    [theme applyThemeToGraph:self];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionGraph;
}

#pragma mark -
#pragma mark Accessors

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
        [title release];
        title = [newTitle copy];
		CPLayerAnnotation *theTitleAnnotation = self.titleAnnotation;
		if ( title ) {
			if ( theTitleAnnotation ) {
				((CPTextLayer *)theTitleAnnotation.contentLayer).text = title;
			}
			else {
				CPLayerAnnotation *newTitleAnnotation = [[CPLayerAnnotation alloc] initWithAnchorLayer:plotAreaFrame];
				CPTextLayer *newTextLayer = [[CPTextLayer alloc] initWithText:title style:self.titleTextStyle];
				newTitleAnnotation.contentLayer = newTextLayer;
				newTitleAnnotation.displacement = self.titleDisplacement;
				newTitleAnnotation.rectAnchor = self.titlePlotAreaFrameAnchor;
				[self addAnnotation:newTitleAnnotation];
				self.titleAnnotation = newTitleAnnotation;
				[newTextLayer release];
				[newTitleAnnotation release];
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

-(void)setTitleTextStyle:(CPTextStyle *)newStyle
{
    if ( newStyle != titleTextStyle ) {
        [titleTextStyle release];
        titleTextStyle = [newStyle copy];
		((CPTextLayer *)self.titleAnnotation.contentLayer).textStyle = titleTextStyle;
    }
}

-(void)setTitleDisplacement:(CGPoint)newDisplace
{
    if ( !CGPointEqualToPoint(newDisplace, titleDisplacement) ) {
        titleDisplacement = newDisplace;
        titleAnnotation.displacement = newDisplace;
    }
}

-(void)setTitlePlotAreaFrameAnchor:(CPRectAnchor)newAnchor
{
    if ( newAnchor != titlePlotAreaFrameAnchor ) {
        titlePlotAreaFrameAnchor = newAnchor;
        titleAnnotation.rectAnchor = titlePlotAreaFrameAnchor;
    }
}

#pragma mark -
#pragma mark Event Handling

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPPlot *plot in self.plots ) {
        if ( [plot pointingDeviceDownEvent:event atPoint:interactionPoint] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceDownEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceDownEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (eg dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceDownEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPPlot *plot in self.plots ) {
        if ( [plot pointingDeviceUpEvent:event atPoint:interactionPoint] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceUpEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceUpEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (eg dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceUpEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

-(BOOL)pointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    // Plots
    for ( CPPlot *plot in self.plots ) {
        if ( [plot pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) return YES;
    
    // Plot spaces
    // Plot spaces do not block events, because several spaces may need to receive
    // the same event sequence (eg dragging coordinate translation)
    BOOL handledEvent = NO;
    for ( CPPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceDraggedEvent:event atPoint:interactionPoint];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

-(BOOL)pointingDeviceCancelledEvent:(id)event
{
    // Plots
    for ( CPPlot *plot in self.plots ) {
        if ( [plot pointingDeviceCancelledEvent:event] ) return YES;
    } 
    
    // Axes Set
    if ( [self.axisSet pointingDeviceCancelledEvent:event] ) return YES;
    
    // Plot area
    if ( [self.plotAreaFrame pointingDeviceCancelledEvent:event] ) return YES;
    
    // Plot spaces
    BOOL handledEvent = NO;
    for ( CPPlotSpace *space in self.plotSpaces ) {
        BOOL handled = [space pointingDeviceCancelledEvent:event];
        handledEvent |= handled;
    } 
    
    return handledEvent;
}

@end

#pragma mark -

@implementation CPGraph(AbstractFactoryMethods)

/**	@brief Creates a new plot space for the graph.
 *	@return A new plot space.
 **/
-(CPPlotSpace *)newPlotSpace
{
	return nil;
}

/**	@brief Creates a new axis set for the graph.
 *	@return A new axis set.
 **/
-(CPAxisSet *)newAxisSet
{
	return nil;
}

@end
