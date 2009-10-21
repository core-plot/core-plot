
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

#pragma mark -
#pragma mark Initialize/Deallocate

-(id)init
{
	if ( self = [super init] ) {
		identifier = nil;
	}
	return self;
}

-(void)dealloc
{
	[identifier release];
	[super dealloc];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotSpace;
}

///	@}

@end

///	@brief CPPlotSpace abstract methods—must be overridden by subclasses
@implementation CPPlotSpace(AbstractMethods)

/// @addtogroup CPPlotSpace
/// @{

/**	@brief Converts a data point to drawing coordinates.
 *	@param layer The layer containing the point to convert.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimals).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)viewPointInLayer:(CPLayer *)layer forPlotPoint:(NSDecimal *)plotPoint
{
	return CGPointMake(0.0f, 0.0f);
}

/**	@brief Converts a data point to drawing coordinates.
 *	@param layer The layer containing the point to convert.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)viewPointInLayer:(CPLayer *)layer forDoublePrecisionPlotPoint:(double *)plotPoint;
{
	return CGPointMake(0.0f, 0.0f);
}

/**	@brief Converts a point given in drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimals).
 *	@param point The drawing coordinates of the data point.
 *	@param layer The layer containing the point to convert.
 **/
-(void)plotPoint:(NSDecimal *)plotPoint forViewPoint:(CGPoint)point inLayer:(CPLayer *)layer
{
}

/**	@brief Converts a point given in drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@param point The drawing coordinates of the data point.
 *	@param layer The layer containing the point to convert.
 **/
-(void)doublePrecisionPlotPoint:(double *)plotPoint forViewPoint:(CGPoint)point inLayer:(CPLayer *)layer
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
