#import "CPTDefinitions.h"

/// @file

/**
 *  @brief Enumeration of possible results of a plot range comparison.
 **/
typedef NS_ENUM (NSInteger, CPTPlotRangeComparisonResult) {
    CPTPlotRangeComparisonResultNumberBelowRange, ///< Number is below the range.
    CPTPlotRangeComparisonResultNumberInRange,    ///< Number is in the range.
    CPTPlotRangeComparisonResultNumberAboveRange  ///< Number is above the range.
};

@interface CPTPlotRange : NSObject<NSCoding, NSCopying, NSMutableCopying>

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
+(instancetype)plotRangeWithLocation:(NSDecimal)loc length:(NSDecimal)len;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithLocation:(NSDecimal)loc length:(NSDecimal)len;
/// @}

/// @name Checking Ranges
/// @{
-(BOOL)contains:(NSDecimal)number;
-(BOOL)containsDouble:(double)number;
-(BOOL)containsNumber:(NSNumber *)number;
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
