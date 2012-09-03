#import "CPTDefinitions.h"
#import <Foundation/Foundation.h>

/// @file

/**
 *  @brief Enumeration of possible results of a plot range comparison.
 **/
typedef enum _CPTPlotRangeComparisonResult {
    CPTPlotRangeComparisonResultNumberBelowRange, ///< Number is below the range.
    CPTPlotRangeComparisonResultNumberInRange,    ///< Number is in the range.
    CPTPlotRangeComparisonResultNumberAboveRange  ///< Number is above the range.
}
CPTPlotRangeComparisonResult;

@interface CPTPlotRange : NSObject<NSCoding, NSCopying, NSMutableCopying> {
    @private
    NSDecimal location;
    NSDecimal length;
    double locationDouble;
    double lengthDouble;
}

/// @name Range Limits
/// @{
@property (nonatomic, readonly) NSDecimal location;
@property (nonatomic, readonly) NSDecimal length;
@property (nonatomic, readonly) NSDecimal end;
@property (nonatomic, readonly) double locationDouble;
@property (nonatomic, readonly) double lengthDouble;
@property (nonatomic, readonly) double endDouble;

@property (nonatomic, readonly) NSDecimal minLimit;
@property (nonatomic, readonly) NSDecimal midPoint;
@property (nonatomic, readonly) NSDecimal maxLimit;
@property (nonatomic, readonly) double minLimitDouble;
@property (nonatomic, readonly) double midPointDouble;
@property (nonatomic, readonly) double maxLimitDouble;
/// @}

/// @name Factory Methods
/// @{
+(id)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;
/// @}

/// @name Initialization
/// @{
-(id)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;
/// @}

/// @name Checking Ranges
/// @{
-(BOOL)contains:(NSDecimal)number;
-(BOOL)containsDouble:(double)number;
-(BOOL)isEqualToRange:(CPTPlotRange *)otherRange;
-(BOOL)containsRange:(CPTPlotRange *)otherRange;
-(BOOL)intersectsRange:(CPTPlotRange *)otherRange;
/// @}

/// @name Range Comparison
/// @{
-(CPTPlotRangeComparisonResult)compareToNumber:(NSNumber *)number;
-(CPTPlotRangeComparisonResult)compareToDecimal:(NSDecimal)number;
-(CPTPlotRangeComparisonResult)compareToDouble:(double)number;
/// @}

@end
