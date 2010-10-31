#import "CPAxis.h"
#import "CPAxisLabel.h"
#import "CPAxisLabelGroup.h"
#import "CPAxisSet.h"
#import "CPAxisTitle.h"
#import "CPColor.h"
#import "CPExceptions.h"
#import "CPFill.h"
#import "CPGradient.h"
#import "CPGridLineGroup.h"
#import "CPGridLines.h"
#import "CPImage.h"
#import "CPLimitBand.h"
#import "CPLineStyle.h"
#import "CPPlotRange.h"
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPTextLayer.h"
#import "CPUtilities.h"
#import "CPPlatformSpecificCategories.h"
#import "CPUtilities.h"
#import "NSDecimalNumberExtensions.h"

///	@cond
@interface CPAxis ()

@property (nonatomic, readwrite, assign) BOOL needsRelabel;
@property (nonatomic, readwrite, assign) __weak CPGridLines *minorGridLines;
@property (nonatomic, readwrite, assign) __weak CPGridLines *majorGridLines;
@property (nonatomic, readwrite, assign) BOOL labelFormatterChanged;
@property (nonatomic, readwrite, retain) NSMutableArray *backgroundLimitBands;

-(void)generateFixedIntervalMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(void)autoGenerateMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations;
-(NSSet *)filteredTickLocations:(NSSet *)allLocations;
-(void)updateAxisLabelsAtLocations:(NSSet *)locations;

@end
///	@endcond

#pragma mark -

/**	@brief An abstract axis class.
 **/
@implementation CPAxis

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
 *  policy is CPAxisLabelingPolicyFixedInterval. The origin is
 *  a reference point used to being labeling. Labels are added
 *	at the origin, as well as at fixed intervals above and below
 *  the origin.
 **/
@synthesize labelingOrigin;

/**	@property tickDirection
 *	@brief The tick direction.
 *  The direction is given as the sign that ticks extend along
 *  the axis (eg positive, or negative).
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

/**	@property labelRotation
 *	@brief The rotation of the axis labels in radians.
 *  Set this property to M_PI/2.0 to have labels read up the screen, for example.
 **/
@synthesize labelRotation;

/**	@property labelAlignment
 *	@brief The alignment of the axis label with respect to the tick mark.
 **/
@synthesize labelAlignment;

/**	@property labelTextStyle
 *	@brief The text style used to draw the label text.
 **/
@synthesize labelTextStyle;

/**	@property labelFormatter
 *	@brief The number formatter used to format the label text.
 *  If you need a non-numerical label, such as a date, you can use a formatter than turns
 *  the numerical plot coordinate into a string (eg 'Jan 10, 2010'). 
 *  The CPTimeFormatter is useful for this purpose.
 **/
@synthesize labelFormatter;

@synthesize labelFormatterChanged;

/**	@property axisLabels
 *	@brief The set of axis labels.
 **/
@synthesize axisLabels;

/**	@property needsRelabel
 *	@brief If YES, the axis needs to be relabeled before the layer content is drawn.
 **/
@synthesize needsRelabel;

/**	@property labelExclusionRanges
 *	@brief An array of CPPlotRange objects. Any tick marks and labels falling inside any of the ranges in the array will not be drawn.
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
 *  This property only applies when the CPAxisLabelingPolicyAutomatic policy is in use.
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
 *	When initializing the fills, provide an NSArray containing any combinination of CPFill,
 *	CPColor, CPGradient, and/or CPImage objects. Blank (transparent) bands can be created
 *	by using [NSNull null] in place of some of the CPFill objects.
 **/
@synthesize alternatingBandFills;

/**	@property backgroundLimitBands
 *	@brief An array of CPLimitBand objects.
 *
 *	The limit bands are drawn on top of the alternating band fills.
 **/
@dynamic backgroundLimitBands;

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
	if ( self = [super initWithFrame:newFrame] ) {
		plotSpace = nil;
		majorTickLocations = [[NSSet set] retain];
		minorTickLocations = [[NSSet set] retain];
        preferredNumberOfMajorTicks = 5;
		minorTickLength = 3.0;
		majorTickLength = 5.0;
		labelOffset = 2.0;
        labelRotation = 0.0;
		labelAlignment = CPAlignmentCenter;
		title = nil;
		titleOffset = 30.0;
		axisLineStyle = [[CPLineStyle alloc] init];
		axisLineStyle.delegate = self;
		majorTickLineStyle = [[CPLineStyle alloc] init];
		majorTickLineStyle.delegate = self;
		minorTickLineStyle = [[CPLineStyle alloc] init];
		minorTickLineStyle.delegate = self;
		majorGridLineStyle = nil;
		minorGridLineStyle = nil;
		labelingOrigin = [[NSDecimalNumber zero] decimalValue];
		majorIntervalLength = [[NSDecimalNumber one] decimalValue];
		minorTicksPerInterval = 1;
		coordinate = CPCoordinateX;
		labelingPolicy = CPAxisLabelingPolicyFixedInterval;
		labelTextStyle = [[CPTextStyle alloc] init];
		labelTextStyle.delegate = self;
		NSNumberFormatter *newFormatter = [[NSNumberFormatter alloc] init];
		newFormatter.minimumIntegerDigits = 1;
		newFormatter.maximumFractionDigits = 1; 
        newFormatter.minimumFractionDigits = 1;
        labelFormatter = newFormatter;
		labelFormatterChanged = YES;
		axisLabels = [[NSSet set] retain];
        tickDirection = CPSignNone;
		axisTitle = nil;
		titleTextStyle = [[CPTextStyle alloc] init];
		titleTextStyle.delegate = self;
		titleLocation = CPDecimalNaN();
        needsRelabel = YES;
		labelExclusionRanges = nil;
		plotArea = nil;
		separateLayers = NO;
		alternatingBandFills = nil;
		backgroundLimitBands = nil;
		minorGridLines = nil;
		majorGridLines = nil;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPAxis *theLayer = (CPAxis *)layer;
		
		plotSpace = [theLayer->plotSpace retain];
		majorTickLocations = [theLayer->majorTickLocations retain];
		minorTickLocations = [theLayer->minorTickLocations retain];
		preferredNumberOfMajorTicks = theLayer->preferredNumberOfMajorTicks;
		minorTickLength = theLayer->minorTickLength;
		majorTickLength = theLayer->majorTickLength;
		labelOffset = theLayer->labelOffset;
		labelRotation = theLayer->labelRotation;
		labelAlignment = theLayer->labelAlignment;
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
		axisLabels = [theLayer->axisLabels retain];
		tickDirection = theLayer->tickDirection;
		labelTextStyle = [theLayer->labelTextStyle retain];
		axisTitle = [theLayer->axisTitle retain];
		titleTextStyle = [theLayer->titleTextStyle retain];
		titleLocation = theLayer->titleLocation;
		needsRelabel = theLayer->needsRelabel;
		labelExclusionRanges = [theLayer->labelExclusionRanges retain];
		plotArea = theLayer->plotArea;
		separateLayers = theLayer->separateLayers;
		visibleRange = [theLayer->visibleRange retain];
		gridLinesRange = [theLayer->gridLinesRange retain];
		alternatingBandFills = [theLayer->alternatingBandFills retain];
		backgroundLimitBands = [theLayer->backgroundLimitBands retain];
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
	[axisLabels release];
	[labelTextStyle release];
	[axisTitle release];
	[titleTextStyle release];
	[labelExclusionRanges release];
    [visibleRange release];
    [gridLinesRange release];
	[alternatingBandFills release];
	[backgroundLimitBands release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Ticks

-(void)generateFixedIntervalMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations
{
	NSMutableSet *majorLocations = [NSMutableSet set];
	NSMutableSet *minorLocations = [NSMutableSet set];
	
	NSDecimal zero = CPDecimalFromInteger(0);
	NSDecimal majorInterval = self.majorIntervalLength;
	
	if ( CPDecimalGreaterThan(majorInterval, zero) ) {
		CPPlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] copy];
		if ( range ) {
			CPPlotRange *theVisibleRange = self.visibleRange;
			if ( theVisibleRange ) {
				[range intersectionPlotRange:theVisibleRange];
			}
			
			NSDecimal rangeMin = range.minLimit;
			NSDecimal rangeMax = range.maxLimit;
			
			NSDecimal minorInterval;
			NSUInteger minorTickCount = self.minorTicksPerInterval;
			if ( minorTickCount > 0 ) {
				minorInterval = CPDecimalDivide(majorInterval, CPDecimalFromUnsignedInteger(self.minorTicksPerInterval + 1));
			}
			else {
				minorInterval = zero;
			}
			
			// Set starting coord--should be the smallest value >= rangeMin that is a whole multiple of majorInterval away from the labelingOrigin
			NSDecimal coord = CPDecimalDivide(CPDecimalSubtract(rangeMin, self.labelingOrigin), majorInterval);
			NSDecimalRound(&coord, &coord, 0, NSRoundUp);
			coord = CPDecimalAdd(CPDecimalMultiply(coord, majorInterval), self.labelingOrigin);
			
			// Set minor ticks between the starting point and rangeMin
			if ( minorTickCount > 0 ) {
				NSDecimal minorCoord = CPDecimalSubtract(coord, minorInterval);
				
				for ( NSUInteger minorTickIndex = 0; minorTickIndex < minorTickCount; minorTickIndex++ ) {
					if ( CPDecimalLessThan(minorCoord, rangeMin) ) break;
					[minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
					minorCoord = CPDecimalSubtract(minorCoord, minorInterval);
				}
			}

			// Set tick locations
			while ( CPDecimalLessThanOrEqualTo(coord, rangeMax) ) {
				// Major tick
				[majorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:coord]];
				
				// Minor ticks
				if ( minorTickCount > 0 ) {
					NSDecimal minorCoord = CPDecimalAdd(coord, minorInterval);
					
					for ( NSUInteger minorTickIndex = 0; minorTickIndex < minorTickCount; minorTickIndex++ ) {
						if ( CPDecimalGreaterThan(minorCoord, rangeMax) ) break;
						[minorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:minorCoord]];
						minorCoord = CPDecimalAdd(minorCoord, minorInterval);
					}
				}
				
				coord = CPDecimalAdd(coord, majorInterval);
			}
		}
		
		[range release];
	}
	
	*newMajorLocations = majorLocations;
	*newMinorLocations = minorLocations;
}

-(void)autoGenerateMajorTickLocations:(NSSet **)newMajorLocations minorTickLocations:(NSSet **)newMinorLocations 
{
    // cache some values
	CPPlotRange *range = [[self.plotSpace plotRangeForCoordinate:self.coordinate] copy];
    CPPlotRange *theVisibleRange = self.visibleRange;
    if ( theVisibleRange ) {
        [range intersectionPlotRange:theVisibleRange];
    }
    NSUInteger numTicks = self.preferredNumberOfMajorTicks;
    NSUInteger minorTicks = self.minorTicksPerInterval; 
    double length = range.lengthDouble;   
    
    // Create sets for locations
    NSMutableSet *majorLocations = [NSMutableSet set];
    NSMutableSet *minorLocations = [NSMutableSet set];
    
    // Filter troublesome values and return empty sets
    if ( length > 0 && numTicks > 0 ) {
		// Determine interval value
		double roughInterval = length / numTicks;
		double exponentValue = pow( 10.0, floor(log10(fabs(roughInterval))) );    
		double interval = exponentValue * round(roughInterval / exponentValue);
		
		// Determine minor interval
		double minorInterval = interval / (minorTicks + 1);
        
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
				double minorPointLocation = pointLocation + minorInterval * (j + 1);
				if ( minorPointLocation < minLimit ) continue;
				if ( minorPointLocation > maxLimit ) continue;
				[minorLocations addObject:[NSDecimalNumber numberWithDouble:minorPointLocation]];
			}
			
			if ( pointLocation < minLimit ) continue;
			if ( pointLocation > maxLimit ) continue;
			[majorLocations addObject:[NSDecimalNumber numberWithDouble:pointLocation]];
		}
    }
	
	[range release];

    // Return tick locations sets
    *newMajorLocations = majorLocations;
    *newMinorLocations = minorLocations;
}

-(NSSet *)filteredTickLocations:(NSSet *)allLocations 
{
	NSArray *exclusionRanges = self.labelExclusionRanges;
	if ( exclusionRanges ) {
		NSMutableSet *filteredLocations = [allLocations mutableCopy];
		for ( CPPlotRange *range in exclusionRanges ) {
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
 **/
-(void)updateAxisLabelsAtLocations:(NSSet *)locations
{
	if ( [self.delegate respondsToSelector:@selector(axis:shouldUpdateAxisLabelsAtLocations:)] ) {
		BOOL shouldContinue = [self.delegate axis:self shouldUpdateAxisLabelsAtLocations:locations];
		if ( !shouldContinue ) return;
	}

	CPTextStyle *theLabelTextStyle = self.labelTextStyle;
	NSNumberFormatter *theLabelFormatter = self.labelFormatter;

	if ( locations.count == 0 || !theLabelTextStyle || !theLabelFormatter ) {
		self.axisLabels = nil;
		return;
	}
	
	CGFloat offset = self.labelOffset;
	switch ( self.tickDirection ) {
		case CPSignNone:
			offset += self.majorTickLength / 2.0;
			break;
		case CPSignPositive:
		case CPSignNegative:
			offset += self.majorTickLength;
			break;
	}
	
	[self.plotArea setAxisSetLayersForType:CPGraphLayerTypeAxisLabels];

	NSMutableSet *oldAxisLabels = [self.axisLabels mutableCopy];
    NSMutableSet *newAxisLabels = [[NSMutableSet alloc] initWithCapacity:locations.count];
	CPAxisLabel *blankLabel = [[CPAxisLabel alloc] initWithText:nil textStyle:nil];
	CPAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
	CALayer *lastLayer = nil;
	CPPlotArea *thePlotArea = self.plotArea;
	
	CGFloat theLabelRotation = self.labelRotation;
	CPAlignment theLabelAlignment = self.labelAlignment;
	BOOL theLabelFormatterChanged = self.labelFormatterChanged;
	CPSign theTickDirection = self.tickDirection;
	CPCoordinate orthogonalCoordinate = CPOrthogonalCoordinate(self.coordinate);
	
	for ( NSDecimalNumber *tickLocation in locations ) {
		CPAxisLabel *newAxisLabel;
		BOOL needsNewContentLayer = NO;
		
		// reuse axis labels where possible--will prevent flicker when updating layers
		blankLabel.tickLocation = [tickLocation decimalValue];
		CPAxisLabel *oldAxisLabel = [oldAxisLabels member:blankLabel];
		
		if ( oldAxisLabel ) {
			newAxisLabel = [oldAxisLabel retain];
		}
		else {
			newAxisLabel = [[CPAxisLabel alloc] initWithText:nil textStyle:nil];
			newAxisLabel.tickLocation = [tickLocation decimalValue];
			needsNewContentLayer = YES;
		}
		
		newAxisLabel.rotation = theLabelRotation;
		newAxisLabel.offset = offset;
		newAxisLabel.alignment = theLabelAlignment;
		
		if ( needsNewContentLayer || theLabelFormatterChanged ) {
			NSString *labelString = [theLabelFormatter stringForObjectValue:tickLocation];
			CPTextLayer *newLabelLayer = [[CPTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
			[oldAxisLabel.contentLayer removeFromSuperlayer];
			newAxisLabel.contentLayer = newLabelLayer;
			
			if ( lastLayer ) {
				[axisLabelGroup insertSublayer:newLabelLayer below:lastLayer];
			}
			else {
				[axisLabelGroup insertSublayer:newLabelLayer atIndex:[thePlotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisLabels]];
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
	for ( CPAxisLabel *label in oldAxisLabels ) {
		[label.contentLayer removeFromSuperlayer];
	}
	[oldAxisLabels release];
	
	// do not use accessor because we've already updated the layer hierarchy
	[axisLabels release];
	axisLabels = newAxisLabels;
	theLabelTextStyle.delegate = self;
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
		case CPAxisLabelingPolicyNone:
        case CPAxisLabelingPolicyLocationsProvided:
            // Locations are set by user
			break;
		case CPAxisLabelingPolicyFixedInterval:
			[self generateFixedIntervalMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			break;
        case CPAxisLabelingPolicyAutomatic:
			[self autoGenerateMajorTickLocations:&newMajorLocations minorTickLocations:&newMinorLocations];
			break;
		case CPAxisLabelingPolicyLogarithmic:
			// TODO: logarithmic labeling policy
			break;
	}
	
	switch ( self.labelingPolicy ) {
		case CPAxisLabelingPolicyNone:
        case CPAxisLabelingPolicyLocationsProvided:
            // Locations are set by user--no filtering required
			break;
		default:
			// Filter and set tick locations	
			self.majorTickLocations = [self filteredMajorTickLocations:newMajorLocations];
			self.minorTickLocations = [self filteredMinorTickLocations:newMinorLocations];
	}
	
    if ( self.labelingPolicy != CPAxisLabelingPolicyNone ) {
        // Label ticks
		[self updateAxisLabelsAtLocations:self.majorTickLocations];
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
	return CPDecimalNaN();
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionAxis;
}

-(void)layoutSublayers
{
    for ( CPAxisLabel *label in self.axisLabels ) {
        CGPoint tickBasePoint = [self viewPointForCoordinateDecimalNumber:label.tickLocation];
        [label positionRelativeToViewPoint:tickBasePoint forCoordinate:CPOrthogonalCoordinate(self.coordinate) inDirection:self.tickDirection];
    }

	[self.axisTitle positionRelativeToViewPoint:[self viewPointForCoordinateDecimalNumber:self.titleLocation] forCoordinate:CPOrthogonalCoordinate(self.coordinate) inDirection:self.tickDirection];
}

#pragma mark -
#pragma mark Background Bands

/**	@brief Add a background limit band.
 *	@param limitBand The new limit band.
 **/
-(void)addBackgroundLimitBand:(CPLimitBand *)limitBand
{
	if ( limitBand ) {
		if ( !self.backgroundLimitBands ) {
			self.backgroundLimitBands = [NSMutableArray array];
		}
		
		[self.backgroundLimitBands addObject:limitBand];
		[self.plotArea setNeedsDisplay];
	}
}

/**	@brief Remove a background limit band.
 *	@param limitBand The limit band to be removed.
 **/
-(void)removeBackgroundLimitBand:(CPLimitBand *)limitBand
{
	if ( limitBand ) {
		[self.backgroundLimitBands removeObject:limitBand];
		[self.plotArea setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Text style delegate

-(void)textStyleDidChange:(CPTextStyle *)textStyle
{
	BOOL labelsChanged = NO;
	
	if ( textStyle == self.labelTextStyle ) {
		for ( CPAxisLabel *axisLabel in self.axisLabels ) {
			CPLayer *contentLayer = axisLabel.contentLayer;
			if ( [contentLayer conformsToProtocol:@protocol(CPTextStyleDelegate)] ) {
				[(id <CPTextStyleDelegate>)contentLayer textStyleDidChange:textStyle];
				labelsChanged = YES;
			}
		}
	}
	else if ( textStyle == self.titleTextStyle ) {
		CPLayer *contentLayer = self.axisTitle.contentLayer;
		if ( [contentLayer conformsToProtocol:@protocol(CPTextStyleDelegate)] ) {
			[(id <CPTextStyleDelegate>)contentLayer textStyleDidChange:textStyle];
			labelsChanged = YES;
		}
	}
	
	if ( labelsChanged ) {
		[self setNeedsLayout];
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setAxisLabels:(NSSet *)newLabels 
{
    if ( newLabels != axisLabels ) {
        for ( CPAxisLabel *label in axisLabels ) {
            [label.contentLayer removeFromSuperlayer];
        }
		
		[newLabels retain];
        [axisLabels release];
        axisLabels = newLabels;
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisLabels];

		if ( axisLabels ) {
			CPAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
			CALayer *lastLayer = nil;
			
			for ( CPAxisLabel *label in axisLabels ) {
				CPLayer *contentLayer = label.contentLayer;
				if ( contentLayer ) {
					if ( lastLayer ) {
						[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
					}
					else {
						[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisLabels]];
					}
					
					lastLayer = contentLayer;
				}
			}
		}
		
		[self setNeedsLayout];		
	}
}

-(void)setLabelTextStyle:(CPTextStyle *)newStyle 
{
	if ( newStyle != labelTextStyle ) {
		labelTextStyle.delegate = nil;
		[labelTextStyle release];
		labelTextStyle = [newStyle copy];
		
		for ( CPAxisLabel *axisLabel in self.axisLabels ) {
			CPLayer *contentLayer = axisLabel.contentLayer;
			if ( [contentLayer isKindOfClass:[CPTextLayer class]] ) {
				[(CPTextLayer *)contentLayer setTextStyle:labelTextStyle];
			}
		}
		labelTextStyle.delegate = self;
		
		[self setNeedsLayout];
	}
}

-(void)setAxisTitle:(CPAxisTitle *)newTitle
{
	if ( newTitle != axisTitle ) {
		[axisTitle.contentLayer removeFromSuperlayer];
		[axisTitle release];
		axisTitle = [newTitle retain];
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisTitles];
		
		if ( axisTitle ) {
			axisTitle.offset = self.titleOffset;		
			CPLayer *contentLayer = axisTitle.contentLayer;
			if ( contentLayer ) {
				[self.plotArea.axisTitleGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisTitles]];
			}
		}
		[self setNeedsLayout];
	}
}

-(CPAxisTitle *)axisTitle 
{
    if ( axisTitle == nil && title != nil ) {
        CPAxisTitle *newTitle = [[CPAxisTitle alloc] initWithText:title textStyle:self.titleTextStyle];
		self.axisTitle = newTitle;
		[newTitle release];
    }
    return axisTitle;
}

-(void)setTitleTextStyle:(CPTextStyle *)newStyle 
{
	if ( newStyle != titleTextStyle ) {
		titleTextStyle.delegate = nil;
		[titleTextStyle release];
		titleTextStyle = [newStyle copy];

		CPLayer *contentLayer = self.axisTitle.contentLayer;
		if ( [contentLayer isKindOfClass:[CPTextLayer class]] ) {
			[(CPTextLayer *)contentLayer setTextStyle:titleTextStyle];
		}
		titleTextStyle.delegate = self;
		
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

-(void)setTitle:(NSString *)newTitle
{
	if ( newTitle != title ) {
		[title release];
		title = [newTitle copy];
    	if ( title == nil ) self.axisTitle = nil;
        
        CPLayer *contentLayer = self.axisTitle.contentLayer;
        if ( [contentLayer isKindOfClass:[CPTextLayer class]] ) {
            [(CPTextLayer *)contentLayer setText:title];
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

-(void)setLabelRotation:(CGFloat)newRotation 
{
    if ( newRotation != labelRotation ) {
        labelRotation = newRotation;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setLabelAlignment:(CPAlignment)newAlignment 
{
    if ( newAlignment != labelAlignment ) {
        labelAlignment = newAlignment;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setPlotSpace:(CPPlotSpace *)newSpace 
{
    if ( newSpace != plotSpace ) {
        [plotSpace release];
        plotSpace = [newSpace retain];
        self.needsRelabel = YES;
    }
}

-(void)setCoordinate:(CPCoordinate)newCoordinate 
{
    if ( newCoordinate != coordinate ) {
        coordinate = newCoordinate;
        self.needsRelabel = YES;
    }
}

-(void)setAxisLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != axisLineStyle ) {
		axisLineStyle.delegate = nil;
        [axisLineStyle release];
        axisLineStyle = [newLineStyle copy];
		axisLineStyle.delegate = self;
		[self setNeedsDisplay];			
    }
}

-(void)setMajorTickLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != majorTickLineStyle ) {
		majorTickLineStyle.delegate = nil;
        [majorTickLineStyle release];
        majorTickLineStyle = [newLineStyle copy];
		majorTickLineStyle.delegate = self;
        [self setNeedsDisplay];
    }
}

-(void)setMinorTickLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != minorTickLineStyle ) {
		minorTickLineStyle.delegate = nil;
        [minorTickLineStyle release];
        minorTickLineStyle = [newLineStyle copy];
		minorTickLineStyle.delegate = self;
        [self setNeedsDisplay];
    }
}

-(void)setMajorGridLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != majorGridLineStyle ) {
		majorGridLineStyle.delegate = nil;
        [majorGridLineStyle release];
        majorGridLineStyle = [newLineStyle copy];
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeMajorGridLines];
		
		if ( majorGridLineStyle ) {
			if ( self.separateLayers ) {
				if ( !self.majorGridLines ) {
					CPGridLines *gridLines = [[CPGridLines alloc] init];
					self.majorGridLines = gridLines;
					[gridLines release];
				}
				else {
					[self.majorGridLines setNeedsDisplay];
				}
				majorGridLineStyle.delegate = self.majorGridLines;
			}
			else {
				[self.plotArea.majorGridLineGroup setNeedsDisplay];
				majorGridLineStyle.delegate = self.plotArea.majorGridLineGroup;
			}
		}
		else {
			self.majorGridLines = nil;
		}
    }
}

-(void)setMinorGridLineStyle:(CPLineStyle *)newLineStyle 
{
    if ( newLineStyle != minorGridLineStyle ) {
		minorGridLineStyle.delegate = nil;
        [minorGridLineStyle release];
        minorGridLineStyle = [newLineStyle copy];
		
		[self.plotArea updateAxisSetLayersForType:CPGraphLayerTypeMinorGridLines];
		
		if ( minorGridLineStyle ) {
			if ( self.separateLayers ) {
				if ( !self.minorGridLines ) {
					CPGridLines *gridLines = [[CPGridLines alloc] init];
					self.minorGridLines = gridLines;
					[gridLines release];
				}
				else {
					[self.minorGridLines setNeedsDisplay];
				}
				minorGridLineStyle.delegate = self.minorGridLines;
			}
			else {
				[self.plotArea.minorGridLineGroup setNeedsDisplay];
				minorGridLineStyle.delegate = self.plotArea.minorGridLineGroup;
			}
		}
		else {
			self.minorGridLines = nil;
		}
    }
}

-(void)setLabelingOrigin:(NSDecimal)newLabelingOrigin
{
	if ( CPDecimalEquals(labelingOrigin, newLabelingOrigin) ) {
		return;
	}
	labelingOrigin = newLabelingOrigin;
	self.needsRelabel = YES;
}

-(void)setMajorIntervalLength:(NSDecimal)newIntervalLength 
{
	if ( CPDecimalEquals(majorIntervalLength, newIntervalLength) ) {
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

-(void)setLabelingPolicy:(CPAxisLabelingPolicy)newPolicy 
{
    if ( newPolicy != labelingPolicy ) {
        labelingPolicy = newPolicy;
        self.needsRelabel = YES;
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

-(void)setTickDirection:(CPSign)newDirection 
{
    if ( newDirection != tickDirection ) {
        tickDirection = newDirection;
		[self setNeedsLayout];
        self.needsRelabel = YES;
    }
}

-(void)setGridLinesRange:(CPPlotRange *)newRange {
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

-(void)setPlotArea:(CPPlotArea *)newPlotArea
{
	if ( newPlotArea != plotArea ) {
		plotArea = newPlotArea;
		
		if ( plotArea ) {
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeMinorGridLines];
			CPGridLines *gridLines = self.minorGridLines;
			if ( gridLines ) {
				[gridLines removeFromSuperlayer];
				[plotArea.minorGridLineGroup insertSublayer:gridLines atIndex:[plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMinorGridLines]];
			}
			
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeMajorGridLines];
			gridLines = self.majorGridLines;
			if ( gridLines ) {
				[gridLines removeFromSuperlayer];
				[plotArea.majorGridLineGroup insertSublayer:gridLines atIndex:[plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMajorGridLines]];
			}
			
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisLabels];
			if ( self.axisLabels.count > 0 ) {
				CPAxisLabelGroup *axisLabelGroup = self.plotArea.axisLabelGroup;
				CALayer *lastLayer = nil;
				
				for ( CPAxisLabel *label in self.axisLabels ) {
					CPLayer *contentLayer = label.contentLayer;
					if ( contentLayer ) {
						[contentLayer removeFromSuperlayer];
						
						if ( lastLayer ) {
							[axisLabelGroup insertSublayer:contentLayer below:lastLayer];
						}
						else {
							[axisLabelGroup insertSublayer:contentLayer atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisLabels]];
						}
						
						lastLayer = contentLayer;
					}
				}
			}
			
			[plotArea updateAxisSetLayersForType:CPGraphLayerTypeAxisTitles];
			CPLayer *content = self.axisTitle.contentLayer;
			if ( content ) {
				[content removeFromSuperlayer];
				[plotArea.axisTitleGroup insertSublayer:content atIndex:[plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeAxisTitles]];
			}
		}
		else {
			self.minorGridLines = nil;
			self.majorGridLines = nil;
			for ( CPAxisLabel *label in self.axisLabels ) {
				[label.contentLayer removeFromSuperlayer];
			}
			[self.axisTitle.contentLayer removeFromSuperlayer];
		}
	}
}

-(void)setVisibleRange:(CPPlotRange *)newRange
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
				CPGridLines *gridLines = [[CPGridLines alloc] init];
				self.minorGridLines = gridLines;
				self.minorGridLineStyle.delegate = gridLines;
				[gridLines release];
			}
			if ( self.majorGridLineStyle ) {
				CPGridLines *gridLines = [[CPGridLines alloc] init];
				self.majorGridLines = gridLines;
				self.majorGridLineStyle.delegate = gridLines;
				[gridLines release];
			}
		}
		else {
			self.minorGridLines	= nil;
			if ( self.minorGridLineStyle ) {
				self.minorGridLineStyle.delegate = self.plotArea.minorGridLineGroup;
				[self.plotArea.minorGridLineGroup setNeedsDisplay];
			}
			self.majorGridLines = nil;
			if ( self.majorGridLineStyle ) {
				self.majorGridLineStyle.delegate = self.plotArea.majorGridLineGroup;
				[self.plotArea.majorGridLineGroup setNeedsDisplay];
			}
		}
		
	}
}

-(void)setMinorGridLines:(CPGridLines *)newGridLines
{
	if ( newGridLines != minorGridLines ) {
		[minorGridLines removeFromSuperlayer];
		minorGridLines = newGridLines;
		if ( minorGridLines ) {
			minorGridLines.major = NO;
			minorGridLines.axis = self;
			[self.plotArea.minorGridLineGroup insertSublayer:minorGridLines atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMinorGridLines]];
		}
	}
}

-(void)setMajorGridLines:(CPGridLines *)newGridLines
{
	if ( newGridLines != majorGridLines ) {
		[majorGridLines removeFromSuperlayer];
		majorGridLines = newGridLines;
		if ( majorGridLines ) {
			majorGridLines.major = YES;
			majorGridLines.axis = self;
			[self.plotArea.majorGridLineGroup insertSublayer:majorGridLines atIndex:[self.plotArea sublayerIndexForAxis:self layerType:CPGraphLayerTypeMajorGridLines]];
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
			else if ( [obj isKindOfClass:[CPFill class]] ) {
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
			CPFill *newFill = nil;
			
			for ( id obj in newFills ) {
				i++;
				if ( obj == [NSNull null] ) {
					continue;
				}
				else if ( [obj isKindOfClass:[CPFill class]] ) {
					continue;
				}
				else if ( [obj isKindOfClass:[CPColor class]] ) {
					newFill = [[CPFill alloc] initWithColor:obj];
				}
				else if ( [obj isKindOfClass:[CPGradient class]] ) {
					newFill = [[CPFill alloc] initWithGradient:obj];
				}
				else if ( [obj isKindOfClass:[CPImage class]] ) {
					newFill = [[CPFill alloc] initWithImage:obj];
				}
				else {
					[NSException raise:CPException format:@"Alternating band fills must be one or more of the following: CPFill, CPColor, CPGradient, CPImage, or [NSNull null]."];
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

-(CPAxisSet *)axisSet
{
	return self.plotArea.axisSet;
}

@end

#pragma mark -

@implementation CPAxis(AbstractMethods)

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
