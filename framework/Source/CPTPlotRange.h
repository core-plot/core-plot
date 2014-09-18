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
@property (nonatomic, readonly, strong) NSNumber *location;
@property (nonatomic, readonly, strong) NSNumber *length;
@property (nonatomic, readonly, strong) NSNumber *end;
@property (nonatomic, readonly) NSDecimal locationDecimal;
@property (nonatomic, readonly) NSDecimal lengthDecimal;
@property (nonatomic, readonly) NSDecimal endDecimal;
@property (nonatomic, readonly) double locationDouble;
@property (nonatomic, readonly) double lengthDouble;
@property (nonatomic, readonly) double endDouble;

@property (nonatomic, readonly, strong) NSNumber *minLimit;
@property (nonatomic, readonly, strong) NSNumber *midPoint;
@property (nonatomic, readonly, strong) NSNumber *maxLimit;
@property (nonatomic, readonly) NSDecimal minLimitDecimal;
@property (nonatomic, readonly) NSDecimal midPointDecimal;
@property (nonatomic, readonly) NSDecimal maxLimitDecimal;
@property (nonatomic, readonly) double minLimitDouble;
@property (nonatomic, readonly) double midPointDouble;
@property (nonatomic, readonly) double maxLimitDouble;
/// @}

/// @name Factory Methods
/// @{
+(instancetype)plotRangeWithLocation:(NSNumber *)loc length:(NSNumber *)len;
+(instancetype)plotRangeWithLocationDecimal:(NSDecimal)loc lengthDecimal:(NSDecimal)len;
/// @}

/// @name Initialization
/// @{
-(instancetype)initWithLocation:(NSNumber *)loc length:(NSNumber *)len;
-(instancetype)initWithLocationDecimal:(NSDecimal)loc lengthDecimal:(NSDecimal)len;
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
