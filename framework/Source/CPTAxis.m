#import "CPTAxis.h"
#import "CPTAxisLabel.h"
#import "CPTAxisLabelGroup.h"
#import "CPTAxisSet.h"
#import "CPTAxisTitle.h"
#import "CPTColor.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTGradient.h"
#import "CPTGridLineGroup.h"
#import "CPTGridLines.h"
#import "CPTImage.h"
#import "CPTLimitBand.h"
#import "CPTLineStyle.h"
#import "CPTPlotRange.h"
#import "CPTPlotSpace.h"
#import "CPTPlotArea.h"
#import "CPTTextLayer.h"
#import "CPTUtilities.h"
#import "CPTPlatformSpecificCategories.h"
#import "CPTUtilities.h"
#import "NSDecimalNumberExtensions.h"

/**	@cond */
@interface CPTAxis ()

@property (nonatomic, readwrite, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) __weak CPTGridLines *minorGridLines;
@property (nonatomic, readwrite, assign) __weak CPTGridLines *majorGridLines;
@property (nonatomic, readwrite, assign) BOOL labelFormatterChanged;
@property (nonatomic, readwrite, retain) NSMutableArray *mutableBackgroundLimitBands;

-(void)generateFixedIntervalMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(void)autoGenerateMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(NSSet *)filteredTickLocations:(NSSet *)allLocations;
-(void)updateAxisLabelsAtLocations:(NSSet *)locations useMajorAxisLabels:(BOOL)useMajorAxisLabels labelAlignment:(CPTAlignment)theLabelAlignment labelOffset:(CGFloat)theLabelOffset labelRotation:(CGFloat)theLabelRotation textStyle:(CPTTextStyle *)theLabelTextStyle labelFormatter:(NSNumberFormatter *)theLabelFormatter;

double niceNum(double x, BOOL round);

@end
/**	@endcond */

#pragma mark -

/**	@brief An abstract axis class.
 **/
@implementation CPTAxis

// Axis

/**	@property axisLineStyle
 *  @brief The line style for the axis line.
 *	If nil, the line is not drawn.
 **/
@synthesize axisLineStyle;

/**	@property coordinate
 *	@brief The axis coordinate.
 **/
@synthesize coordinate;

/**	@property labelingOrigin
 *	@brief The origin used for axis labels.
 *  The default value is 0. It is only used when the axis labeling
 *  policy is CPTAxisLabelingPolicyFixedInterval. The origin is
 *  a reference point used to being labeling. Labels are added
 *	at the origin, as well as at fixed intervals above and below
 *  the origin.
 **/
@synthesize labelingOrigin;

/**	@property tickDirection
 *	@brief The tick direction.
 *  The direction is given as the sign that ticks extend along
 *  the axis (e.g., positive, or negative).
 **/
@synthesize tickDirection;

/**	@property visibleRange
 *	@brief The plot range over which the axis and ticks are visible.
 *  Use this to restrict an axis to less than the full plot area width.
 *  Set to nil for no restriction.
 **/
@synthesize visibleRange;

/**	@property gridLinesRange
 *	@brief The plot range over which the grid lines are visible.
 *  Note that this range applies to the orthogonal coordinate, not
 *  the axis coordinate itself.
 *  Set to nil for no restriction.
 **/
@synthesize gridLinesRange;


// Title

/**	@property titleTextStyle
 *  @brief The text style used to draw the axis title text.
 **/
@synthesize titleTextStyle;

/**	@property axisTitle
 *  @brief The axis title.
 *	If nil, no title is drawn.
 **/
@synthesize axisTitle;

/**	@property titleOffset
 *	@brief The offset distance between the axis title and the axis line.
 **/
@synthesize titleOffset;

/**	@property title
 *	@brief A convenience property for setting the text title of the axis.
 **/
@synthesize title;

/**	@property titleRotation
 *	@brief The rotation angle of the axis title in radians.
 *  If NaN (the default), the title will be parallel to the axis.
 **/
@synthesize titleRotation;

/**	@property titleLocation
 *	@brief The position along the axis where the axis title should be centered.
 *  If NaN, the <code>defaultTitleLocation</code> will be used.
 **/
@dynamic titleLocation;

/**	@property defaultTitleLocation
 *	@brief The position along the axis where the axis title should be centered
 *  if <code>titleLocation</code> is NaN.
 **/
@dynamic defaultTitleLocation;

// Plot space

/**	@property plotSpace
 *	@brief The plot space for the axis.
 **/
@synthesize plotSpace;

// Labels

/**	@property labelingPolicy
 *	@brief The axis labeling policy.
 **/
@synthesize labelingPolicy;

/**	@property labelOffset
 *	@brief The offset distance between the tick marks and labels.
 **/
@synthesize labelOffset;

/**	@property minorTickLabelOffset
 *	@brief The offset distance between the minor tick marks and labels.
 **/
@synthesize minorTickLabelOffset;

/**	@property labelRotation
 *	@brief The rotation of the axis labels in radians.
 *  Set this property to M_PI/2.0 to have labels read up the screen, for example.
 **/
@synthesize labelRotation;

/**	@property minorTickLabelRotation
 *	@brief The rotation of the axis minor tick labels in radians.
 *  Set this property to M_PI/2.0 to have labels read up the screen, for example.
 **/
@synthesize minorTickLabelRotation;

/**	@property labelAlignment
 *	@brief The alignment of the axis label with respect to the tick mark.
 **/
@synthesize labelAlignment;

/**	@property minorTickLabelAlignment
 *	@brief The alignment of the axis label with respect to the tick mark.
 **/
@synthesize minorTickLabelAlignment;

/**	@property labelTextStyle
 *	@brief The text style used to draw the label text.
 **/
@synthesize labelTextStyle;

/**	@property minorTickLabelTextStyle
 *	@brief The text style used to draw the label text of minor tick labels.
 **/
@synthesize minorTickLabelTextStyle;

/**	@property labelFormatter
 *	@brief The number formatter used to format the label text.
 *  If you need a non-numerical label, such as a date, you can use a formatter than turns
 *  the numerical plot coordinate into a string (e.g., "Jan 10, 2010"). 
 *  The CPTTimeFormatter is useful for this purpose.
 **/
@synthesize labelFormatter;

/**	@property minorTickLabelFormatter
 *	@brief The number formatter used to format the label text of minor ticks.
 *  If you need a non-numerical label, such as a date, you can use a formatter than turns
 *  the numerical plot coordinate into a string (e.g., "Jan 10, 2010"). 
 *  The CPTTimeFormatter is useful for this purpose.
 **/
@synthesize minorTickLabelFormatter;

@synthesize labelFormatterChanged;

/**	@property axisLabels
 *	@brief The set of axis labels.
 **/
@synthesize axisLabels;

/**	@property minorTickAxisLabels
 *	@brief The set of minor tick axis labels.
 **/
@synthesize minorTickAxisLabels;

/**	@property needsRelabel
 *	@brief If YES, the axis needs to be relabeled before the layer content is drawn.
 **/
@synthesize needsRelabel;

/**	@property labelExclusionRanges
 *	@brief An array of CPTPlotRange objects. Any tick marks and labels falling inside any of the ranges in the array will not be drawn.
 **/
@synthesize labelExclusionRanges;

// Major ticks

/**	@property majorIntervalLength
 *	@brief The distance between major tick marks expressed in data coordinates.
 **/
@synthesize majorIntervalLength;

/**	@property majorTickLineStyle
 *  @brief The line style for the major tick marks.
 *	If nil, the major ticks are not drawn.
 **/
@synthesize majorTickLineStyle;

/**	@property majorTickLength
 *	@brief The length of the major tick marks.
 **/
@synthesize majorTickLength;

/**	@property majorTickLocations
 *	@brief A set of axis coordinates for all major tick marks.
 **/
@synthesize majorTickLocations;

/**	@property preferredNumberOfMajorTicks
 *	@brief The number of ticks that should be targeted when autogenerating positions.
 *  This property only applies when the CPTAxisLabelingPolicyAutomatic policy is in use.
 *	If zero (0) (the default), Core Plot will choose a reasonable number of ticks.
 **/
@synthesize preferredNumberOfMajorTicks;

// Minor ticks

/**	@property minorTicksPerInterval
 *	@brief The number of minor tick marks drawn in each major tick interval.
 **/
@synthesize minorTicksPerInterval;

/**	@property minorTickLineStyle
 *  @brief The line style for the minor tick marks.
 *	If nil, the minor ticks are not drawn.
 **/
@synthesize minorTickLineStyle;

/**	@property minorTickLength
 *	@brief The length of the minor tick marks.
 **/
@synthesize minorTickLength;

/**	@property minorTickLocations
 *	@brief A set of axis coordinates for all minor tick marks.
 **/
@synthesize minorTickLocations;

// Grid Lines

/**	@property majorGridLineStyle
 *  @brief The line style for the major grid lines.
 *	If nil, the major grid lines are not drawn.
 **/
@synthesize majorGridLineStyle;

/**	@property minorGridLineStyle
 *  @brief The line style for the minor grid lines.
 *	If nil, the minor grid lines are not drawn.
 **/
@synthesize minorGridLineStyle;

// Background Bands

/**	@property alternatingBandFills
 *	@brief An array of two or more fills to be drawn between successive major tick marks.
 *
 *	When initializing the fills, provide an NSArray containing any combinination of CPTFill,
 *	CPTColor, CPTGradient, and/or CPTImage objects. Blank (transparent) bands can be created
 *	by using [NSNull null] in place of some of the CPTFill objects.
 **/
@synthesize alternatingBandFills;

/**	@property backgroundLimitBands
 *	@brief An array of CPTLimitBand objects.
 *
 *	The limit bands are drawn on top of the alternating band fills.
 **/
@dynamic backgroundLimitBands;

@synthesize mutableBackgroundLimitBands;

// Layers

/**	@property separateLayers
 *  @brief Use separate layers for drawing grid lines?
 *
 *	If NO, the default, the major and minor grid lines are drawn in layers shared with other axes.
 *	If YES, the grid lines are drawn in their own layers.
 **/
@synthesize separateLayers;

/**	@property plotArea
 *  @brief The plot area that the axis belongs to.
 **/
@synthesize plotArea;

/**	@property minorGridLines
 *  @brief The layer that draws the minor grid lines.
 **/
@synthesize minorGridLines;

/**	@property majorGridLines
 *  @brief The layer that draws the major grid lines.
 **/
@synthesize majorGridLines;

/**	@property axisSet
 *  @brief The axis set that the axis belongs to.
 **/
@dynamic axisSet;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		plotSpace = nil;
		majorTickLocations = [[NSSet set] retain];
		minorTickLocations = [[NSSet set] retain];
        preferredNumberOfMajorTicks = 0;
		minorTickLength = 3.0;
		majorTickLength = 5.0;
		labelOffset = 2.0;
		minorTickLabelOffset = 2.0;
        labelRotation = 0.0;
        minorTickLabelRotation = 0.0;
		labelAlignment = CPTAlignmentCenter;
		minorTickLabelAlignment = CPTAlignmentCenter;
		title = nil;
		titleOffset = 30.0;
		axisLineStyle = [[CPTLineStyle alloc] init];
		majorTickLineStyle = [[CPTLineStyle alloc] init];
		minorTickLineStyle = [[CPTLineStyle alloc] init];
		majorGridLineStyle = nil;
		minorGridLineStyle = nil;
		labelingOrigin = [[NSDecimalNumber zero] decimalValue];
		majorIntervalLength = [[NSDecimalNumber one] decimalValue];
		minorTicksPerInterval = 1;
		coordinate = CPTCoordinateX;
		labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
		labelTextStyle = [[CPTTextStyle alloc] init];
		NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
		newFormatter.minimumIntegerDigits = 1;
		newFormatter.maximumFractionDigits = 1; 
        newFormatter.minimumFractionDigits = 1;
        labelFormatter = newFormatter;
		minorTickLabelTextStyle = [[CPTTextStyle alloc] init];
        minorTickLabelFormatter = nil;
		labelFormatterChanged = YES;
		axisLabels = [[NSSet set] retain];
		minorTickAxisLabels = [[NSSet set] retain];
        tickDirection = CPTSignNone;
		axisTitle = nil;
		titleTextStyle = [[CPTTextStyle alloc] init];
		titleRotation = NAN;
		titleLocation = CPTDecimalNaN();
        needsRelabel = YES;
		labelExclusionRanges = nil;
		plotArea = nil;
		separateLayers = NO;
		alternatingBandFills = nil;
		mutableBackgroundLimitBands = nil;
		minorGridLines = nil;
		majorGridLines = nil;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTAxis *theLayer = (CPTAxis *)layer;
		
		plotSpace = [theLayer->plotSpace retain];
		majorTickLocations = [theLayer->majorTickLocations retain];
		minorTickLocations = [theLayer->minorTickLocations retain];
		preferredNumberOfMajorTicks = theLayer->preferredNumberOfMajorTicks;
		minorTickLength = theLayer->minorTickLength;
		majorTickLength = theLayer->majorTickLength;
		labelOffset = theLayer->labelOffset;
		minorTickLabelOffset = theLayer->labelOffset;
		labelRotation = theLayer->labelRotation;
		minorTickLabelRotation = theLayer->labelRotation;
		labelAlignment = theLayer->labelAlignment;
		minorTickLabelAlignment = theLayer->labelAlignment;
		title = [theLayer->title retain];
		titleOffset = theLayer->titleOffset;
		axisLineStyle = [theLayer->axisLineStyle retain];
		majorTickLineStyle = [theLayer->majorTickLineStyle retain];
		minorTickLineStyle = [theLayer->minorTickLineStyle retain];
		majorGridLineStyle = [theLayer->majorGridLineStyle retain];
		minorGridLineStyle = [theLayer->minorGridLineStyle retain];
		labelingOrigin = theLayer->labelingOrigin;
		majorIntervalLength = theLayer->majorIntervalLength;
		minorTicksPerInterval = theLayer->minorTicksPerInterval;
		coordinate = theLayer->coordinate;
		labelingPolicy = theLayer->labelingPolicy;
		labelFormatter = [theLayer->labelFormatter retain];
		minorTickLabelFormatter = [theLayer->minorTickLabelFormatter retain];
		axisLabels = [theLayer->axisLabels retain];
		minorTickAxisLabels = [theLayer->minorTickAxisLabels retain];
		tickDirection = theLayer->tickDirection;
		labelTextStyle = [theLayer->labelTextStyle retain];
		minorTickLabelTextStyle = [theLayer->minorTickLabelTextStyle retain];
		axisTitle = [theLayer->axisTitle retain];
		titleTextStyle = [theLayer->titleTextStyle retain];
		titleRotation = theLayer->titleRotation;
		titleLocation = theLayer->titleLocation;
		needsRelabel = theLayer->needsRelabel;
		labelExclusionRanges = [theLayer->labelExclusionRanges retain];
		plotArea = theLayer->plotArea;
		separateLayers = theLayer->separateLayers;
		visibleRange = [theLayer->visibleRange retain];
		gridLinesRange = [theLayer->gridLinesRange retain];
		alternatingBandFills = [theLayer->alternatingBandFills retain];
		mutableBackgroundLimitBands = [theLayer->mutableBackgroundLimitBands retain];
		minorGridLines = theLayer->minorGridLines;
		majorGridLines = theLayer->majorGridLines;
	}
	return self;
}

-(void)dealloc
{
	self.plotArea = nil; // update layers
	
	[plotSpace release];	
	[majorTickLocations release];
	[minorTickLocations release];
	[title release];
	[axisLineStyle release];
	[majorTickLineStyle release];
	[minorTickLineStyle release];
    [majorGridLineStyle release];
    [minorGridLineStyle release];
	[labelFormatter release];
	[minorTickLabelFormatter release];
	[axisLabels release];
	[minorTickAxisLabels release];
	[labelTextStyle release];
	[minorTickLabelTextStyle release];
	[axisTitle release];
	[titleTextStyle release];
	[labelExclusionRanges release];
    [visibleRange release];
    [gridLinesRange release];
	[alternatingBandFills release];
	[mutableBackgroundLimitBands release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Ticks

-(void)generateFixedIntervalMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations
{
	NSMutableSet *majorLocations = [NSMutableSet set];
	NSMutableSet *minorLocations = [NSMutableSet set];
	
	NSDecimal zero = CPTDecimalFromInteger(0);
	NSDecimal majorInterval = self.majorIntervalLength;
	
	if ( CPTDecimalGreaterThan(majorInterval, zero) ) {
		CPTPlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] copy];
		if ( range ) {
			CPTPlotRange *theVisibleRange = self.visibleRange;
			if ( theVisibleRange ) {
				[range intersectionPlotRange:theVisibleRange];
			}
			
			NSDecimal rangeMin = range.minLimit;
			NSDecimal rangeMax = range.maxLimit;
			
			NSDecimal minorInterval;
			NSUInteger minorTickCount = self.minorTicksPerInterval;
			if ( minorTickCount > 0 ) {
				minorInterval = CPTDecimalDivide(majorInterval, CPTDecimalFromUnsignedInteger(self.minorTicksPerInterval + 1));
			}
			else {
				minorInterval = zero;
			}
			
			// Set starting coord--should be the smallest value >= rangeMin that is a whole multiple of majorInterval away from the labelingOrigin
			NSDecimal coord = CPTDecimalDivide(CPTDecimalSubtract(rangeMin, self.labelingOrigin), majorInterval);
			NSDecimalRound(&coord, &coord, 0, NSRoundUp);
			coord = CPTDecimalAdd(CPTDecimalMultiply(coord, majorInterval), self.labelingOrigin);
			
			// Set minor ticks between the starting point and rangeMin
			if ( minorTickCount > 0 ) {
				NSDecimal minorCoord = CPTDecimalSubtract(coord, minorInterval);
				
				for ( NSUInteger minorTickIndex = 0; minorTickIndex < minorTickCount; minorTickIndex++ ) {
					if ( CPTDecimalLessThan(minorCoord, rangeMin) ) break;
					[minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
					minorCoord = CPTDecimalSubtract(minorCoord, minorInterval);
				}
			}

			// Set tick locations
			while ( CPTDecimalLessThanOrEqualTo(coord, rangeMax) ) {
				// Major tick
				[majorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:coord]];
				
				// Minor ticks
				if ( minorTickCount > 0 ) {
					NSDecimal minorCoord = CPTDecimalAdd(coord, minorInterval);
					
					for ( NSUInteger minorTickIndex = 0; minorTickIndex < minorTickCount; minorTickIndex++ ) {
						if ( CPTDecimalGreaterThan(minorCoord, rangeMax) ) break;
						[minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
						minorCoord = CPTDecimalAdd(minorCoord, minorInterval);
					}
				}
				
				coord = CPTDecimalAdd(coord, majorInterval);
			}
		}
		
		[range release];
	}
	
	*newMajorLocations = majorLocations;
	*newMinorLocations = minorLocations;
}

-(void)autoGenerateMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations 
{
	// Get plot range
	CPTPlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] copy];
    CPTPlotRange *theVisibleRange = self.visibleRange;
    if ( theVisibleRange ) {
        [range intersectionPlotRange:theVisibleRange];
    }

	// Validate scale type
	CPTScaleType scaleType = [self.plotSpace scaleTypeForCoordinate:self.coordinate];
	
	switch ( scaleType ) {
		case CPTScaleTypeLinear:
			// supported scale type
			break;
			
		case CPTScaleTypeLog:
			// supported scale type--check range
			if ( (range.minLimitDouble <= 0.0) || (range.maxLimitDouble <= 0.0) ) {
				*newMajorLocations = [NSMutableSet set];
				*newMinorLocations = [NSMutableSet set];
				[range release];
				return;
			}
			break;
			
		default:
			// unsupported scale type--bail out
			*newMajorLocations = [NSMutableSet set];
			*newMinorLocations = [NSMutableSet set];
			[range release];
			return;
			
			break;
	}
    
	// Cache some values
    NSUInteger numTicks = self.preferredNumberOfMajorTicks;
    NSUInteger minorTicks = self.minorTicksPerInterval + 1; 
    double length = fabs(range.lengthDouble);
	
    // Create sets for locations
    NSMutableSet *majorLocations = [NSMutableSet set];
    NSMutableSet *minorLocations = [NSMutableSet set];
    
    // Filter troublesome values and return empty sets
    if ( length != 0.0 ) {
		switch ( scaleType ) {
			case CPTScaleTypeLinear: {
				// Determine interval value
				if ( numTicks == 0 ) {
					numTicks = 5;
				}
				
				length = niceNum(length, NO);
				double interval = niceNum(length / (numTicks - 1), YES);
				
				// Determine minor interval
				double minorInterval = interval / minorTicks;
				
				// Calculate actual range limits
				double minLimit = range.minLimitDouble;
				double maxLimit = range.maxLimitDouble;
				
				// Determine the initial and final major indexes for the actual visible range
				NSInteger initialIndex = floor(minLimit / interval);  // can be negative
				NSInteger finalIndex = ceil(maxLimit / interval);  // can be negative
				
				// Iterate through the indexes with visible ticks and build the locations sets
				for ( NSInteger i = initialIndex; i <= finalIndex; i++ ) {
					double pointLocation = i * interval;
					for ( NSUInteger j = 0; j < minorTicks; j++ ) {
						double minorPointLocation = pointLocation + minorInterval * j;
						if ( minorPointLocation < minLimit ) continue;
						if ( minorPointLocation > maxLimit ) continue;
						[minorLocations addObject:[NSDecimalNumber numberWithDouble:minorPointLocation]];
					}
					
					if ( pointLocation < minLimit ) continue;
					if ( pointLocation > maxLimit ) continue;
					[majorLocations addObject:[NSDecimalNumber numberWithDouble:pointLocation]];
				}
			}
				break;
				
			case CPTScaleTypeLog: {
				// Determine interval value
				if ( numTicks == 0 ) {
					numTicks = 5;
				}
				
				length = log10(length);
				double interval;
				if ( fabs(length) >= numTicks ) {
					interval = niceNum(length / (numTicks - 1), YES);
				}
				else {
					interval = signbit(length) ? -1.0 : 1.0;
				}
				double intervalStep = pow(10.0, fabs(interval));
				
				// Calculate actual range limits
				double minLimit = range.minLimitDouble;
				double maxLimit = range.maxLimitDouble;
				
				// Determine minor interval
				double minorInterval = intervalStep * pow(10.0, floor(log10(minLimit))) / minorTicks;
				
				// Determine the initial and final major indexes for the actual visible range
				NSInteger initialIndex = floor(log10(minLimit / fabs(interval)));  // can be negative
				NSInteger finalIndex = ceil(log10(maxLimit / fabs(interval)));  // can be negative
				
				// Iterate through the indexes with visible ticks and build the locations sets
				for ( NSInteger i = initialIndex; i <= finalIndex; i++ ) {
					double pointLocation = pow(10.0, i * interval);
					for ( NSUInteger j = 0; j < minorTicks; j++ ) {
						double minorPointLocation = pointLocation + minorInterval * j;
						if ( minorPointLocation < minLimit ) continue;
						if ( minorPointLocation > maxLimit ) continue;
						[minorLocations addObject:[NSDecimalNumber numberWithDouble:minorPointLocation]];
					}
					minorInterval *= intervalStep;
					
					if ( pointLocation < minLimit ) continue;
					if ( pointLocation > maxLimit ) continue;
					[majorLocations addObject:[NSDecimalNumber numberWithDouble:pointLocation]];
				}
			}
				break;
				
			default:
				break;
		}
    }
	
	[range release];

    // Return tick locations sets
    *newMajorLocations = majorLocations;
    *newMinorLocations = minorLocations;
}

double niceNum(double x, BOOL round)
{
	if ( x == 0.0 ) return 0.0;
	
	BOOL xIsNegative = (x < 0.0);
	if ( xIsNegative ) x = -x;
	
	double exponent = floor(log10(x));
	double fraction = x / pow(10.0, exponent);
	
	double roundedFraction;
	
	if ( round ) {
		if ( fraction < 1.5 ) {
			roundedFraction = 1.0;
		}
		else if ( fraction < 3.0 ) {
			roundedFraction = 2.0;
		}
		else if ( fraction < 7.0 ) {
			roundedFraction = 5.0;
		}
		else {
			roundedFraction = 10.0;
		}
	}
	else {
		if ( fraction <= 1.0 ) {
			roundedFraction = 1.0;
		}
		else if ( fraction <= 2.0 ) {
			roundedFraction = 2.0;
		}
		else if ( fraction <= 5.0 ) {
			roundedFraction = 5.0;
		}
		else {
			roundedFraction = 10.0;
		}
	}
	
	if ( xIsNegative ) roundedFraction = -roundedFraction;
	
	return roundedFraction * pow(10.0, exponent);
}

-(NSSet *)filteredTickLocations:(NSSet *)allLocations 
{
	NSArray *exclusionRanges = self.labelExclusionRanges;
	if ( exclusionRanges ) {
		NSMutableSet *filteredLocations = [allLocations mutableCopy];
		for ( CPTPlotRange *range in exclusionRanges ) {
			for ( NSDecimalNumber *location in allLocations ) {
				if ( [range contains:[location decimalValue]] ) {
					[filteredLocations removeObject:location];	
				}
			}
		}
		return [filteredLocations autorelease];
	}
	else {
		return allLocations;
	}
	
}

/**	@brief Removes any major ticks falling inside the label exclusion ranges from the set of tick locations.
 *	@param allLocations A set of major tick locations.
 *	@return The filtered set.
 **/
-(NSSet *)filteredMajorTickLocations:(NSSet *)allLocations
{
	return [self filteredTickLocations:allLocations];
}

/**	@brief Removes any minor ticks falling inside the label exclusion ranges from the set of tick locations.
 *	@param allLocations A set of minor tick locations.
 *	@return The filtered set.
 **/
-(NSSet *)filteredMinorTickLocations:(NSSet *)allLocations
{
	return [self filteredTickLocations:allLocations];
}

#pragma mark -
#pragma mark Labels

/**	@brief Updates the set of axis labels using the given locations.
 *	Existing axis label objects and content layers are reused where possible.
 *	@param locations A set of NSDecimalNumber label locations.
 *	@param useMajorAxisLabels If YES, label the major ticks, otherwise label the minor ticks.
 *	@param theLabelAlignment The alignment of each label.
 *	@param theLabelOffset The label offset.
 *	@param theLabelRotation The rotation angle of each label in radians.
 *	@param theLabelTextStyle The text style used to draw each label.
 *	@param theLabelFormatter The number formatter used to format each label.
 **/
-(void)updateAxisLabelsAtLocations:(NSSet *)locations
				useMajorAxisLabels:(BOOL)useMajorAxisLabels
					labelAlignment:(CPTAlignment)theLabelAlignment
					   labelOffset:(CGFloat)theLabelOffset
					 labelRotation:(CGFloat)theLabelRotation
						 textStyle:(CPTTextStyle *)theLabelTextStyle
					labelFormatter:(NSNumberFormatter *)theLabelFormatter
{
	if ( [self.delegate respondsToSelector:@selector(axis:shouldUpdateAxisLabelsAtLocations:)] ) {
		BOOL shouldContinue = [self.delegate axis:self shouldUpdateAxisLabelsAtLocations:locations];
		if ( !shouldContinue ) return;
	}

	if ( locations.count == 0 || !theLabelTextStyle || !theLabelFormatter ) {
		if ( useMajorAxisLabels ) {
			self.axisLabels = nil;
		} else {
			self.minorTickAxisLabels = nil;
		}
		return;
	}
	
	CGFloat offset = theLabelOffset;
	switch ( self.tickDirection ) {
		case CPTSignNone:
			offset += self.majorTickLength / 2.0;
			break;
		case CPTSignPositive:
		case CPTSignNegative:
			offset += self.majorTickLength;
			break;
	}
	
	[self.plotArea setAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];

	NSMutableSet *oldAxisLabels;
	if (useMajorAxisLabels) {
		oldAxisLabels = [self.axisLabels mutableCopy];
	} else {
		oldAxisLabels = [self.minorTickAxisLabels mutableCopy];
	}
	
    NSMutableSet *newAxisLabels = [[NSMutableSet alloc] initWithCapacity:locations.count];
	CPTAxisLabel *blankLabel = [[CPTAxisLabel alloc] initWithText:nil textStyle:nil];
	CPTAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
	CALayer *lastLayer = nil;
	CPTPlotArea *thePlotArea = self.plotArea;
	
	BOOL theLabelFormatterChanged = self.labelFormatterChanged;
	CPTSign theTickDirection = self.tickDirection;
	CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
	
	for ( NSDecimalNumber *tickLocation in locations ) {
		CPTAxisLabel *newAxisLabel;
		BOOL needsNewContentLayer = NO;
		
		// reuse axis labels where possible--will prevent flicker when updating layers
		blankLabel.tickLocation = [tickLocation decimalValue];
		CPTAxisLabel *oldAxisLabel = [oldAxisLabels member:blankLabel];
		
		if ( oldAxisLabel ) {
			newAxisLabel = [oldAxisLabel retain];
		}
		else {
			newAxisLabel = [[CPTAxisLabel alloc] initWithText:nil textStyle:nil];
			newAxisLabel.tickLocation = [tickLocation decimalValue];
			needsNewContentLayer = YES;
		}
		
		newAxisLabel.rotation = theLabelRotation;
		newAxisLabel.offset = offset;
		newAxisLabel.alignment = theLabelAlignment;
		
		if ( needsNewContentLayer || theLabelFormatterChanged ) {
			NSString *labelString = [theLabelFormatter stringForObjectValue:tickLocation];
			CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
			[oldAxisLabel.contentLayer removeFromSuperlayer];
			newAxisLabel.contentLayer = newLabelLayer;
			
			if ( lastLayer ) {
				[axisLabelGroup insertSublayer:newLabelLayer below:lastLayer];
			}
			else {
				[axisLabelGroup insertSublayer:newLabelLayer atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
			}
			
			[newLabelLayer release];
			CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:newAxisLabel.tickLocation];
			[newAxisLabel positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:theTickDirection];
		}

		lastLayer = newAxisLabel.contentLayer;
		
		[newAxisLabels addObject:newAxisLabel];
		[newAxisLabel release];
	}
	[blankLabel release];
	
	// remove old labels that are not needed any more from the layer hierarchy
	[oldAxisLabels minusSet:newAxisLabels];
	for ( CPTAxisLabel *label in oldAxisLabels ) {
		[label.contentLayer removeFromSuperlayer];
	}
	[oldAxisLabels release];
	
	// do not use accessor because we've already updated the layer hierarchy
	if (useMajorAxisLabels) {
		[axisLabels release];
		axisLabels = newAxisLabels;
	} else {
		[minorTickAxisLabels release];
		minorTickAxisLabels = newAxisLabels;
	}
	
	[self setNeedsLayout];		
	self.labelFormatterChanged = NO;
}

/**	@brief Marks the receiver as needing to update the labels before the content is next drawn.
 **/
-(void)setNeedsRelabel
{
    self.needsRelabel = YES;
}

/**	@brief Updates the axis labels.
 **/
-(void)relabel
{
    if ( !self.needsRelabel ) return;
	if ( !self.plotSpace ) return;
	if ( self.delegate && ![self.delegate axisShouldRelabel:self] ) {
        self.needsRelabel = NO;
        return;
    }

	NSSet *newMajorLocations = nil;
	NSSet *newMinorLocations = nil;
	
	switch ( self.labelingPolicy ) {
		case CPTAxisLabelingPolicyNone:
        case CPTAxisLabelingPolicyLocationsProvided:
            // Locations are set by user
			break;
		case CPTAxisLabelingPolicyFixedInterval:
			[self generateFixedIntervalMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			break;
        case CPTAxisLabelingPolicyAutomatic:
			[self autoGenerateMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			break;
	}
	
	switch ( self.labelingPolicy ) {
		case CPTAxisLabelingPolicyNone:
        case CPTAxisLabelingPolicyLocationsProvided:
            // Locations are set by user--no filtering required
			break;
		default:
			// Filter and set tick locations	
			self.majorTickLocations = [self filteredMajorTickLocations:newMajorLocations];
			self.minorTickLocations = [self filteredMinorTickLocations:newMinorLocations];
	}
	
    if ( self.labelingPolicy != CPTAxisLabelingPolicyNone ) {
        // Label ticks
		[self updateAxisLabelsAtLocations:self.majorTickLocations useMajorAxisLabels:YES labelAlignment:self.labelAlignment labelOffset: self.labelOffset labelRotation:self.labelRotation textStyle:self.labelTextStyle labelFormatter:self.labelFormatter];
		if (self.minorTickLabelFormatter) {
			[self updateAxisLabelsAtLocations:self.minorTickLocations useMajorAxisLabels:NO labelAlignment:self.minorTickLabelAlignment labelOffset: self.minorTickLabelOffset labelRotation:self.minorTickLabelRotation textStyle:self.minorTickLabelTextStyle labelFormatter:self.minorTickLabelFormatter];
		}
    }

    self.needsRelabel = NO;
	if ( self.alternatingBandFills.count > 0 ) {
		[self.plotArea setNeedsDisplay];
	}
	
	[self.delegate axisDidRelabel:self];
}

#pragma mark -
#pragma mark Titles

-(NSDecimal)defaultTitleLocation
{
	return CPTDecimalNaN();
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPTDefaultZPositionAxis;
}

-(void)layoutSublayers
{
	CPTCoordinate orthogonalCoordinate = CPTOrthogonalCoordinate(self.coordinate);
	CPTSign direction = self.tickDirection;
	
    for ( CPTAxisLabel *label in self.axisLabels ) {
        CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
        [label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
    }
    for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
        CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
        [label positionRelativeToViewPoint:tickBasePoint forCoordinate:orthogonalCoordinate inDirection:direction];
    }
	
	[self.axisTitle positionRelativeToViewPoint:[self viewPointForCoordinateDecimalNumber:self.titleLocation] forCoordinate:orthogonalCoordinate inDirection:direction];
}

#pragma mark -
#pragma mark Background Bands

/**	@brief Add a background limit band.
 *	@param limitBand The new limit band.
 **/
-(void)addBackgroundLimitBand:(CPTLimitBand *)limitBand
{
	if ( limitBand ) {
		if ( !self.mutableBackgroundLimitBands ) {
			self.mutableBackgroundLimitBands = [NSMutableArray array];
		}
		
		[self.mutableBackgroundLimitBands addObject:limitBand];
		[self.plotArea setNeedsDisplay];
	}
}

/**	@brief Remove a background limit band.
 *	@param limitBand The limit band to be removed.
 **/
-(void)removeBackgroundLimitBand:(CPTLimitBand *)limitBand
{
	if ( limitBand ) {
		[self.mutableBackgroundLimitBands removeObject:limitBand];
		[self.plotArea setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setAxisLabels:(NSSet *)newLabels 
{
    if ( newLabels != axisLabels ) {
        for ( CPTAxisLabel *label in axisLabels ) {
            [label.contentLayer removeFromSuperlayer];
        }
		
		[newLabels retain];
        [axisLabels release];
        axisLabels = newLabels;
		
		[self.plotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];

		if ( axisLabels ) {
			CPTAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
			CALayer *lastLayer = nil;
			
			for ( CPTAxisLabel *label in axisLabels ) {
				CPTLayer *contentLayer = label.contentLayer;
				if ( contentLayer ) {
					if ( lastLayer ) {
						[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
					}
					else {
						[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
					}
					
					lastLayer = contentLayer;
				}
			}
		}
		
		[self setNeedsLayout];		
	}
}

-(void)setMinorTickAxisLabels:(NSSet *)newLabels 
{
    if ( newLabels != minorTickAxisLabels ) {
        for ( CPTAxisLabel *label in minorTickAxisLabels ) {
            [label.contentLayer removeFromSuperlayer];
        }
		
		[newLabels retain];
        [minorTickAxisLabels release];
        minorTickAxisLabels = newLabels;
		if ( minorTickAxisLabels ) {
			CPTAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
			CALayer *lastLayer = nil;
			
			for ( CPTAxisLabel *label in minorTickAxisLabels ) {
				CPTLayer *contentLayer = label.contentLayer;
				if ( contentLayer ) {
					if ( lastLayer ) {
						[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
					}
					else {
						[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
					}
					
					lastLayer = contentLayer;
				}
			}
		}
		
		[self setNeedsLayout];		
	}
}

-(void)setLabelTextStyle:(CPTTextStyle *)newStyle 
{
	if ( newStyle != labelTextStyle ) {
		[labelTextStyle release];
		labelTextStyle = [newStyle copy];
		
		for ( CPTAxisLabel *axisLabel in self.axisLabels ) {
			CPTLayer *contentLayer = axisLabel.contentLayer;
			if ( [contentLayer isKindOfClass:[CPTTextLayer class]] ) {
				[(CPTTextLayer *)contentLayer setTextStyle:labelTextStyle];
			}
		}
		
		[self setNeedsLayout];
	}
}

-(void)setMinorTickLabelTextStyle:(CPTTextStyle *)newStyle 
{
	if ( newStyle != minorTickLabelTextStyle ) {
		[minorTickLabelTextStyle release];
		minorTickLabelTextStyle = [newStyle copy];

		[self setNeedsLayout];
	}
}

-(void)setAxisTitle:(CPTAxisTitle *)newTitle
{
	if ( newTitle != axisTitle ) {
		[axisTitle.contentLayer removeFromSuperlayer];
		[axisTitle release];
		axisTitle = [newTitle retain];
		
		[self.plotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisTitles];
		
		if ( axisTitle ) {
			axisTitle.offset = self.titleOffset;		
			CPTLayer *contentLayer = axisTitle.contentLayer;
			if ( contentLayer ) {
				[self.plotArea.axisTitleGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisTitles]];
			}
		}
		[self setNeedsLayout];
	}
}

-(CPTAxisTitle *)axisTitle 
{
    if ( axisTitle == nil && title != nil ) {
        CPTAxisTitle *newTitle = [[CPTAxisTitle alloc] initWithText:title textStyle:self.titleTextStyle];
		newTitle.rotation = self.titleRotation;
		self.axisTitle = newTitle;
		[newTitle release];
    }
    return axisTitle;
}

-(void)setTitleTextStyle:(CPTTextStyle *)newStyle 
{
	if ( newStyle != titleTextStyle ) {
		[titleTextStyle release];
		titleTextStyle = [newStyle copy];

		CPTLayer *contentLayer = self.axisTitle.contentLayer;
		if ( [contentLayer isKindOfClass:[CPTTextLayer class]] ) {
			[(CPTTextLayer *)contentLayer setTextStyle:titleTextStyle];
		}
		
		[self setNeedsLayout];
	}
}

-(void)setTitleOffset:(CGFloat)newOffset 
{
    if ( newOffset != titleOffset ) {
        titleOffset = newOffset;
		self.axisTitle.offset = titleOffset;
		[self setNeedsLayout];
    }
}

-(void)setTitleRotation:(CGFloat)newRotation 
{
    if ( newRotation != titleRotation ) {
        titleRotation = newRotation;
		self.axisTitle.rotation = titleRotation;
		[self setNeedsLayout];
    }
}

-(void)setTitle:(NSString *)newTitle
{
	if ( newTitle != title ) {
		[title release];
		title = [newTitle copy];
    	if ( title == nil ) self.axisTitle = nil;
        
        CPTLayer *contentLayer = self.axisTitle.contentLayer;
        if ( [contentLayer isKindOfClass:[CPTTextLayer class]] ) {
            [(CPTTextLayer *)contentLayer setText:title];
        }
        
		[self setNeedsLayout];
	}
}

-(void)setTitleLocation:(NSDecimal)newLocation
{
	if ( NSDecimalCompare(&newLocation, &titleLocation) != NSOrderedSame ) {
		titleLocation = newLocation;
		[self setNeedsLayout];
	}
}

-(NSDecimal)titleLocation
{
	if ( NSDecimalIsNotANumber(&titleLocation) ) {
		return self.defaultTitleLocation;
	} else {
		return titleLocation;
	}
}

-(void)setLabelExclusionRanges:(NSArray *)ranges 
{
	if ( ranges != labelExclusionRanges ) {
		[labelExclusionRanges release];
		labelExclusionRanges = [ranges retain];
        self.needsRelabel = YES;
	}
}

-(void)setNeedsRelabel:(BOOL)newNeedsRelabel 
{
    if (newNeedsRelabel != needsRelabel) {
        needsRelabel = newNeedsRelabel;
        if ( needsRelabel ) {
            [self setNeedsLayout];
            [self setNeedsDisplay];
        }
    }
}

-(void)setMajorTickLocations:(NSSet *)newLocations 
{
    if ( newLocations != majorTickLocations ) {
        [majorTickLocations release];
        majorTickLocations = [newLocations retain];
		[self setNeedsDisplay];
		if ( self.separateLayers ) {
			[self.majorGridLines setNeedsDisplay];
		}
		else {
			[self.plotArea.majorGridLineGroup setNeedsDisplay];
		}

        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLocations:(NSSet *)newLocations 
{
    if ( newLocations != majorTickLocations ) {
        [minorTickLocations release];
        minorTickLocations = [newLocations retain];
		[self setNeedsDisplay];
		if ( self.separateLayers ) {
			[self.minorGridLines setNeedsDisplay];
		}
		else {
			[self.plotArea.minorGridLineGroup setNeedsDisplay];
		}

        self.needsRelabel = YES;
    }
}

-(void)setMajorTickLength:(CGFloat)newLength 
{
    if ( newLength != majorTickLength ) {
        majorTickLength = newLength;
        [self setNeedsDisplay];
        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLength:(CGFloat)newLength 
{
    if ( newLength != minorTickLength ) {
        minorTickLength = newLength;
        [self setNeedsDisplay];
    }
}

-(void)setLabelOffset:(CGFloat)newOffset 
{
    if ( newOffset != labelOffset ) {
        labelOffset = newOffset;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLabelOffset:(CGFloat)newOffset 
{
    if ( newOffset != minorTickLabelOffset ) {
        minorTickLabelOffset = newOffset;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setLabelRotation:(CGFloat)newRotation 
{
    if ( newRotation != labelRotation ) {
        labelRotation = newRotation;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLabelRotation:(CGFloat)newRotation 
{
    if ( newRotation != minorTickLabelRotation ) {
        minorTickLabelRotation = newRotation;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setLabelAlignment:(CPTAlignment)newAlignment 
{
    if ( newAlignment != labelAlignment ) {
        labelAlignment = newAlignment;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLabelAlignment:(CPTAlignment)newAlignment 
{
    if ( newAlignment != minorTickLabelAlignment ) {
        minorTickLabelAlignment = newAlignment;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setPlotSpace:(CPTPlotSpace *)newSpace 
{
    if ( newSpace != plotSpace ) {
        [plotSpace release];
        plotSpace = [newSpace retain];
        self.needsRelabel = YES;
    }
}

-(void)setCoordinate:(CPTCoordinate)newCoordinate 
{
    if ( newCoordinate != coordinate ) {
        coordinate = newCoordinate;
        self.needsRelabel = YES;
    }
}

-(void)setAxisLineStyle:(CPTLineStyle *)newLineStyle 
{
    if ( newLineStyle != axisLineStyle ) {
        [axisLineStyle release];
        axisLineStyle = [newLineStyle copy];
		[self setNeedsDisplay];			
    }
}

-(void)setMajorTickLineStyle:(CPTLineStyle *)newLineStyle 
{
    if ( newLineStyle != majorTickLineStyle ) {
        [majorTickLineStyle release];
        majorTickLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setMinorTickLineStyle:(CPTLineStyle *)newLineStyle 
{
    if ( newLineStyle != minorTickLineStyle ) {
        [minorTickLineStyle release];
        minorTickLineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setMajorGridLineStyle:(CPTLineStyle *)newLineStyle 
{
    if ( newLineStyle != majorGridLineStyle ) {
        [majorGridLineStyle release];
        majorGridLineStyle = [newLineStyle copy];
		
		[self.plotArea updateAxisSetLayersForType:CPTGraphLayerTypeMajorGridLines];
		
		if ( majorGridLineStyle ) {
			if ( self.separateLayers ) {
				if ( !self.majorGridLines ) {
					CPTGridLines *gridLines = [[CPTGridLines alloc] init];
					self.majorGridLines = gridLines;
					[gridLines release];
				}
				else {
					[self.majorGridLines setNeedsDisplay];
				}
			}
			else {
				[self.plotArea.majorGridLineGroup setNeedsDisplay];
			}
		}
		else {
			self.majorGridLines = nil;
		}
    }
}

-(void)setMinorGridLineStyle:(CPTLineStyle *)newLineStyle 
{
    if ( newLineStyle != minorGridLineStyle ) {
        [minorGridLineStyle release];
        minorGridLineStyle = [newLineStyle copy];
		
		[self.plotArea updateAxisSetLayersForType:CPTGraphLayerTypeMinorGridLines];
		
		if ( minorGridLineStyle ) {
			if ( self.separateLayers ) {
				if ( !self.minorGridLines ) {
					CPTGridLines *gridLines = [[CPTGridLines alloc] init];
					self.minorGridLines = gridLines;
					[gridLines release];
				}
				else {
					[self.minorGridLines setNeedsDisplay];
				}
			}
			else {
				[self.plotArea.minorGridLineGroup setNeedsDisplay];
			}
		}
		else {
			self.minorGridLines = nil;
		}
    }
}

-(void)setLabelingOrigin:(NSDecimal)newLabelingOrigin
{
	if ( CPTDecimalEquals(labelingOrigin, newLabelingOrigin) ) {
		return;
	}
	labelingOrigin = newLabelingOrigin;
	self.needsRelabel = YES;
}

-(void)setMajorIntervalLength:(NSDecimal)newIntervalLength 
{
	if ( CPTDecimalEquals(majorIntervalLength, newIntervalLength) ) {
		return;
	}
	majorIntervalLength = newIntervalLength;
	self.needsRelabel = YES;
}

-(void)setMinorTicksPerInterval:(NSUInteger)newMinorTicksPerInterval 
{
    if ( newMinorTicksPerInterval != minorTicksPerInterval ) {
        minorTicksPerInterval = newMinorTicksPerInterval;
        self.needsRelabel = YES;
    }
}

-(void)setLabelingPolicy:(CPTAxisLabelingPolicy)newPolicy 
{
    if ( newPolicy != labelingPolicy ) {
        labelingPolicy = newPolicy;
        self.needsRelabel = YES;
    }
}

-(void)setPreferredNumberOfMajorTicks:(NSUInteger)newPreferredNumberOfMajorTicks
{
	if ( newPreferredNumberOfMajorTicks != preferredNumberOfMajorTicks ) {
		preferredNumberOfMajorTicks = newPreferredNumberOfMajorTicks;
		if ( self.labelingPolicy == CPTAxisLabelingPolicyAutomatic ) {
			self.needsRelabel = YES;
		}
	}
}

-(void)setLabelFormatter:(NSNumberFormatter *)newTickLabelFormatter 
{
    if ( newTickLabelFormatter != labelFormatter ) {
        [labelFormatter release];
        labelFormatter = [newTickLabelFormatter retain];
		self.labelFormatterChanged = YES;
        self.needsRelabel = YES;
    }
}

-(void)setMinorTickLabelFormatter:(NSNumberFormatter *)newMinorTickLabelFormatter 
{
    if ( newMinorTickLabelFormatter != minorTickLabelFormatter ) {
        [minorTickLabelFormatter release];
        minorTickLabelFormatter = [newMinorTickLabelFormatter retain];
		if (!newMinorTickLabelFormatter) {
			for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
				[label.contentLayer removeFromSuperlayer];
			}
			[minorTickAxisLabels release];
			minorTickAxisLabels = [[NSSet set] retain];
		}
		self.labelFormatterChanged = YES;
        self.needsRelabel = YES;
    }
}

-(void)setTickDirection:(CPTSign)newDirection 
{
    if ( newDirection != tickDirection ) {
        tickDirection = newDirection;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setGridLinesRange:(CPTPlotRange *)newRange {
    if ( newRange != gridLinesRange ) {
        [gridLinesRange release];
        gridLinesRange = [newRange copy];
		if ( self.separateLayers ) {
			[self.minorGridLines setNeedsDisplay];
			[self.majorGridLines setNeedsDisplay];
		}
		else {
			[self.plotArea.minorGridLineGroup setNeedsDisplay];
			[self.plotArea.majorGridLineGroup setNeedsDisplay];
		}
    }
}

-(void)setPlotArea:(CPTPlotArea *)newPlotArea
{
	if ( newPlotArea != plotArea ) {
		plotArea = newPlotArea;
		
		if ( plotArea ) {
			[plotArea updateAxisSetLayersForType:CPTGraphLayerTypeMinorGridLines];
			CPTGridLines *gridLines = self.minorGridLines;
			if ( gridLines ) {
				[gridLines removeFromSuperlayer];
				[plotArea.minorGridLineGroup insertSublayer:gridLines atIndex:[plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMinorGridLines]];
			}
			
			[plotArea updateAxisSetLayersForType:CPTGraphLayerTypeMajorGridLines];
			gridLines = self.majorGridLines;
			if ( gridLines ) {
				[gridLines removeFromSuperlayer];
				[plotArea.majorGridLineGroup insertSublayer:gridLines atIndex:[plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMajorGridLines]];
			}
			
			[plotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisLabels];
			if ( self.axisLabels.count > 0 ) {
				CPTAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
				CALayer *lastLayer = nil;
				
				for ( CPTAxisLabel *label in self.axisLabels ) {
					CPTLayer *contentLayer = label.contentLayer;
					if ( contentLayer ) {
						[contentLayer removeFromSuperlayer];
						
						if ( lastLayer ) {
							[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
						}
						else {
							[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
						}
						
						lastLayer = contentLayer;
					}
				}
			}

			if ( self.minorTickAxisLabels.count > 0 ) {
				CPTAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
				CALayer *lastLayer = nil;
				
				for ( CPTAxisLabel *label in self.minorTickAxisLabels ) {
					CPTLayer *contentLayer = label.contentLayer;
					if ( contentLayer ) {
						[contentLayer removeFromSuperlayer];
						
						if ( lastLayer ) {
							[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
						}
						else {
							[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisLabels]];
						}
						
						lastLayer = contentLayer;
					}
				}
			}
			
			[plotArea updateAxisSetLayersForType:CPTGraphLayerTypeAxisTitles];
			CPTLayer *content = self.axisTitle.contentLayer;
			if ( content ) {
				[content removeFromSuperlayer];
				[plotArea.axisTitleGroup insertSublayer:content atIndex:[plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeAxisTitles]];
			}
		}
		else {
			self.minorGridLines = nil;
			self.majorGridLines = nil;
			for ( CPTAxisLabel *label in self.axisLabels ) {
				[label.contentLayer removeFromSuperlayer];
			}
			[self.axisTitle.contentLayer removeFromSuperlayer];
		}
	}
}

-(void)setVisibleRange:(CPTPlotRange *)newRange
{
    if ( newRange != visibleRange ) {
        [visibleRange release];
        visibleRange = [newRange copy];
        self.needsRelabel = YES;
    }
}

-(void)setSeparateLayers:(BOOL)newSeparateLayers
{
	if ( newSeparateLayers != separateLayers ) {
		separateLayers = newSeparateLayers;
		if ( separateLayers ) {
			if ( self.minorGridLineStyle ) {
				CPTGridLines *gridLines = [[CPTGridLines alloc] init];
				self.minorGridLines = gridLines;
				[gridLines release];
			}
			if ( self.majorGridLineStyle ) {
				CPTGridLines *gridLines = [[CPTGridLines alloc] init];
				self.majorGridLines = gridLines;
				[gridLines release];
			}
		}
		else {
			self.minorGridLines	= nil;
			if ( self.minorGridLineStyle ) {
				[self.plotArea.minorGridLineGroup setNeedsDisplay];
			}
			self.majorGridLines = nil;
			if ( self.majorGridLineStyle ) {
				[self.plotArea.majorGridLineGroup setNeedsDisplay];
			}
		}
		
	}
}

-(void)setMinorGridLines:(CPTGridLines *)newGridLines
{
	if ( newGridLines != minorGridLines ) {
		[minorGridLines removeFromSuperlayer];
		minorGridLines = newGridLines;
		if ( minorGridLines ) {
			minorGridLines.major = NO;
			minorGridLines.axis = self;
			[self.plotArea.minorGridLineGroup insertSublayer:minorGridLines atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMinorGridLines]];
		}
	}
}

-(void)setMajorGridLines:(CPTGridLines *)newGridLines
{
	if ( newGridLines != majorGridLines ) {
		[majorGridLines removeFromSuperlayer];
		majorGridLines = newGridLines;
		if ( majorGridLines ) {
			majorGridLines.major = YES;
			majorGridLines.axis = self;
			[self.plotArea.majorGridLineGroup insertSublayer:majorGridLines atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPTGraphLayerTypeMajorGridLines]];
		}
	}	
}

-(void)setAlternatingBandFills:(NSArray *)newFills
{
	if ( newFills != alternatingBandFills ) {
		[alternatingBandFills release];
		
		BOOL convertFills = NO;
		for ( id obj in newFills ) {
			if ( obj == [NSNull null] ) {
				continue;
			}
			else if ( [obj isKindOfClass:[CPTFill class]] ) {
				continue;
			}
			else {
				convertFills = YES;
				break;
			}
		}
		
		if ( convertFills ) {
			NSMutableArray *fillArray = [newFills mutableCopy];
			NSInteger i = -1;
			CPTFill *newFill = nil;
			
			for ( id obj in newFills ) {
				i++;
				if ( obj == [NSNull null] ) {
					continue;
				}
				else if ( [obj isKindOfClass:[CPTFill class]] ) {
					continue;
				}
				else if ( [obj isKindOfClass:[CPTColor class]] ) {
					newFill = [[CPTFill alloc] initWithColor:obj];
				}
				else if ( [obj isKindOfClass:[CPTGradient class]] ) {
					newFill = [[CPTFill alloc] initWithGradient:obj];
				}
				else if ( [obj isKindOfClass:[CPTImage class]] ) {
					newFill = [[CPTFill alloc] initWithImage:obj];
				}
				else {
					[NSException raise:CPTException format:@"Alternating band fills must be one or more of the following: CPTFill, CPTColor, CPTGradient, CPTImage, or [NSNull null]."];
				}
				
				[fillArray replaceObjectAtIndex:i withObject:newFill];
				[newFill release];
			}
			
			alternatingBandFills = fillArray;
		}
		else {
			alternatingBandFills = [newFills copy];
		}
		[self.plotArea setNeedsDisplay];
	}
}

-(NSArray *)backgroundLimitBands
{
    return [[self.mutableBackgroundLimitBands copy] autorelease];
}

-(CPTAxisSet *)axisSet
{
	return self.plotArea.axisSet;
}

@end

#pragma mark -

@implementation CPTAxis(AbstractMethods)

/**	@brief Converts a position on the axis to drawing coordinates.
 *	@param coordinateDecimalNumber The axis value in data coordinate space.
 *	@return The drawing coordinates of the point.
 **/
-(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimal)coordinateDecimalNumber
{
	return CGPointZero;
}

/**	@brief Draws grid lines into the provided graphics context.
 *	@param context The graphics context to draw into.
 *	@param major Draw the major grid lines if YES, minor grid lines otherwise.
 **/
-(void)drawGridLinesInContext:(CGContextRef)context isMajor:(BOOL)major
{
	// do nothing--subclasses must override to do their drawing	
}

/**	@brief Draws alternating background bands into the provided graphics context.
 *	@param context The graphics context to draw into.
 **/
-(void)drawBackgroundBandsInContext:(CGContextRef)context
{
	// do nothing--subclasses must override to do their drawing	
}

/**	@brief Draws background limit ranges into the provided graphics context.
 *	@param context The graphics context to draw into.
 **/
-(void)drawBackgroundLimitsInContext:(CGContextRef)context
{
	// do nothing--subclasses must override to do their drawing	
}

@end
