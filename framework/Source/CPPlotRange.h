#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

/// @file

/**	@brief Enumeration of possible results of a plot range comparison.
 **/
typedef enum _CPPlotRangeComparisonResult {
    CPPlotRangeComparisonResultNumberBelowRange,	///< Number is below the range.
    CPPlotRangeComparisonResultNumberInRange,		///< Number is in the range.
    CPPlotRangeComparisonResultNumberAboveRange		///< Number is above the range.
} CPPlotRangeComparisonResult;

@interface CPPlotRange : NSObject <NSCoding, NSCopying> {
	@private
	NSDecimal location;
	NSDecimal length;
    double locationDouble;
	double lengthDouble;
}

/// @name Range Limits
/// @{
@property (nonatomic, readwrite) NSDecimal location;
@property (nonatomic, readwrite) NSDecimal length;
@property (nonatomic, readonly) NSDecimal end;
@property (nonatomic, readonly) double locationDouble;
@property (nonatomic, readonly) double lengthDouble;
@property (nonatomic, readonly) double endDouble;

@property (nonatomic, readonly) NSDecimal minLimit;
@property (nonatomic, readonly) NSDecimal maxLimit;
@property (nonatomic, readonly) double minLimitDouble;
@property (nonatomic, readonly) double maxLimitDouble;
///	@}

/// @name Factory Methods
/// @{
+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;
///	@}

/// @name Initialization
/// @{
-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;
///	@}

/// @name Checking Ranges
/// @{
-(BOOL)contains:(NSDecimal)number;
-(BOOL)containsDouble:(double)number;
-(BOOL)isEqualToRange:(CPPlotRange *)otherRange;
///	@}

/// @name Combining Ranges
/// @{
-(void)unionPlotRange:(CPPlotRange *)otherRange;
-(void)intersectionPlotRange:(CPPlotRange *)otherRange;
///	@}

/// @name Shifting Ranges
/// @{
-(void)shiftLocationToFitInRange:(CPPlotRange *)otherRange;
-(void)shiftEndToFitInRange:(CPPlotRange *)otherRange;
///	@}

/// @name Expanding/Contracting Ranges
/// @{
-(void)expandRangeByFactor:(NSDecimal)factor;
///	@}

/// @name Range Comparison
/// @{
-(CPPlotRangeComparisonResult)compareToNumber:(NSNumber *)number;
-(CPPlotRangeComparisonResult)compareToDecimal:(NSDecimal)number;
-(CPPlotRangeComparisonResult)compareToDouble:(double)number;
///	@}

@end
