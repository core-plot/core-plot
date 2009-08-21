
#import "CPLayer.h"
#import "CPDefinitions.h"

@class CPAxisSet;
@class CPPlotRange;

extern NSString * const CPPlotSpaceCoordinateMappingDidChangeNotification;

@interface CPPlotSpace : CPLayer {
	id <NSCopying, NSObject> identifier;
}

@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;

@end

@interface CPPlotSpace(AbstractMethods)

/// @name Coordinate Space Conversions
/// @{
-(CGPoint)viewPointForPlotPoint:(NSDecimal *)plotPoint;
-(CGPoint)viewPointForDoublePrecisionPlotPoint:(double *)plotPoint;
-(void)plotPoint:(NSDecimal *)plotPoint forViewPoint:(CGPoint)point;
-(void)doublePrecisionPlotPoint:(double *)plotPoint forViewPoint:(CGPoint)point;
///	@}

/// @name Coordinate Range
/// @{
-(CPPlotRange *)plotRangeForCoordinate:(CPCoordinate)coordinate;
///	@}

@end
