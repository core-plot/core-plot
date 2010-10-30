#import <Foundation/Foundation.h>
#import "CPLayer.h"
#import "CPDefinitions.h"
#import "CPTextStyle.h"

///	@file

@class CPAxis;
@class CPAxisSet;
@class CPAxisTitle;
@class CPGridLines;
@class CPLimitBand;
@class CPLineStyle;
@class CPPlotSpace;
@class CPPlotRange;
@class CPPlotArea;

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

#pragma mark -

/**	@brief Axis labeling delegate.
 **/
@protocol CPAxisDelegate <NSObject>

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

@optional

/**	@brief This method gives the delegate a chance to create custom labels for each tick.
 *  It can be used with any relabeling policy. Returning NO will cause the axis not
 *  to update the labels. It is then the delegates responsiblity to do this.
 *	@param axis The axis.
 *  @param locations The locations of the major ticks.
 *  @return YES if the axis class should proceed with automatic relabeling.
 **/
-(BOOL)axis:(CPAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations;

///	@}

@end

#pragma mark -

@interface CPAxis : CPLayer <CPTextStyleDelegate> {   
	@private
    CPCoordinate coordinate;
	CPPlotSpace *plotSpace;
    NSSet *majorTickLocations;
    NSSet *minorTickLocations;
    CGFloat majorTickLength;
    CGFloat minorTickLength;
	CGFloat labelOffset;
    CGFloat labelRotation;
	CPAlignment labelAlignment;
    CPLineStyle *axisLineStyle;
    CPLineStyle *majorTickLineStyle;
    CPLineStyle *minorTickLineStyle;
    CPLineStyle *majorGridLineStyle;
    CPLineStyle *minorGridLineStyle;
    NSDecimal labelingOrigin;			
    NSDecimal majorIntervalLength;	
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
	NSDecimal titleLocation;	
    CPSign tickDirection;
    BOOL needsRelabel;
	NSArray *labelExclusionRanges;
    CPPlotRange *visibleRange;
    CPPlotRange *gridLinesRange;
	NSArray *alternatingBandFills;
	NSMutableArray *backgroundLimitBands;
	BOOL separateLayers;
	__weak CPPlotArea *plotArea;
	__weak CPGridLines *minorGridLines;
	__weak CPGridLines *majorGridLines;
}

/// @name Axis
/// @{
@property (nonatomic, readwrite, copy) CPLineStyle *axisLineStyle;
@property (nonatomic, readwrite, assign) CPCoordinate coordinate;
@property (nonatomic, readwrite, assign) NSDecimal labelingOrigin;
@property (nonatomic, readwrite, assign) CPSign tickDirection;
@property (nonatomic, readwrite, copy) CPPlotRange *visibleRange;
///	@}

/// @name Title
/// @{
@property (nonatomic, readwrite, copy) CPTextStyle *titleTextStyle;
@property (nonatomic, readwrite, retain) CPAxisTitle *axisTitle;
@property (nonatomic, readwrite, assign) CGFloat titleOffset;
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, assign) NSDecimal titleLocation;
@property (nonatomic, readonly, assign) NSDecimal defaultTitleLocation;
///	@}

/// @name Labels
/// @{
@property (nonatomic, readwrite, assign) CPAxisLabelingPolicy labelingPolicy;
@property (nonatomic, readwrite, assign) CGFloat labelOffset;
@property (nonatomic, readwrite, assign) CGFloat labelRotation;
@property (nonatomic, readwrite, assign) CPAlignment labelAlignment;
@property (nonatomic, readwrite, copy) CPTextStyle *labelTextStyle;
@property (nonatomic, readwrite, retain) NSNumberFormatter *labelFormatter;
@property (nonatomic, readwrite, retain) NSSet *axisLabels;
@property (nonatomic, readonly, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, retain) NSArray *labelExclusionRanges;
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
@property (nonatomic, readwrite, copy) CPPlotRange *gridLinesRange;
///	@}

/// @name Background Bands
/// @{
@property (nonatomic, readwrite, copy) NSArray *alternatingBandFills;
@property (nonatomic, readonly, retain) NSMutableArray *backgroundLimitBands;
///	@}

/// @name Plot Space
/// @{
@property (nonatomic, readwrite, retain) CPPlotSpace *plotSpace;
///	@}

/// @name Layers
/// @{
@property (nonatomic, readwrite, assign) BOOL separateLayers;
@property (nonatomic, readwrite, assign) __weak CPPlotArea *plotArea;
@property (nonatomic, readonly, assign) __weak CPGridLines *minorGridLines;
@property (nonatomic, readonly, assign) __weak CPGridLines *majorGridLines;
@property (nonatomic, readonly, retain) CPAxisSet *axisSet;
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

/// @name Background Bands
/// @{
-(void)addBackgroundLimitBand:(CPLimitBand *)limitBand;
-(void)removeBackgroundLimitBand:(CPLimitBand *)limitBand;
///	@}

@end

#pragma mark -

/**	@category CPAxis(AbstractMethods)
 *	@brief CPAxis abstract methods—must be overridden by subclasses
 **/
@interface CPAxis(AbstractMethods)

/// @name Coordinate Space Conversions
/// @{
-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber;
///	@}

/// @name Grid Lines
/// @{
-(void)drawGridLinesInContext:(CGContextRef)context isMajor:(BOOL)major;
///	@}

/// @name Background Bands
/// @{
-(void)drawBackgroundBandsInContext:(CGContextRef)context;
-(void)drawBackgroundLimitsInContext:(CGContextRef)context;
///	@}

@end

