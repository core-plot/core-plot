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

+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(BOOL)contains:(NSDecimal)number;
-(BOOL)containsDouble:(double)number;
-(BOOL)isEqualToRange:(CPPlotRange *)otherRange;

-(void)unionPlotRange:(CPPlotRange *)otherRange;
-(void)intersectionPlotRange:(CPPlotRange *)otherRange;

-(void)shiftLocationToFitInRange:(CPPlotRange *)otherRange;
-(void)shiftEndToFitInRange:(CPPlotRange *)otherRange;

-(void)expandRangeByFactor:(NSDecimal)factor;

-(CPPlotRangeComparisonResult)compareToNumber:(NSNumber *)number;
-(CPPlotRangeComparisonResult)compareToDouble:(double)number;

@end
