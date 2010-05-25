#import "CPDefinitions.h"

@class CPLayer;
@class CPPlotRange;

extern NSString * const CPPlotSpaceCoordinateMappingDidChangeNotification;

@interface CPPlotSpace : NSObject {
	@private
	id <NSCopying, NSObject> identifier;
}

@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;

@end

@interface CPPlotSpace(AbstractMethods)

/// @name Coordinate Space Conversions
/// @{
-(CGPoint)viewPointInLayer:(CPLayer *)layer forPlotPoint:(NSDecimal *)plotPoint;
-(CGPoint)viewPointInLayer:(CPLayer *)layer forDoublePrecisionPlotPoint:(double *)plotPoint;
-(void)plotPoint:(NSDecimal *)plotPoint forViewPoint:(CGPoint)point inLayer:(CPLayer *)layer;
-(void)doublePrecisionPlotPoint:(double *)plotPoint forViewPoint:(CGPoint)point inLayer:(CPLayer *)layer;
///	@}

/// @name Coordinate Range
/// @{
-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate;
///	@}

/// @name Adjusting Ranges to Plot Data
/// @{
-(void)scaleToFitPlots:(NSArray *)plots;
///	@}

@end
