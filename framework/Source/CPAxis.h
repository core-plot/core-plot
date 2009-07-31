
#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPDefinitions.h"

///	@file

@class CPLineStyle;
@class CPPlotSpace;
@class CPPlotRange;
@class CPAxis;
@class CPTextStyle;

/**	@brief Enumeration of labeling policies
 **/
typedef enum _CPAxisLabelingPolicy {
    CPAxisLabelingPolicyNone,			///< No labels provided; user sets labels.
    CPAxisLabelingPolicyFixedInterval,	///< Fixed interval labeling policy.
    // TODO: Implement automatic labeling
	CPAxisLabelingPolicyAutomatic,		///< Automatic labeling policy (not implemented).
	// TODO: Implement logarithmic labeling
    CPAxisLabelingPolicyLogarithmic		///< logarithmic labeling policy (not implemented). 
} CPAxisLabelingPolicy;

/**	@brief Axis labeling delegate.
 **/
@protocol CPAxisDelegate

/// @name Labels
/// @{

/**	@brief Determines if the axis should relabel itself now.
 *	@param axis The axis.
 *	@return YES if the axis should relabel now.
 **/
-(BOOL)axisShouldRelabel:(CPAxis *)axis;

/**	@brief The method is called after the axis is relabeled to allow the delegate to perform any
 *	necessary cleanup or further labeling actions.
 *	@param axis The axis.
 **/
-(void)axisDidRelabel:(CPAxis *)axis;

///	@}

@end

@interface CPAxis : CPLayer {   
@private
    CPCoordinate coordinate;
	CPPlotSpace *plotSpace;
    NSSet *majorTickLocations;
    NSSet *minorTickLocations;
    CGFloat majorTickLength;
    CGFloat minorTickLength;
	CGFloat axisLabelOffset;
    CPLineStyle *axisLineStyle;
    CPLineStyle *majorTickLineStyle;
    CPLineStyle *minorTickLineStyle;
    NSDecimalNumber *fixedPoint;
    NSDecimalNumber *majorIntervalLength;
    NSUInteger minorTicksPerInterval;
    CPAxisLabelingPolicy axisLabelingPolicy;
	CPTextStyle *axisLabelTextStyle;
	NSNumberFormatter *tickLabelFormatter;
	NSSet *axisLabels;
    CPSign tickDirection;
    BOOL needsRelabel;
	NSArray *labelExclusionRanges;
	id <CPAxisDelegate> delegate;
}

/// @name Axis
/// @{
@property (nonatomic, readwrite, copy) CPLineStyle *axisLineStyle;
@property (nonatomic, readwrite, assign) CPCoordinate coordinate;
@property (nonatomic, readwrite, copy) NSDecimalNumber *fixedPoint;
@property (nonatomic, readwrite, assign) CPSign tickDirection;
///	@}

/// @name Labels
/// @{
@property (nonatomic, readwrite, assign) CPAxisLabelingPolicy axisLabelingPolicy;
@property (nonatomic, readwrite, assign) CGFloat axisLabelOffset;
@property (nonatomic, readwrite, copy) CPTextStyle *axisLabelTextStyle;
@property (nonatomic, readwrite, retain) NSNumberFormatter *tickLabelFormatter;
@property (nonatomic, readwrite, retain) NSSet *axisLabels;
@property (nonatomic, readonly, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, retain) NSArray *labelExclusionRanges;
@property (nonatomic, readwrite, assign) id <CPAxisDelegate> delegate;
///	@}

/// @name Major Ticks
/// @{
@property (nonatomic, readwrite, copy) NSDecimalNumber *majorIntervalLength;
@property (nonatomic, readwrite, assign) CGFloat majorTickLength;
@property (nonatomic, readwrite, copy) CPLineStyle *majorTickLineStyle;
@property (nonatomic, readwrite, retain) NSSet *majorTickLocations;
///	@}

/// @name Minor Ticks
/// @{
@property (nonatomic, readwrite, assign) NSUInteger minorTicksPerInterval;
@property (nonatomic, readwrite, assign) CGFloat minorTickLength;
@property (nonatomic, readwrite, copy) CPLineStyle *minorTickLineStyle;
@property (nonatomic, readwrite, retain) NSSet *minorTickLocations;
///	@}
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;

/// @name Labels
/// @{
-(void)relabel;
-(void)setNeedsRelabel;

-(NSArray *)newAxisLabelsAtLocations:(NSArray *)locations;
///	@}

/// @name Ticks
/// @{
-(NSSet *)filteredMajorTickLocations:(NSSet *)allLocations;
-(NSSet *)filteredMinorTickLocations:(NSSet *)allLocations;
///	@}

@end

@interface CPAxis(AbstractMethods)

/// @name Coordinate Space Conversions
/// @{
-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimalNumber;
///	@}

@end

