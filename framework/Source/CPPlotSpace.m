
#import "CPPlotSpace.h"
#import "CPLayer.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"

/**	@brief Plot space coordinate change notification.
 *
 *	This notification is posted to the default notification center whenever the mapping between
 *	the plot space coordinate system and drawing coordinates changes.
 **/
NSString * const CPPlotSpaceCoordinateMappingDidChangeNotification = @"CPPlotSpaceCoordinateMappingDidChangeNotification";

/**	@brief Defines the coordinate system of a plot.
 **/
@implementation CPPlotSpace

/// @defgroup CPPlotSpace CPPlotSpace
/// @{

/**	@property identifier
 *	@brief An object used to identify the plot in collections.
 **/
@synthesize identifier;

/**	@property allowsUserInteraction
 *	@brief Determines whether user can interactively change plot range and/or zoom.
 **/
@synthesize allowsUserInteraction;

/** @property nextResponder
 *  @brief The next responder of the layer in the responder chain.
 **/
@synthesize nextResponder;

/** @property plotArea
 *  @brief The plot area of the space.
 **/
@synthesize plotArea;

/** @property delegate
 *  @brief The plot space delegate.
 **/
@synthesize delegate;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)init
{
	if ( self = [super init] ) {
		identifier = nil;
        allowsUserInteraction = NO;
        nextResponder = nil;
        plotArea = nil;
        delegate = nil;
	}
	return self;
}

-(void)dealloc
{	
	delegate = nil;
	plotArea = nil;
	nextResponder = nil;
	[identifier release];
	[super dealloc];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotSpace;
}

#pragma mark -
#pragma mark Responder Chain and User interaction

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger down event.
 *	@param interactionPoint The coordinates of the event in the host view.
 **/
-(void)pointingDeviceDownAtPoint:(CGPoint)interactionPoint
{
	[nextResponder pointingDeviceDownAtPoint:interactionPoint];
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger up event.
 *	@param interactionPoint The coordinates of the event in the host view.
 **/
-(void)pointingDeviceUpAtPoint:(CGPoint)interactionPoint
{
	[nextResponder pointingDeviceUpAtPoint:interactionPoint];
}

/**	@brief Abstraction of Mac and iPhone event handling. Handles mouse or finger dragged event.
 *	@param interactionPoint The coordinates of the event in the host view.
 **/
-(void)pointingDeviceDraggedAtPoint:(CGPoint)interactionPoint
{
	[nextResponder pointingDeviceDraggedAtPoint:interactionPoint];
}

/**	@brief Abstraction of Mac and iPhone event handling. Mouse or finger event cancelled.
 **/
-(void)pointingDeviceCancelled
{
	[nextResponder pointingDeviceCancelled];
}

///	@}

@end

///	@brief CPPlotSpace abstract methods—must be overridden by subclasses
@implementation CPPlotSpace(AbstractMethods)

/// @addtogroup CPPlotSpace
/// @{

/**	@brief Converts a data point to plot area drawing coordinates.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimals).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint
{
	return CGPointMake(0.0f, 0.0f);
}

/**	@brief Converts a data point to plot area drawing coordinates.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint;
{
	return CGPointMake(0.0f, 0.0f);
}

/**	@brief Converts a point given in plot area drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimals).
 *	@param point The drawing coordinates of the data point.
 **/
-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
}

/**	@brief Converts a point given in drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@param point The drawing coordinates of the data point.
 *	@param layer The layer containing the point to convert.
 **/
-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
}

/**	@brief Gets the range of values for a given coordinate.
 *	@param coordinate The axis coordinate.
 *	@return The range of values.
 **/
-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate
{
	return nil;
}

/**	@brief Scales the plot ranges so that the plots just fit in the visible space.
 *	@param plots An array of the plots that have to fit in the visible area.
 **/
-(void)scaleToFitPlots:(NSArray *)plots {
}
///	@}

@end
