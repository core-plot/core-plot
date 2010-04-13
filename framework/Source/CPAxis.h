
#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPDefinitions.h"

///	@file

@class CPAxis;
@class CPAxisSet;
@class CPAxisTitle;
@class CPGridLines;
@class CPLineStyle;
@class CPPlotSpace;
@class CPPlotRange;
@class CPPlotArea;
@class CPTextStyle;

/**	@brief Enumeration of labeling policies
 **/
typedef enum _CPAxisLabelingPolicy {
    CPAxisLabelingPolicyNone,					///< No labels provided; user sets labels and locations.
    CPAxisLabelingPolicyLocationsProvided,		///< User sets locations; class makes labels.
    CPAxisLabelingPolicyFixedInterval,			///< Fixed interval labeling policy.
	CPAxisLabelingPolicyAutomatic,				///< Automatic labeling policy.
	// TODO: Implement logarithmic labeling
    CPAxisLabelingPolicyLogarithmic				///< logarithmic labeling policy (not implemented). 
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
	CGFloat labelOffset;
    CGFloat labelRotation;
    CPLineStyle *axisLineStyle;
    CPLineStyle *majorTickLineStyle;
    CPLineStyle *minorTickLineStyle;
    CPLineStyle *majorGridLineStyle;
    CPLineStyle *minorGridLineStyle;
    NSDecimal labelingOrigin;			// TODO: NSDecimal instance variables in CALayers cause an unhandled property type encoding error
    NSDecimal majorIntervalLength;	// TODO: NSDecimal instance variables in CALayers cause an unhandled property type encoding error
    NSUInteger minorTicksPerInterval;
    NSUInteger preferredNumberOfMajorTicks;
    CPAxisLabelingPolicy labelingPolicy;
	CPTextStyle *labelTextStyle;
	CPTextStyle *titleTextStyle;
	NSNumberFormatter *labelFormatter;
	BOOL labelFormatterChanged;
	NSSet *axisLabels;
	CPAxisTitle *axisTitle;
	NSString *title;
	CGFloat titleOffset;
	NSDecimal titleLocation;	// TODO: NSDecimal instance variables in CALayers cause an unhandled property type encoding error
    CPSign tickDirection;
    BOOL needsRelabel;
	NSArray *labelExclusionRanges;
	id <CPAxisDelegate> delegate;
	CPPlotArea *plotArea;
	CPGridLines *minorGridLines;
	CPGridLines *majorGridLines;
//	Class gridLineClass;
}

/// @name Axis
/// @{
@property (nonatomic, readwrite, copy) CPLineStyle *axisLineStyle;
@property (nonatomic, readwrite, assign) CPCoordinate coordinate;
@property (nonatomic, readwrite, assign) NSDecimal labelingOrigin;
@property (nonatomic, readwrite, assign) CPSign tickDirection;
///	@}

/// @name Title
/// @{
@property (nonatomic, readwrite, copy) CPTextStyle *titleTextStyle;
@property (nonatomic, readwrite, retain) CPAxisTitle *axisTitle;
@property (nonatomic, readwrite, assign) CGFloat titleOffset;
@property (nonatomic, readwrite, retain) NSString *title;
@property (nonatomic, readwrite, assign) NSDecimal titleLocation;
///	@}

/// @name Labels
/// @{
@property (nonatomic, readwrite, assign) CPAxisLabelingPolicy labelingPolicy;
@property (nonatomic, readwrite, assign) CGFloat labelOffset;
@property (nonatomic, readwrite, assign) CGFloat labelRotation;
@property (nonatomic, readwrite, copy) CPTextStyle *labelTextStyle;
@property (nonatomic, readwrite, retain) NSNumberFormatter *labelFormatter;
@property (nonatomic, readwrite, retain) NSSet *axisLabels;
@property (nonatomic, readonly, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, retain) NSArray *labelExclusionRanges;
@property (nonatomic, readwrite, assign) id <CPAxisDelegate> delegate;
///	@}

/// @name Major Ticks
/// @{
@property (nonatomic, readwrite, assign) NSDecimal majorIntervalLength;
@property (nonatomic, readwrite, assign) CGFloat majorTickLength;
@property (nonatomic, readwrite, copy) CPLineStyle *majorTickLineStyle;
@property (nonatomic, readwrite, retain) NSSet *majorTickLocations;
@property (nonatomic, readwrite, assign) NSUInteger preferredNumberOfMajorTicks;
///	@}

/// @name Minor Ticks
/// @{
@property (nonatomic, readwrite, assign) NSUInteger minorTicksPerInterval;
@property (nonatomic, readwrite, assign) CGFloat minorTickLength;
@property (nonatomic, readwrite, copy) CPLineStyle *minorTickLineStyle;
@property (nonatomic, readwrite, retain) NSSet *minorTickLocations;
///	@}

/// @name Grid Lines
/// @{
@property (nonatomic, readwrite, copy) CPLineStyle *majorGridLineStyle;
@property (nonatomic, readwrite, copy) CPLineStyle *minorGridLineStyle;
///	@}

/// @name Plot Space
/// @{
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
///	@}

/// @name Layers
/// @{
@property (nonatomic, readwrite, retain) CPPlotArea *plotArea;
@property (nonatomic, readonly, retain) CPGridLines *minorGridLines;
@property (nonatomic, readonly, retain) CPGridLines *majorGridLines;
@property (nonatomic, readonly, retain) CPAxisSet *axisSet;
@property (nonatomic, readonly, retain) Class gridLineClass;
///	@}

/// @name Labels
/// @{
-(void)relabel;
-(void)setNeedsRelabel;
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
-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber;
///	@}

@end

