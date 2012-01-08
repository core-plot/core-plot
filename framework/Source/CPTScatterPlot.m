#import "CPTScatterPlot.h"

#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLegend.h"
#import "CPTLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTNumericData.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTPlotSymbol.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"
#import "NSNumberExtensions.h"
#import <stdlib.h>

/**	@defgroup plotAnimationScatterPlot Scatter Plot
 *	@ingroup plotAnimation
 **/

/**	@if MacOnly
 *	@defgroup plotBindingsScatterPlot Scatter Plot Bindings
 *	@ingroup plotBindings
 *	@endif
 **/

NSString *const CPTScatterPlotBindingXValues	 = @"xValues";     ///< X values.
NSString *const CPTScatterPlotBindingYValues	 = @"yValues";     ///< Y values.
NSString *const CPTScatterPlotBindingPlotSymbols = @"plotSymbols"; ///< Plot symbols.

///	@cond
@interface CPTScatterPlot()

@property (nonatomic, readwrite, copy) NSArray *xValues;
@property (nonatomic, readwrite, copy) NSArray *yValues;
@property (nonatomic, readwrite, retain) NSArray *plotSymbols;

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPTXYPlotSpace *)plotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)calculateViewPoints:(CGPoint *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags;
-(void)alignViewPointsToUserSpace:(CGPoint *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags;

-(NSUInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags extremeNumIsLowerBound:(BOOL)isLowerBound;

-(CGPathRef)newDataLinePathForViewPoints:(CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineYValue:(CGFloat)baselineYValue;

CGFloat squareOfDistanceBetweenPoints(CGPoint point1, CGPoint point2);

@end

///	@endcond

#pragma mark -

/**
 *	@brief A two-dimensional scatter plot.
 *	@see See @ref plotAnimationScatterPlot "Scatter Plot" for a list of animatable properties.
 *	@if MacOnly
 *	@see See @ref plotBindingsScatterPlot "Scatter Plot Bindings" for a list of supported binding identifiers.
 *	@endif
 **/
@implementation CPTScatterPlot

@dynamic xValues;
@dynamic yValues;
@synthesize plotSymbols;

/** @property interpolation
 *	@brief The interpolation algorithm used for lines between data points.
 *	Default is #CPTScatterPlotInterpolationLinear
 **/
@synthesize interpolation;

/** @property dataLineStyle
 *	@brief The line style for the data line.
 *	If <code>nil</code>, the line is not drawn.
 **/
@synthesize dataLineStyle;

/** @property plotSymbol
 *	@brief The plot symbol drawn at each point if the data source does not provide symbols.
 *	If <code>nil</code>, no symbol is drawn.
 **/
@synthesize plotSymbol;

/** @property areaFill
 *	@brief The fill style for the area underneath the data line.
 *	If <code>nil</code>, the area is not filled.
 **/
@synthesize areaFill;

/** @property areaFill2
 *	@brief The fill style for the area above the data line.
 *	If <code>nil</code>, the area is not filled.
 **/
@synthesize areaFill2;

/** @property areaBaseValue
 *	@brief The Y coordinate of the straight boundary of the area fill.
 *	If not a number, the area is not filled.
 *
 *	Typically set to the minimum value of the Y range, but it can be any value that gives the desired appearance.
 **/
@synthesize areaBaseValue;

/** @property areaBaseValue2
 *	@brief The Y coordinate of the straight boundary of the secondary area fill.
 *	If not a number, the area is not filled.
 *
 *	Typically set to the maximum value of the Y range, but it can be any value that gives the desired appearance.
 **/
@synthesize areaBaseValue2;

/** @property plotSymbolMarginForHitDetection
 *	@brief A margin added to each side of a symbol when determining whether it has been hit.
 *
 *	Default is zero. The margin is set in plot area view coordinates.
 **/
@synthesize plotSymbolMarginForHitDetection;

#pragma mark -
#pragma mark init/dealloc

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
	if ( self == [CPTScatterPlot class] ) {
		[self exposeBinding:CPTScatterPlotBindingXValues];
		[self exposeBinding:CPTScatterPlotBindingYValues];
		[self exposeBinding:CPTScatterPlotBindingPlotSymbols];
	}
}

#endif

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTScatterPlot object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTScatterPlot::dataLineStyle dataLineStyle @endlink = default line style
 *	- @link CPTScatterPlot::plotSymbol plotSymbol @endlink = <code>nil</code>
 *	- @link CPTScatterPlot::areaFill areaFill @endlink = <code>nil</code>
 *	- @link CPTScatterPlot::areaFill2 areaFill2 @endlink = <code>nil</code>
 *	- @link CPTScatterPlot::areaBaseValue areaBaseValue @endlink = NAN
 *	- @link CPTScatterPlot::areaBaseValue2 areaBaseValue2 @endlink = NAN
 *	- @link CPTScatterPlot::plotSymbolMarginForHitDetection plotSymbolMarginForHitDetection @endlink = 0.0
 *	- @link CPTScatterPlot::interpolation interpolation @endlink = #CPTScatterPlotInterpolationLinear
 *	- @link CPTPlot::labelField labelField @endlink = #CPTScatterPlotFieldY
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTScatterPlot object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		dataLineStyle					= [[CPTLineStyle alloc] init];
		plotSymbol						= nil;
		areaFill						= nil;
		areaFill2						= nil;
		areaBaseValue					= [[NSDecimalNumber notANumber] decimalValue];
		areaBaseValue2					= [[NSDecimalNumber notANumber] decimalValue];
		plotSymbols						= nil;
		plotSymbolMarginForHitDetection = 0.0;
		interpolation					= CPTScatterPlotInterpolationLinear;
		self.labelField					= CPTScatterPlotFieldY;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTScatterPlot *theLayer = (CPTScatterPlot *)layer;

		dataLineStyle					= [theLayer->dataLineStyle retain];
		plotSymbol						= [theLayer->plotSymbol retain];
		areaFill						= [theLayer->areaFill retain];
		areaFill2						= [theLayer->areaFill2 retain];
		areaBaseValue					= theLayer->areaBaseValue;
		areaBaseValue2					= theLayer->areaBaseValue2;
		plotSymbols						= [theLayer->plotSymbols retain];
		plotSymbolMarginForHitDetection = theLayer->plotSymbolMarginForHitDetection;
		interpolation					= theLayer->interpolation;
	}
	return self;
}

-(void)dealloc
{
	[dataLineStyle release];
	[plotSymbol release];
	[areaFill release];
	[areaFill2 release];
	[plotSymbols release];

	[super dealloc];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeInteger:self.interpolation forKey:@"CPTScatterPlot.interpolation"];
	[coder encodeObject:self.dataLineStyle forKey:@"CPTScatterPlot.dataLineStyle"];
	[coder encodeObject:self.plotSymbol forKey:@"CPTScatterPlot.plotSymbol"];
	[coder encodeObject:self.areaFill forKey:@"CPTScatterPlot.areaFill"];
	[coder encodeObject:self.areaFill2 forKey:@"CPTScatterPlot.areaFill2"];
	[coder encodeDecimal:self.areaBaseValue forKey:@"CPTScatterPlot.areaBaseValue"];
	[coder encodeDecimal:self.areaBaseValue2 forKey:@"CPTScatterPlot.areaBaseValue2"];
	[coder encodeCGFloat:self.plotSymbolMarginForHitDetection forKey:@"CPTScatterPlot.plotSymbolMarginForHitDetection"];

	// No need to archive these properties:
	// plotSymbols
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		interpolation					= [coder decodeIntegerForKey:@"CPTScatterPlot.interpolation"];
		dataLineStyle					= [[coder decodeObjectForKey:@"CPTScatterPlot.dataLineStyle"] copy];
		plotSymbol						= [[coder decodeObjectForKey:@"CPTScatterPlot.plotSymbol"] copy];
		areaFill						= [[coder decodeObjectForKey:@"CPTScatterPlot.areaFill"] copy];
		areaFill2						= [[coder decodeObjectForKey:@"CPTScatterPlot.areaFill2"] copy];
		areaBaseValue					= [coder decodeDecimalForKey:@"CPTScatterPlot.areaBaseValue"];
		areaBaseValue2					= [coder decodeDecimalForKey:@"CPTScatterPlot.areaBaseValue2"];
		plotSymbolMarginForHitDetection = [coder decodeCGFloatForKey:@"CPTScatterPlot.plotSymbolMarginForHitDetection"];

		plotSymbols = nil;
	}
	return self;
}

#pragma mark -
#pragma mark Data Loading

///	@cond

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
	[super reloadDataInIndexRange:indexRange];

	if ( self.dataSource ) {
		id<CPTScatterPlotDataSource> theDataSource = (id<CPTScatterPlotDataSource>)self.dataSource;

		id newXValues = [self numbersFromDataSourceForField:CPTScatterPlotFieldX recordIndexRange:indexRange];
		[self cacheNumbers:newXValues forField:CPTScatterPlotFieldX atRecordIndex:indexRange.location];
		id newYValues = [self numbersFromDataSourceForField:CPTScatterPlotFieldY recordIndexRange:indexRange];
		[self cacheNumbers:newYValues forField:CPTScatterPlotFieldY atRecordIndex:indexRange.location];

		BOOL datasourceProvidesSymbolArray = [theDataSource respondsToSelector:@selector(symbolsForScatterPlot:recordIndexRange:)];
		BOOL datasourceProvidesSymbols	   = [theDataSource respondsToSelector:@selector(symbolForScatterPlot:recordIndex:)];

		if ( datasourceProvidesSymbolArray || datasourceProvidesSymbols ) {
			// Ensure the plot symbol array exists and is the right size
			NSMutableArray *symbols	   = (NSMutableArray *)self.plotSymbols;
			NSUInteger numberOfRecords = [theDataSource numberOfRecordsForPlot:self];
			if ( !symbols ) {
				self.plotSymbols = [NSMutableArray array];
				symbols			 = (NSMutableArray *)self.plotSymbols;
			}
			NSNull *nullObject = [NSNull null];
			NSUInteger i	   = symbols.count;
			while ( i < numberOfRecords ) {
				[symbols addObject:nullObject];
				i++;
			}

			// Update plot symbols
			if ( datasourceProvidesSymbolArray ) {
				[symbols replaceObjectsInRange:indexRange withObjectsFromArray:[theDataSource symbolsForScatterPlot:self recordIndexRange:indexRange]];
			}
			else if ( datasourceProvidesSymbols ) {
				NSUInteger indexRangeEnd = indexRange.location + indexRange.length;
				for ( NSUInteger recordIndex = indexRange.location; recordIndex < indexRangeEnd; recordIndex++ ) {
					CPTPlotSymbol *theSymbol = [theDataSource symbolForScatterPlot:self recordIndex:recordIndex];
					if ( theSymbol ) {
						[symbols replaceObjectAtIndex:recordIndex withObject:theSymbol];
					}
					else {
						[symbols replaceObjectAtIndex:recordIndex withObject:nullObject];
					}
				}
			}
		}
		else {
			self.plotSymbols = nil;
		}
	}
	else {
		self.xValues	 = nil;
		self.yValues	 = nil;
		self.plotSymbols = nil;
	}
}

-(void)insertDataAtIndex:(NSUInteger)index numberOfRecords:(NSUInteger)numberOfRecords
{
	NSMutableArray *symbols = (NSMutableArray *)self.plotSymbols;

	if ( index < symbols.count ) {
		NSNull *nullObject = [NSNull null];

		NSUInteger endIndex = index + numberOfRecords;
		for ( NSUInteger i = index; i < endIndex; i++ ) {
			[symbols insertObject:nullObject atIndex:i];
		}
	}

	[super insertDataAtIndex:index numberOfRecords:numberOfRecords];
}

-(void)deleteDataInIndexRange:(NSRange)indexRange
{
	[super deleteDataInIndexRange:indexRange];

	NSMutableArray *symbols = (NSMutableArray *)self.plotSymbols;
	[symbols removeObjectsInRange:indexRange];
}

///	@endcond

#pragma mark -
#pragma mark Symbols

/**	@brief Returns the plot symbol to use for a given index.
 *	@param index The index of the record.
 *	@return The plot symbol to use, or nil if no plot symbol should be drawn.
 **/
-(CPTPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)index
{
	CPTPlotSymbol *symbol = self.plotSymbol;

	if ( index < self.plotSymbols.count ) {
		symbol = [self.plotSymbols objectAtIndex:index];
	}
	if ( ![symbol isKindOfClass:[CPTPlotSymbol class]] ) {
		symbol = nil; // Account for NSNull values
	}
	return symbol;
}

#pragma mark -
#pragma mark Determining Which Points to Draw

///	@cond

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly
{
	NSUInteger dataCount = self.cachedDataCount;

	if ( dataCount == 0 ) {
		return;
	}

	if ( self.areaFill || self.areaFill2 || self.dataLineStyle.dashPattern ) {
		// show all points to preserve the line dash and area fills
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			pointDrawFlags[i] = YES;
		}
	}
	else {
		CPTPlotRangeComparisonResult *xRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
		CPTPlotRangeComparisonResult *yRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
		BOOL *nanFlags							  = malloc( dataCount * sizeof(BOOL) );

		CPTPlotRange *xRange = xyPlotSpace.xRange;
		CPTPlotRange *yRange = xyPlotSpace.yRange;

		// Determine where each point lies in relation to range
		if ( self.doublePrecisionCache ) {
			const double *xBytes = (const double *)[self cachedNumbersForField:CPTScatterPlotFieldX].data.bytes;
			const double *yBytes = (const double *)[self cachedNumbersForField:CPTScatterPlotFieldY].data.bytes;
			for ( NSUInteger i = 0; i < dataCount; i++ ) {
				const double x = *xBytes++;
				const double y = *yBytes++;

				CPTPlotRangeComparisonResult xFlag = [xRange compareToDouble:x];
				xRangeFlags[i] = xFlag;
				if ( xFlag != CPTPlotRangeComparisonResultNumberInRange ) {
					yRangeFlags[i] = CPTPlotRangeComparisonResultNumberInRange; // if x is out of range, then y doesn't matter
				}
				else {
					yRangeFlags[i] = [yRange compareToDouble:y];
				}
				nanFlags[i] = isnan(x) || isnan(y);
			}
		}
		else {
			// Determine where each point lies in relation to range
			const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPTScatterPlotFieldX].data.bytes;
			const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPTScatterPlotFieldY].data.bytes;
			for ( NSUInteger i = 0; i < dataCount; i++ ) {
				const NSDecimal *x = xBytes++;
				const NSDecimal *y = yBytes++;

				CPTPlotRangeComparisonResult xFlag = [xRange compareToDecimal:*x];
				xRangeFlags[i] = xFlag;
				if ( xFlag != CPTPlotRangeComparisonResultNumberInRange ) {
					yRangeFlags[i] = CPTPlotRangeComparisonResultNumberInRange; // if x is out of range, then y doesn't matter
				}
				else {
					yRangeFlags[i] = [yRange compareToDecimal:*y];
				}

				nanFlags[i] = NSDecimalIsNotANumber(x) || NSDecimalIsNotANumber(y);
			}
		}

		// Ensure that whenever the path crosses over a region boundary, both points
		// are included. This ensures no lines are left out that shouldn't be.
		memset( pointDrawFlags, NO, dataCount * sizeof(BOOL) );
		if ( dataCount > 0 ) {
			pointDrawFlags[0] = (xRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
								 yRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
								 !nanFlags[0]);
		}
		for ( NSUInteger i = 1; i < dataCount; i++ ) {
			if ( !visibleOnly && !nanFlags[i - 1] && !nanFlags[i] && ( (xRangeFlags[i - 1] != xRangeFlags[i]) || (yRangeFlags[i - 1] != yRangeFlags[i]) ) ) {
				pointDrawFlags[i - 1] = YES;
				pointDrawFlags[i]	  = YES;
			}
			else if ( (xRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
					  (yRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
					  !nanFlags[i] ) {
				pointDrawFlags[i] = YES;
			}
		}

		free(xRangeFlags);
		free(yRangeFlags);
		free(nanFlags);
	}
}

-(void)calculateViewPoints:(CGPoint *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags
{
	NSUInteger dataCount	   = self.cachedDataCount;
	CPTPlotArea *thePlotArea   = self.plotArea;
	CPTPlotSpace *thePlotSpace = self.plotSpace;
	CGPoint originTransformed  = [self convertPoint:self.frame.origin fromLayer:thePlotArea];

	// Calculate points
	if ( self.doublePrecisionCache ) {
		const double *xBytes = (const double *)[self cachedNumbersForField:CPTScatterPlotFieldX].data.bytes;
		const double *yBytes = (const double *)[self cachedNumbersForField:CPTScatterPlotFieldY].data.bytes;
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const double x = *xBytes++;
			const double y = *yBytes++;
			if ( !drawPointFlags[i] || isnan(x) || isnan(y) ) {
				viewPoints[i] = CGPointMake(NAN, NAN);
			}
			else {
				double plotPoint[2];
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y;
				viewPoints[i]			  = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
				viewPoints[i].x			 += originTransformed.x;
				viewPoints[i].y			 += originTransformed.y;
			}
		}
	}
	else {
		const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPTScatterPlotFieldX].data.bytes;
		const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPTScatterPlotFieldY].data.bytes;
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const NSDecimal x = *xBytes++;
			const NSDecimal y = *yBytes++;
			if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y) ) {
				viewPoints[i] = CGPointMake(NAN, NAN);
			}
			else {
				NSDecimal plotPoint[2];
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y;
				viewPoints[i]			  = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
				viewPoints[i].x			 += originTransformed.x;
				viewPoints[i].y			 += originTransformed.y;
			}
		}
	}
}

-(void)alignViewPointsToUserSpace:(CGPoint *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags
{
	NSUInteger dataCount = self.cachedDataCount;

	// Align to device pixels if there is a data line.
	// Otherwise, align to view space, so fills are sharp at edges.
	if ( self.dataLineStyle.lineWidth > 0.0 ) {
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			if ( drawPointFlags[i] ) {
				viewPoints[i] = CPTAlignPointToUserSpace(theContext, viewPoints[i]);
			}
		}
	}
	else {
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			if ( drawPointFlags[i] ) {
				viewPoints[i] = CPTAlignIntegralPointToUserSpace(theContext, viewPoints[i]);
			}
		}
	}
}

-(NSUInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags extremeNumIsLowerBound:(BOOL)isLowerBound
{
	NSInteger result	 = NSNotFound;
	NSInteger delta		 = (isLowerBound ? 1 : -1);
	NSUInteger dataCount = self.cachedDataCount;

	if ( dataCount > 0 ) {
		NSUInteger initialIndex = (isLowerBound ? 0 : dataCount - 1);
		for ( NSUInteger i = initialIndex; i < dataCount; i += delta ) {
			if ( pointDrawFlags[i] ) {
				result = i;
				break;
			}
			if ( (delta < 0) && (i == 0) ) {
				break;
			}
		}
	}
	return result;
}

///	@endcond

#pragma mark -
#pragma mark View Points

///	@cond

CGFloat squareOfDistanceBetweenPoints(CGPoint point1, CGPoint point2)
{
	CGFloat deltaX			= point1.x - point2.x;
	CGFloat deltaY			= point1.y - point2.y;
	CGFloat distanceSquared = deltaX * deltaX + deltaY * deltaY;

	return distanceSquared;
}

///	@endcond

/**	@brief Returns the index of the closest visible point to the point passed in.
 *	@param viewPoint The reference point.
 *	@return The index of the closest point, or NSNotFound if there is no visible point.
 **/
-(NSUInteger)indexOfVisiblePointClosestToPlotAreaPoint:(CGPoint)viewPoint
{
	NSUInteger dataCount = self.cachedDataCount;
	CGPoint *viewPoints	 = malloc( dataCount * sizeof(CGPoint) );
	BOOL *drawPointFlags = malloc( dataCount * sizeof(BOOL) );

	[self calculatePointsToDraw:drawPointFlags forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];

	NSUInteger result = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:YES];
	if ( result != NSNotFound ) {
		CGFloat minimumDistanceSquared = NAN;
		for ( NSUInteger i = result; i < dataCount; ++i ) {
			CGFloat distanceSquared = squareOfDistanceBetweenPoints(viewPoint, viewPoints[i]);
			if ( isnan(minimumDistanceSquared) || (distanceSquared < minimumDistanceSquared) ) {
				minimumDistanceSquared = distanceSquared;
				result				   = i;
			}
		}
	}

	free(viewPoints);
	free(drawPointFlags);

	return result;
}

/**	@brief Returns the plot area view point of a visible point.
 *	@param index The index of the point.
 *	@return The view point of the visible point at the index passed.
 **/
-(CGPoint)plotAreaPointOfVisiblePointAtIndex:(NSUInteger)index
{
	NSUInteger dataCount = self.cachedDataCount;
	CGPoint *viewPoints	 = malloc( dataCount * sizeof(CGPoint) );
	BOOL *drawPointFlags = malloc( dataCount * sizeof(BOOL) );

	[self calculatePointsToDraw:drawPointFlags forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];

	CGPoint result = viewPoints[index];

	free(viewPoints);
	free(drawPointFlags);

	return result;
}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) {
		return;
	}

	CPTMutableNumericData *xValueData = [self cachedNumbersForField:CPTScatterPlotFieldX];
	CPTMutableNumericData *yValueData = [self cachedNumbersForField:CPTScatterPlotFieldY];

	if ( (xValueData == nil) || (yValueData == nil) ) {
		return;
	}
	NSUInteger dataCount = self.cachedDataCount;
	if ( dataCount == 0 ) {
		return;
	}
	if ( !(self.dataLineStyle || self.areaFill || self.areaFill2 || self.plotSymbol || self.plotSymbols.count) ) {
		return;
	}
	if ( xValueData.numberOfSamples != yValueData.numberOfSamples ) {
		[NSException raise:CPTException format:@"Number of x and y values do not match"];
	}

	[super renderAsVectorInContext:theContext];

	// Calculate view points, and align to user space
	CGPoint *viewPoints	 = malloc( dataCount * sizeof(CGPoint) );
	BOOL *drawPointFlags = malloc( dataCount * sizeof(BOOL) );

	CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];

	BOOL pixelAlign = self.alignsPointsToPixels;
	if ( pixelAlign ) {
		[self alignViewPointsToUserSpace:viewPoints withContent:theContext drawPointFlags:drawPointFlags];
	}

	// Get extreme points
	NSUInteger lastDrawnPointIndex	= [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:NO];
	NSUInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:YES];

	if ( firstDrawnPointIndex != NSNotFound ) {
		NSRange viewIndexRange = NSMakeRange(firstDrawnPointIndex, lastDrawnPointIndex - firstDrawnPointIndex);

		// Draw fills
		NSDecimal theAreaBaseValue;
		CPTFill *theFill;

		for ( NSUInteger i = 0; i < 2; i++ ) {
			switch ( i ) {
				case 0:
					theAreaBaseValue = self.areaBaseValue;
					theFill			 = self.areaFill;
					break;

				case 1:
					theAreaBaseValue = self.areaBaseValue2;
					theFill			 = self.areaFill2;
					break;

				default:
					break;
			}
			if ( theFill && ( !NSDecimalIsNotANumber(&theAreaBaseValue) ) ) {
				// clear the plot shadow if any--not needed for fills
				CGContextSaveGState(theContext);
				CGContextSetShadowWithColor(theContext, CGSizeZero, 0.0, NULL);

				NSNumber *xValue = [xValueData sampleValue:firstDrawnPointIndex];
				NSDecimal plotPoint[2];
				plotPoint[CPTCoordinateX] = [xValue decimalValue];
				plotPoint[CPTCoordinateY] = theAreaBaseValue;
				CGPoint baseLinePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
				if ( self.alignsPointsToPixels ) {
					baseLinePoint = CPTAlignIntegralPointToUserSpace(theContext, baseLinePoint);
				}

				CGPathRef dataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:viewIndexRange baselineYValue:baseLinePoint.y];

				CGContextBeginPath(theContext);
				CGContextAddPath(theContext, dataLinePath);
				[theFill fillPathInContext:theContext];

				CGPathRelease(dataLinePath);

				CGContextRestoreGState(theContext);
			}
		}

		// Draw line
		if ( self.dataLineStyle ) {
			CGPathRef dataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:viewIndexRange baselineYValue:NAN];
			CGContextBeginPath(theContext);
			CGContextAddPath(theContext, dataLinePath);
			[self.dataLineStyle setLineStyleInContext:theContext];
			CGContextStrokePath(theContext);
			CGPathRelease(dataLinePath);
		}

		// Draw plot symbols
		if ( self.plotSymbol || self.plotSymbols.count ) {
			// clear the plot shadow if any--symbols draw their own shadows
			CGContextSetShadowWithColor(theContext, CGSizeZero, 0.0, NULL);

			if ( self.useFastRendering ) {
				CGFloat scale = self.contentsScale;
				for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
					if ( drawPointFlags[i] ) {
						CPTPlotSymbol *currentSymbol = [self plotSymbolForRecordIndex:i];
						[currentSymbol renderInContext:theContext atPoint:viewPoints[i] scale:scale alignToPixels:pixelAlign];
					}
				}
			}
			else {
				for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
					if ( drawPointFlags[i] ) {
						CPTPlotSymbol *currentSymbol = [self plotSymbolForRecordIndex:i];
						[currentSymbol renderAsVectorInContext:theContext atPoint:viewPoints[i] scale:1.0];
					}
				}
			}
		}
	}

	free(viewPoints);
	free(drawPointFlags);
}

-(CGPathRef)newDataLinePathForViewPoints:(CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineYValue:(CGFloat)baselineYValue
{
	CGMutablePathRef dataLinePath				 = CGPathCreateMutable();
	CPTScatterPlotInterpolation theInterpolation = self.interpolation;
	BOOL lastPointSkipped						 = YES;
	CGFloat firstXValue							 = 0.0;
	CGFloat lastXValue							 = 0.0;
	NSUInteger lastDrawnPointIndex				 = NSMaxRange(indexRange);

	for ( NSUInteger i = indexRange.location; i <= lastDrawnPointIndex; i++ ) {
		CGPoint viewPoint = viewPoints[i];

		if ( isnan(viewPoint.x) || isnan(viewPoint.y) ) {
			if ( !lastPointSkipped ) {
				if ( !isnan(baselineYValue) ) {
					CGPathAddLineToPoint(dataLinePath, NULL, lastXValue, baselineYValue);
					CGPathAddLineToPoint(dataLinePath, NULL, firstXValue, baselineYValue);
					CGPathCloseSubpath(dataLinePath);
				}
				lastPointSkipped = YES;
			}
		}
		else {
			if ( lastPointSkipped ) {
				CGPathMoveToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
				lastPointSkipped = NO;
				firstXValue		 = viewPoint.x;
			}
			else {
				switch ( theInterpolation ) {
					case CPTScatterPlotInterpolationLinear:
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
						break;

					case CPTScatterPlotInterpolationStepped:
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoints[i - 1].y);
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
						break;

					case CPTScatterPlotInterpolationHistogram:
					{
						CGFloat x = (viewPoints[i - 1].x + viewPoints[i].x) / (CGFloat)2.0;
						CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoints[i - 1].y);
						CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoint.y);
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
					}
					break;

					default:
						[NSException raise:CPTException format:@"Interpolation method not supported in scatter plot."];
						break;
				}
			}
			lastXValue = viewPoint.x;
		}
	}

	if ( !lastPointSkipped && !isnan(baselineYValue) ) {
		CGPathAddLineToPoint(dataLinePath, NULL, lastXValue, baselineYValue);
		CGPathAddLineToPoint(dataLinePath, NULL, firstXValue, baselineYValue);
		CGPathCloseSubpath(dataLinePath);
	}

	return dataLinePath;
}

-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)index inRect:(CGRect)rect inContext:(CGContextRef)context
{
	[super drawSwatchForLegend:legend atIndex:index inRect:rect inContext:context];

	CPTLineStyle *theLineStyle = self.dataLineStyle;

	if ( theLineStyle ) {
		[theLineStyle setLineStyleInContext:context];

		CGPoint alignedStartPoint = CPTAlignPointToUserSpace( context, CGPointMake( CGRectGetMinX(rect), CGRectGetMidY(rect) ) );
		CGPoint alignedEndPoint	  = CPTAlignPointToUserSpace( context, CGPointMake( CGRectGetMaxX(rect), CGRectGetMidY(rect) ) );
		CGContextMoveToPoint(context, alignedStartPoint.x, alignedStartPoint.y);
		CGContextAddLineToPoint(context, alignedEndPoint.x, alignedEndPoint.y);

		CGContextStrokePath(context);
	}

	CPTPlotSymbol *thePlotSymbol = self.plotSymbol;

	if ( thePlotSymbol ) {
		[thePlotSymbol renderInContext:context
							   atPoint:CGPointMake( CGRectGetMidX(rect), CGRectGetMidY(rect) )
								 scale:self.contentsScale
						 alignToPixels:YES];
	}

	// if no line or plot symbol, use the area fills to draw the swatch
	if ( !theLineStyle && !thePlotSymbol ) {
		CPTFill *fill1 = self.areaFill;
		CPTFill *fill2 = self.areaFill2;

		if ( fill1 || fill2 ) {
			CGPathRef swatchPath;
			CGFloat radius = legend.swatchCornerRadius;
			if ( radius > 0.0 ) {
				radius	   = MIN(MIN(radius, rect.size.width / (CGFloat)2.0), rect.size.height / (CGFloat)2.0);
				swatchPath = CreateRoundedRectPath(rect, radius);
			}
			else {
				CGMutablePathRef mutablePath = CGPathCreateMutable();
				CGPathAddRect(mutablePath, NULL, rect);
				swatchPath = mutablePath;
			}

			if ( fill1 && !fill2 ) {
				CGContextBeginPath(context);
				CGContextAddPath(context, swatchPath);
				[fill1 fillPathInContext:context];
			}
			else if ( !fill1 && fill2 ) {
				CGContextBeginPath(context);
				CGContextAddPath(context, swatchPath);
				[fill2 fillPathInContext:context];
			}
			else {
				CGContextSaveGState(context);
				CGContextAddPath(context, swatchPath);
				CGContextClip(context);

				if ( CPTDecimalGreaterThanOrEqualTo(self.areaBaseValue2, self.areaBaseValue) ) {
					[fill1 fillRect:CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), rect.size.width, rect.size.height / (CGFloat)2.0) inContext:context];
					[fill2 fillRect:CGRectMake(CGRectGetMinX(rect), CGRectGetMidY(rect), rect.size.width, rect.size.height / (CGFloat)2.0) inContext:context];
				}
				else {
					[fill2 fillRect:CGRectMake(CGRectGetMinX(rect), CGRectGetMinY(rect), rect.size.width, rect.size.height / (CGFloat)2.0) inContext:context];
					[fill1 fillRect:CGRectMake(CGRectGetMinX(rect), CGRectGetMidY(rect), rect.size.width, rect.size.height / (CGFloat)2.0) inContext:context];
				}

				CGContextRestoreGState(context);
			}

			CGPathRelease(swatchPath);
		}
	}
}

/// @endcond

#pragma mark -
#pragma mark Animation

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
	static NSArray *keys = nil;

	if ( !keys ) {
		keys = [[NSArray alloc] initWithObjects:
				nil];
	}

	if ( [keys containsObject:aKey] ) {
		return YES;
	}
	else {
		return [super needsDisplayForKey:aKey];
	}
}

#pragma mark -
#pragma mark Fields

/// @cond

-(NSUInteger)numberOfFields
{
	return 2;
}

-(NSArray *)fieldIdentifiers
{
	return [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPTScatterPlotFieldX], [NSNumber numberWithUnsignedInt:CPTScatterPlotFieldY], nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
	NSArray *result = nil;

	switch ( coord ) {
		case CPTCoordinateX:
			result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTScatterPlotFieldX]];
			break;

		case CPTCoordinateY:
			result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTScatterPlotFieldY]];
			break;

		default:
			[NSException raise:CPTException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
			break;
	}
	return result;
}

/// @endcond

#pragma mark -
#pragma mark Data Labels

/// @cond

-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	NSNumber *xValue = [self cachedNumberForField:CPTScatterPlotFieldX recordIndex:index];
	NSNumber *yValue = [self cachedNumberForField:CPTScatterPlotFieldY recordIndex:index];

	BOOL positiveDirection = YES;
	CPTPlotRange *yRange   = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];

	if ( CPTDecimalLessThan( yRange.length, CPTDecimalFromInteger(0) ) ) {
		positiveDirection = !positiveDirection;
	}

	label.anchorPlotPoint	  = [NSArray arrayWithObjects:xValue, yValue, nil];
	label.contentLayer.hidden = isnan([xValue doubleValue]) || isnan([yValue doubleValue]);

	if ( positiveDirection ) {
		label.displacement = CGPointMake(0.0, self.labelOffset);
	}
	else {
		label.displacement = CGPointMake(0.0, -self.labelOffset);
	}
}

/// @endcond

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

/**
 *	@brief Informs the receiver that the user has
 *	@if MacOnly pressed the mouse button. @endif
 *	@if iOSOnly touched the screen. @endif
 *
 *
 *	If this plot has a delegate that responds to the
 *	@link CPTScatterPlotDelegate::scatterPlot:plotSymbolWasSelectedAtRecordIndex: -scatterPlot:plotSymbolWasSelectedAtRecordIndex: @endlink
 *	method, the data points are searched to find the index of the one closest to the <code>interactionPoint</code>.
 *	The delegate method will be called and this method returns <code>YES</code> if the <code>interactionPoint</code> is within the
 *	@link CPTScatterPlot::plotSymbolMarginForHitDetection plotSymbolMarginForHitDetection @endlink
 *	of the closest data point.
 *	This method returns <code>NO</code> if the <code>interactionPoint</code> is too far away from all of the data points.
 *
 *	@param event The OS event.
 *	@param interactionPoint The coordinates of the interaction.
 *  @return Whether the event was handled or not.
 **/
-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result = NO;

	if ( !self.graph || !self.plotArea ) {
		return NO;
	}

	id<CPTScatterPlotDelegate> theDelegate = self.delegate;
	if ( [theDelegate respondsToSelector:@selector(scatterPlot:plotSymbolWasSelectedAtRecordIndex:)] ) {
		// Inform delegate if a point was hit
		CGPoint plotAreaPoint = [self.graph convertPoint:interactionPoint toLayer:self.plotArea];
		NSUInteger index	  = [self indexOfVisiblePointClosestToPlotAreaPoint:plotAreaPoint];
		CGPoint center		  = [self plotAreaPointOfVisiblePointAtIndex:index];
		CPTPlotSymbol *symbol = [self plotSymbolForRecordIndex:index];

		CGRect symbolRect = CGRectZero;
		symbolRect.size			= symbol.size;
		symbolRect.size.width  += (CGFloat)2.0 * plotSymbolMarginForHitDetection;
		symbolRect.size.height += (CGFloat)2.0 * plotSymbolMarginForHitDetection;
		symbolRect.origin		= CGPointMake( center.x - (CGFloat)0.5 * CGRectGetWidth(symbolRect), center.y - (CGFloat)0.5 * CGRectGetHeight(symbolRect) );

		if ( CGRectContainsPoint(symbolRect, plotAreaPoint) ) {
			[theDelegate scatterPlot:self plotSymbolWasSelectedAtRecordIndex:index];
			result = YES;
		}
	}
	else {
		result = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
	}

	return result;
}

///	@}

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setInterpolation:(CPTScatterPlotInterpolation)newInterpolation
{
	if ( newInterpolation != interpolation ) {
		interpolation = newInterpolation;
		[self setNeedsDisplay];
	}
}

-(void)setPlotSymbol:(CPTPlotSymbol *)aSymbol
{
	if ( aSymbol != plotSymbol ) {
		[plotSymbol release];
		plotSymbol = [aSymbol copy];
		[self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

-(void)setDataLineStyle:(CPTLineStyle *)newLineStyle
{
	if ( dataLineStyle != newLineStyle ) {
		[dataLineStyle release];
		dataLineStyle = [newLineStyle copy];
		[self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

-(void)setAreaFill:(CPTFill *)newFill
{
	if ( newFill != areaFill ) {
		[areaFill release];
		areaFill = [newFill copy];
		[self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

-(void)setAreaFill2:(CPTFill *)newFill
{
	if ( newFill != areaFill2 ) {
		[areaFill2 release];
		areaFill2 = [newFill copy];
		[self setNeedsDisplay];
		[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
	}
}

-(void)setAreaBaseValue:(NSDecimal)newAreaBaseValue
{
	if ( CPTDecimalEquals(areaBaseValue, newAreaBaseValue) ) {
		return;
	}
	areaBaseValue = newAreaBaseValue;
	[self setNeedsDisplay];
	[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
}

-(void)setAreaBaseValue2:(NSDecimal)newAreaBaseValue
{
	if ( CPTDecimalEquals(areaBaseValue2, newAreaBaseValue) ) {
		return;
	}
	areaBaseValue2 = newAreaBaseValue;
	[self setNeedsDisplay];
	[[NSNotificationCenter defaultCenter] postNotificationName:CPTLegendNeedsRedrawForPlotNotification object:self];
}

-(void)setXValues:(NSArray *)newValues
{
	[self cacheNumbers:newValues forField:CPTScatterPlotFieldX];
}

-(NSArray *)xValues
{
	return [[self cachedNumbersForField:CPTScatterPlotFieldX] sampleArray];
}

-(void)setYValues:(NSArray *)newValues
{
	[self cacheNumbers:newValues forField:CPTScatterPlotFieldY];
}

-(NSArray *)yValues
{
	return [[self cachedNumbersForField:CPTScatterPlotFieldY] sampleArray];
}

-(void)setPlotSymbols:(NSArray *)newSymbols
{
	if ( newSymbols != plotSymbols ) {
		[plotSymbols release];
		plotSymbols = [newSymbols mutableCopy];
		[self setNeedsDisplay];
	}
}

///	@endcond

@end
