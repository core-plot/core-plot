#import "CPDefinitions.h"
#import "CPResponder.h"

@class CPLayer;
@class CPPlotRange;
@class CPPlotArea;

extern NSString * const CPPlotSpaceCoordinateMappingDidChangeNotification;

@interface CPPlotSpace : NSObject <CPResponder> {
	@private
    __weak CPPlotArea *plotArea;
	id <NSCopying, NSObject> identifier;
    id <CPResponder> nextResponder;
    BOOL allowsUserInteraction;
}

@property (nonatomic, readwrite, copy) id <NSCopying, NSObject> identifier;
@property (nonatomic, readwrite, assign) BOOL allowsUserInteraction;
@property (nonatomic, readwrite, assign) __weak CPPlotArea *plotArea;

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
