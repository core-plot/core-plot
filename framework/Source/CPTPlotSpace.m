#import "CPTPlotSpace.h"

#import "CPTAxisSet.h"
#import "CPTLayer.h"

NSString *const CPTPlotSpaceCoordinateMappingDidChangeNotification = @"CPTPlotSpaceCoordinateMappingDidChangeNotification";

/**
 *	@brief Defines the coordinate system of a plot.
 *
 *	A plot space determines the mapping between data coordinates
 *	and device coordinates in the plot area.
 **/
@implementation CPTPlotSpace

/**	@property identifier
 *	@brief An object used to identify the plot in collections.
 **/
@synthesize identifier;

/**	@property allowsUserInteraction
 *	@brief Determines whether user can interactively change plot range and/or zoom.
 **/
@synthesize allowsUserInteraction;

/** @property graph
 *  @brief The graph of the space.
 **/
@synthesize graph;

/** @property delegate
 *  @brief The plot space delegate.
 **/
@synthesize delegate;

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)init
{
	if ( (self = [super init]) ) {
		identifier			  = nil;
		allowsUserInteraction = NO;
		graph				  = nil;
		delegate			  = nil;
	}
	return self;
}

-(void)dealloc
{
	delegate = nil;
	graph	 = nil;
	[identifier release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeConditionalObject:self.graph forKey:@"CPTPlotSpace.graph"];
	[coder encodeObject:self.identifier forKey:@"CPTPlotSpace.identifier"];
	if ( [self.delegate conformsToProtocol:@protocol(NSCoding)] ) {
		[coder encodeConditionalObject:self.delegate forKey:@"CPTPlotSpace.delegate"];
	}
	[coder encodeBool:self.allowsUserInteraction forKey:@"CPTPlotSpace.allowsUserInteraction"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		graph				  = [coder decodeObjectForKey:@"CPTPlotSpace.graph"];
		identifier			  = [[coder decodeObjectForKey:@"CPTPlotSpace.identifier"] copy];
		delegate			  = [coder decodeObjectForKey:@"CPTPlotSpace.delegate"];
		allowsUserInteraction = [coder decodeBoolForKey:@"CPTPlotSpace.allowsUserInteraction"];
	}
	return self;
}

#pragma mark -
#pragma mark Responder Chain and User interaction

///	@name User Interaction
///	@{

/**
 *	@brief Informs the receiver that the user has
 *	@if MacOnly pressed the mouse button. @endif
 *	@if iOSOnly touched the screen. @endif
 *
 *
 *	If the receiver does not have a @link CPTPlotSpace::delegate delegate @endlink,
 *	this method always returns <code>NO</code>. Otherwise, the
 *	@link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceDownEvent:atPoint: -plotSpace:shouldHandlePointingDeviceDownEvent:atPoint: @endlink
 *	delegate method is called. If it returns <code>NO</code>, this method returns <code>YES</code>
 *	to indicate that the event has been handled and no further processing should occur.
 *
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL handledByDelegate = NO;

	if ( [delegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceDownEvent:atPoint:)] ) {
		handledByDelegate = ![delegate plotSpace:self shouldHandlePointingDeviceDownEvent:event atPoint:interactionPoint];
	}
	return handledByDelegate;
}

/**
 *	@brief Informs the receiver that the user has
 *	@if MacOnly released the mouse button. @endif
 *	@if iOSOnly lifted their finger off the screen. @endif
 *
 *
 *	If the receiver does not have a @link CPTPlotSpace::delegate delegate @endlink,
 *	this method always returns <code>NO</code>. Otherwise, the
 *	@link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: -plotSpace:shouldHandlePointingDeviceUpEvent:atPoint: @endlink
 *	delegate method is called. If it returns <code>NO</code>, this method returns <code>YES</code>
 *	to indicate that the event has been handled and no further processing should occur.
 *
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL handledByDelegate = NO;

	if ( [delegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceUpEvent:atPoint:)] ) {
		handledByDelegate = ![delegate plotSpace:self shouldHandlePointingDeviceUpEvent:event atPoint:interactionPoint];
	}
	return handledByDelegate;
}

/**
 *	@brief Informs the receiver that the user has moved
 *	@if MacOnly the mouse with the button pressed. @endif
 *	@if iOSOnly their finger while touching the screen. @endif
 *
 *
 *	If the receiver does not have a @link CPTPlotSpace::delegate delegate @endlink,
 *	this method always returns <code>NO</code>. Otherwise, the
 *	@link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint: -plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint: @endlink
 *	delegate method is called. If it returns <code>NO</code>, this method returns <code>YES</code>
 *	to indicate that the event has been handled and no further processing should occur.
 *
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL handledByDelegate = NO;

	if ( [delegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceDraggedEvent:atPoint:)] ) {
		handledByDelegate = ![delegate plotSpace:self shouldHandlePointingDeviceDraggedEvent:event atPoint:interactionPoint];
	}
	return handledByDelegate;
}

/**
 *	@brief Informs the receiver that tracking of
 *	@if MacOnly mouse moves @endif
 *	@if iOSOnly touches @endif
 *	has been cancelled for any reason.
 *
 *
 *	If the receiver does not have a @link CPTPlotSpace::delegate delegate @endlink,
 *	this method always returns <code>NO</code>. Otherwise, the
 *	@link CPTPlotSpaceDelegate::plotSpace:shouldHandlePointingDeviceCancelledEvent: -plotSpace:shouldHandlePointingDeviceCancelledEvent: @endlink
 *	delegate method is called. If it returns <code>NO</code>, this method returns <code>YES</code>
 *	to indicate that the event has been handled and no further processing should occur.
 *
 *	@param event The OS event.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceCancelledEvent:(id)event
{
	BOOL handledByDelegate = NO;

	if ( [delegate respondsToSelector:@selector(plotSpace:shouldHandlePointingDeviceCancelledEvent:)] ) {
		handledByDelegate = ![delegate plotSpace:self shouldHandlePointingDeviceCancelledEvent:event];
	}
	return handledByDelegate;
}

///	@}

@end

#pragma mark -

@implementation CPTPlotSpace(AbstractMethods)

/**	@brief Converts a data point to plot area drawing coordinates.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)plotAreaViewPointForPlotPoint:(NSDecimal *)plotPoint
{
	return CGPointZero;
}

/**	@brief Converts a data point to plot area drawing coordinates.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)plotAreaViewPointForDoublePrecisionPlotPoint:(double *)plotPoint;
{
	return CGPointZero;
}

/**	@brief Converts a point given in plot area drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimal structs).
 *	@param point The drawing coordinates of the data point.
 **/
-(void)plotPoint:(NSDecimal *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
}

/**	@brief Converts a point given in drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@param point The drawing coordinates of the data point.
 **/
-(void)doublePrecisionPlotPoint:(double *)plotPoint forPlotAreaViewPoint:(CGPoint)point
{
}

/**	@brief Sets the range of values for a given coordinate.
 *  @param newRange The new plot range.
 *	@param coordinate The axis coordinate.
 **/
-(void)setPlotRange:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
}

/**	@brief Gets the range of values for a given coordinate.
 *	@param coordinate The axis coordinate.
 *	@return The range of values.
 **/
-(CPTPlotRange *)plotRangeForCoordinate:(CPTCoordinate)coordinate
{
	return nil;
}

/**	@brief Sets the scale type for a given coordinate.
 *  @param newType The new scale type.
 *	@param coordinate The axis coordinate.
 **/
-(void)setScaleType:(CPTScaleType)newType forCoordinate:(CPTCoordinate)coordinate
{
}

/**	@brief Gets the scale type for a given coordinate.
 *	@param coordinate The axis coordinate.
 *	@return The scale type.
 **/
-(CPTScaleType)scaleTypeForCoordinate:(CPTCoordinate)coordinate
{
	return CPTScaleTypeLinear;
}

/**	@brief Scales the plot ranges so that the plots just fit in the visible space.
 *	@param plots An array of the plots that have to fit in the visible area.
 **/
-(void)scaleToFitPlots:(NSArray *)plots
{
}

/**	@brief Zooms the plot space equally in each dimension.
 *	@param interactionScale The scaling factor. One (1) gives no scaling.
 *  @param interactionPoint The plot area view point about which the scaling occurs.
 **/
-(void)scaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
}

@end
