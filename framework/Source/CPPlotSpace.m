
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"
#import "CPLineStyle.h"

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

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.masksToBounds = YES;
	}
	return self;
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotSpace;
}

-(void)setBounds:(CGRect)newBounds {
    BOOL notify = !CGRectEqualToRect(newBounds, self.bounds);
    [super setBounds:newBounds];
    if ( notify ) [[NSNotificationCenter defaultCenter] postNotificationName:CPPlotSpaceCoordinateMappingDidChangeNotification object:self];
}
///	@}

@end

///	@brief CPPlotSpace abstract methods—must be overridden by subclasses
@implementation CPPlotSpace(AbstractMethods)

/// @addtogroup CPPlotSpace
/// @{

/**	@brief Converts a data point to drawing coordinates.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimals).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)viewPointForPlotPoint:(NSDecimal *)plotPoint
{
	return CGPointMake(0.0f, 0.0f);
}

/**	@brief Converts a data point to drawing coordinates.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@return The drawing coordinates of the data point.
 **/
-(CGPoint)viewPointForDoublePrecisionPlotPoint:(double *)plotPoint;
{
	return CGPointMake(0.0f, 0.0f);
}

/**	@brief Converts a point given in drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as NSDecimals).
 *	@param point The drawing coordinates of the data point.
 **/
-(void)plotPoint:(NSDecimal *)plotPoint forViewPoint:(CGPoint)point
{
}

/**	@brief Converts a point given in drawing coordinates to the data coordinate space.
 *	@param plotPoint A c-style array of data point coordinates (as doubles).
 *	@param point The drawing coordinates of the data point.
 **/
-(void)doublePrecisionPlotPoint:(double *)plotPoint forViewPoint:(CGPoint)point;
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
///	@}

@end
