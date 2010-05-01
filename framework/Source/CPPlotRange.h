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
	double doublePrecisionLocation;
	double doublePrecisionLength;
}

@property (readwrite) NSDecimal location;
@property (readwrite) NSDecimal length;
@property (readonly) NSDecimal end;
@property (readwrite) double doublePrecisionLocation;
@property (readwrite) double doublePrecisionLength;
@property (readonly) double doublePrecisionEnd;

+(CPPlotRange *)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;

-(BOOL)contains:(NSDecimal)number;
-(BOOL)isEqualToRange:(CPPlotRange *)otherRange;

-(void)unionPlotRange:(CPPlotRange *)otherRange;
-(void)intersectionPlotRange:(CPPlotRange *)otherRange;

-(void)shiftLocationToFitInRange:(CPPlotRange *)otherRange;
-(void)shiftEndToFitInRange:(CPPlotRange *)otherRange;

-(void)expandRangeByFactor:(NSDecimal)factor;

-(CPPlotRangeComparisonResult)compareToNumber:(NSNumber *)number;

@end
