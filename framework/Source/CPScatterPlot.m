#import <stdlib.h>
#import "CPMutableNumericData.h"
#import "CPNumericData.h"
#import "CPScatterPlot.h"
#import "CPLineStyle.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPPlotSpaceAnnotation.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPXYPlotSpace.h"
#import "CPPlotSymbol.h"
#import "CPFill.h"

NSString * const CPScatterPlotBindingXValues = @"xValues";							///< X values.
NSString * const CPScatterPlotBindingYValues = @"yValues";							///< Y values.
NSString * const CPScatterPlotBindingPlotSymbols = @"plotSymbols";					///< Plot symbols.

/// @cond
@interface CPScatterPlot ()

@property (nonatomic, readwrite, copy) NSArray *xValues;
@property (nonatomic, readwrite, copy) NSArray *yValues;
@property (nonatomic, readwrite, retain) NSArray *plotSymbols;

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPXYPlotSpace *)plotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)calculateViewPoints:(CGPoint *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags;
-(void)alignViewPointsToUserSpace:(CGPoint *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags;

-(NSUInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags extremeNumIsLowerBound:(BOOL)isLowerBound;

-(CGPathRef)newDataLinePathForViewPoints:(CGPoint *)viewPoints indexRange:(NSRange)indexRange baselineYValue:(CGFloat)baselineYValue;

CGFloat squareOfDistanceBetweenPoints(CGPoint point1, CGPoint point2);

@end
/// @endcond

#pragma mark -

/** @brief A two-dimensional scatter plot.
 **/
@implementation CPScatterPlot

@dynamic xValues;
@dynamic yValues;
@synthesize plotSymbols;

/** @property interpolation
 *	@brief The interpolation algorithm used for lines between data points. 
 *	Default is CPScatterPlotInterpolationLinear
 **/
@synthesize interpolation;

/** @property dataLineStyle
 *	@brief The line style for the data line.
 *	If nil, the line is not drawn.
 **/
@synthesize dataLineStyle;

/** @property plotSymbol
 *	@brief The plot symbol drawn at each point if the data source does not provide symbols.
 *	If nil, no symbol is drawn.
 **/
@synthesize plotSymbol;

/** @property areaFill 
 *	@brief The fill style for the area underneath the data line.
 *	If nil, the area is not filled.
 **/
@synthesize areaFill;

/** @property areaFill2
 *	@brief The fill style for the area above the data line.
 *	If nil, the area is not filled.
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
	if ( self == [CPScatterPlot class] ) {
		[self exposeBinding:CPScatterPlotBindingXValues];	
		[self exposeBinding:CPScatterPlotBindingYValues];	
		[self exposeBinding:CPScatterPlotBindingPlotSymbols];	
	}
}
#endif

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		dataLineStyle = [[CPLineStyle alloc] init];
		dataLineStyle.delegate = self;
		plotSymbol = nil;
		areaFill = nil;
		areaFill2 = nil;
		areaBaseValue = [[NSDecimalNumber notANumber] decimalValue];
		areaBaseValue = [[NSDecimalNumber notANumber] decimalValue];
		plotSymbols = nil;
        plotSymbolMarginForHitDetection = 0.0f;
        interpolation = CPScatterPlotInterpolationLinear;
		self.labelField = CPScatterPlotFieldY;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPScatterPlot *theLayer = (CPScatterPlot *)layer;
		
		dataLineStyle = [theLayer->dataLineStyle retain];
		plotSymbol = [theLayer->plotSymbol retain];
		areaFill = [theLayer->areaFill retain];
		areaFill2 = [theLayer->areaFill2 retain];
		areaBaseValue = theLayer->areaBaseValue;
		areaBaseValue2 = theLayer->areaBaseValue2;
		plotSymbols = [theLayer->plotSymbols retain];
		plotSymbolMarginForHitDetection = theLayer->plotSymbolMarginForHitDetection;
		interpolation = theLayer->interpolation;
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

#pragma mark -
#pragma mark Data Loading

-(void)reloadDataInIndexRange:(NSRange)indexRange
{	 
	[super reloadDataInIndexRange:indexRange];
	
	if ( self.dataSource ) {
		id <CPScatterPlotDataSource> theDataSource = (id <CPScatterPlotDataSource>)self.dataSource;
		
		id newXValues = [self numbersFromDataSourceForField:CPScatterPlotFieldX recordIndexRange:indexRange];
		[self cacheNumbers:newXValues forField:CPScatterPlotFieldX atRecordIndex:indexRange.location];
		id newYValues = [self numbersFromDataSourceForField:CPScatterPlotFieldY recordIndexRange:indexRange];
		[self cacheNumbers:newYValues forField:CPScatterPlotFieldY atRecordIndex:indexRange.location];
		
		BOOL datasourceProvidesSymbolArray = [theDataSource respondsToSelector:@selector(symbolsForScatterPlot:recordIndexRange:)];
		BOOL datasourceProvidesSymbols = [theDataSource respondsToSelector:@selector(symbolForScatterPlot:recordIndex:)];
		
		if ( datasourceProvidesSymbolArray || datasourceProvidesSymbols	) {
			// Ensure the plot symbol array exists and is the right size
			NSMutableArray *symbols = (NSMutableArray *)self.plotSymbols;
			NSUInteger numberOfRecords = [theDataSource numberOfRecordsForPlot:self];
			if ( !symbols ) {
				self.plotSymbols = [NSMutableArray array];
				symbols = (NSMutableArray *)self.plotSymbols;
			}
			NSNull *nullObject = [NSNull null];
			NSUInteger i = symbols.count;
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
					CPPlotSymbol *theSymbol = [theDataSource symbolForScatterPlot:self recordIndex:recordIndex];
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
		self.xValues = nil;
		self.yValues = nil;
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

#pragma mark -
#pragma mark Symbols

/**	@brief Returns the plot symbol to use for a given index.
 *	@param index The index of the record.
 *	@return The plot symbol to use, or nil if no plot symbol should be drawn.
 **/
-(CPPlotSymbol *)plotSymbolForRecordIndex:(NSUInteger)index
{
    CPPlotSymbol *symbol = self.plotSymbol;
    if ( index < self.plotSymbols.count ) symbol = [self.plotSymbols objectAtIndex:index];
    if ( ![symbol isKindOfClass:[CPPlotSymbol class]] ) symbol = nil; // Account for NSNull values
    return symbol;
}

#pragma mark -
#pragma mark Determining Which Points to Draw

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly
{    
	NSUInteger dataCount = self.cachedDataCount;
    if ( dataCount == 0 ) return;
	
	if ( self.areaFill || self.areaFill2 || self.dataLineStyle.dashPattern ) {
		// show all points to preserve the line dash and area fills
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			pointDrawFlags[i] = YES;
		}
	}
	else {
		CPPlotRangeComparisonResult *xRangeFlags = malloc(dataCount * sizeof(CPPlotRangeComparisonResult));
		CPPlotRangeComparisonResult *yRangeFlags = malloc(dataCount * sizeof(CPPlotRangeComparisonResult));
		BOOL *nanFlags = malloc(dataCount * sizeof(BOOL));
		
		CPPlotRange *xRange = xyPlotSpace.xRange;
		CPPlotRange *yRange = xyPlotSpace.yRange;
		
		// Determine where each point lies in relation to range
		if ( self.doublePrecisionCache ) {
			const double *xBytes = (const double *)[self cachedNumbersForField:CPScatterPlotFieldX].data.bytes;
			const double *yBytes = (const double *)[self cachedNumbersForField:CPScatterPlotFieldY].data.bytes;
			for ( NSUInteger i = 0; i < dataCount; i++ ) {
				const double x = *xBytes++;
				const double y = *yBytes++;
				
				xRangeFlags[i] = [xRange compareToDouble:x];
				yRangeFlags[i] = [yRange compareToDouble:y];
				nanFlags[i] = isnan(x) || isnan(y);
			}
		}
		else {
			// Determine where each point lies in relation to range
			const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPScatterPlotFieldX].data.bytes;
			const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPScatterPlotFieldY].data.bytes;
			for ( NSUInteger i = 0; i < dataCount; i++ ) {
				const NSDecimal *x = xBytes++;
				const NSDecimal *y = yBytes++;
				
				xRangeFlags[i] = [xRange compareToDecimal:*x];
				yRangeFlags[i] = [yRange compareToDecimal:*y];
				nanFlags[i] = NSDecimalIsNotANumber(x) || NSDecimalIsNotANumber(y);
			}
		}
		
		// Ensure that whenever the path crosses over a region boundary, both points 
		// are included. This ensures no lines are left out that shouldn't be.
		pointDrawFlags[0] = (xRangeFlags[0] == CPPlotRangeComparisonResultNumberInRange && 
							 yRangeFlags[0] == CPPlotRangeComparisonResultNumberInRange &&
							 !nanFlags[0]);
		for ( NSUInteger i = 1; i < dataCount; i++ ) {
			pointDrawFlags[i] = NO;
			if ( !visibleOnly && !nanFlags[i-1] && !nanFlags[i] && ((xRangeFlags[i-1] != xRangeFlags[i]) || (yRangeFlags[i-1] != yRangeFlags[i])) ) {
				pointDrawFlags[i-1] = YES;
				pointDrawFlags[i] = YES;
			}
			else if ( (xRangeFlags[i] == CPPlotRangeComparisonResultNumberInRange) && 
					 (yRangeFlags[i] == CPPlotRangeComparisonResultNumberInRange) &&
					 !nanFlags[i]) {
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
	NSUInteger dataCount = self.cachedDataCount;
	CPPlotArea *thePlotArea = self.plotArea;
	CPPlotSpace *thePlotSpace = self.plotSpace;
	
    // Calculate points
    if ( self.doublePrecisionCache ) {
        const double *xBytes = (const double *)[self cachedNumbersForField:CPScatterPlotFieldX].data.bytes;
        const double *yBytes = (const double *)[self cachedNumbersForField:CPScatterPlotFieldY].data.bytes;
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const double x = *xBytes++;
			const double y = *yBytes++;
			if ( !drawPointFlags[i] || isnan(x) || isnan(y) ) {
				viewPoints[i] = CGPointMake(NAN, NAN);
			}
			else {
				double plotPoint[2];
				plotPoint[CPCoordinateX] = x;
				plotPoint[CPCoordinateY] = y;
				viewPoints[i] = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
        }
    }
    else {
        const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPScatterPlotFieldX].data.bytes;
        const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPScatterPlotFieldY].data.bytes;
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const NSDecimal x = *xBytes++;
			const NSDecimal y = *yBytes++;
			if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y) ) {
				viewPoints[i] = CGPointMake(NAN, NAN);
			}
			else {
				NSDecimal plotPoint[2];
				plotPoint[CPCoordinateX] = x;
				plotPoint[CPCoordinateY] = y;
				viewPoints[i] = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
        }
    }	
}

-(void)alignViewPointsToUserSpace:(CGPoint *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags
{
	NSUInteger dataCount = self.cachedDataCount;
	for ( NSUInteger i = 0; i < dataCount; i++ ) {
		if ( drawPointFlags[i] ) {
			viewPoints[i] = CPAlignPointToUserSpace(theContext, viewPoints[i]);      
		}
	}
}

-(NSUInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags extremeNumIsLowerBound:(BOOL)isLowerBound 
{
	NSInteger result = NSNotFound;
	NSInteger delta = (isLowerBound ? 1 : -1);
	NSUInteger dataCount = self.cachedDataCount;
	if ( dataCount > 0 ) {
		NSUInteger initialIndex = (isLowerBound ? 0 : dataCount - 1);
		for ( NSUInteger i = initialIndex; i < dataCount; i += delta ) {
			if ( pointDrawFlags[i] ) {
				result = i;
				break;
			}
			if ( (delta < 0) && (i == 0) ) break;
		}	
	}
	return result;
}

#pragma mark -
#pragma mark View Points

CGFloat squareOfDistanceBetweenPoints(CGPoint point1, CGPoint point2)
{
	CGFloat deltaX = point1.x - point2.x;
	CGFloat deltaY = point1.y - point2.y;
	CGFloat distanceSquared = deltaX * deltaX + deltaY * deltaY;
	return distanceSquared;
}

/**	@brief Returns the index of the closest visible point to the point passed in.
 *	@param viewPoint The reference point.
 *	@return The index of the closest point, or NSNotFound if there is no visible point.
 **/
-(NSUInteger)indexOfVisiblePointClosestToPlotAreaPoint:(CGPoint)viewPoint 
{
	NSUInteger dataCount = self.cachedDataCount;
	CGPoint *viewPoints = malloc(dataCount * sizeof(CGPoint));
	BOOL *drawPointFlags = malloc(dataCount * sizeof(BOOL));	
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];
	
	NSUInteger result = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:YES];
	if ( result != NSNotFound ) {
		CGFloat minimumDistanceSquared = squareOfDistanceBetweenPoints(viewPoint, viewPoints[result]);
		for ( NSUInteger i = result + 1; i < dataCount; ++i ) {
			CGFloat distanceSquared = squareOfDistanceBetweenPoints(viewPoint, viewPoints[i]);
			if ( distanceSquared < minimumDistanceSquared ) {
				minimumDistanceSquared = distanceSquared;
				result = i;
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
	CGPoint *viewPoints = malloc(dataCount * sizeof(CGPoint));
	BOOL *drawPointFlags = malloc(dataCount * sizeof(BOOL));
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];
	
	CGPoint result = viewPoints[index];
	
	free(viewPoints);
	free(drawPointFlags);
	
	return result;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	CPMutableNumericData *xValueData = [self cachedNumbersForField:CPScatterPlotFieldX];
	CPMutableNumericData *yValueData = [self cachedNumbersForField:CPScatterPlotFieldY];
	
	if ( xValueData == nil || yValueData == nil ) return;
	NSUInteger dataCount = self.cachedDataCount;
	if ( dataCount == 0 ) return;
	if ( !(self.dataLineStyle || self.areaFill || self.areaFill2 || self.plotSymbol || self.plotSymbols.count) ) return;
	if ( xValueData.numberOfSamples != yValueData.numberOfSamples ) {
		[NSException raise:CPException format:@"Number of x and y values do not match"];
	}
	
	[super renderAsVectorInContext:theContext];
	
	// Calculate view points, and align to user space
	CGPoint *viewPoints = malloc(dataCount * sizeof(CGPoint));
	BOOL *drawPointFlags = malloc(dataCount * sizeof(BOOL));
    
	CPXYPlotSpace *thePlotSpace = (CPXYPlotSpace *)self.plotSpace;
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];
	[self alignViewPointsToUserSpace:viewPoints withContent:theContext drawPointFlags:drawPointFlags];
	
	// Get extreme points
	NSUInteger lastDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:NO];
	NSUInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:YES];
	
	if ( firstDrawnPointIndex != NSNotFound ) {
		NSRange viewIndexRange = NSMakeRange(firstDrawnPointIndex, lastDrawnPointIndex - firstDrawnPointIndex);
		
		// Draw fills
		NSDecimal theAreaBaseValue;
		CPFill *theFill;
		
		for ( NSUInteger i = 0; i < 2; i++ ) {
			switch ( i ) {
				case 0:
					theAreaBaseValue = self.areaBaseValue;
					theFill = self.areaFill;
					break;
				case 1:
					theAreaBaseValue = self.areaBaseValue2;
					theFill = self.areaFill2;
					break;
					
				default:
					break;
			}
			if ( theFill && (!NSDecimalIsNotANumber(&theAreaBaseValue)) ) {	
				NSNumber *xValue = [xValueData sampleValue:firstDrawnPointIndex];
				NSDecimal plotPoint[2];
				plotPoint[CPCoordinateX] = [xValue decimalValue];
				plotPoint[CPCoordinateY] = theAreaBaseValue;
				CGPoint baseLinePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
				
				CGPathRef dataLinePath = [self newDataLinePathForViewPoints:viewPoints indexRange:viewIndexRange baselineYValue:baseLinePoint.y];
				
				CGContextBeginPath(theContext);
				CGContextAddPath(theContext, dataLinePath);
				[theFill fillPathInContext:theContext];
				
				CGPathRelease(dataLinePath);
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
			if ( self.useFastRendering ) {
				for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
					if ( drawPointFlags[i] ) {
						CPPlotSymbol *currentSymbol = [self plotSymbolForRecordIndex:i];
						[currentSymbol renderInContext:theContext atPoint:viewPoints[i]];	
					}
				}
			}
			else {
				for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
					if ( drawPointFlags[i] ) {
						CPPlotSymbol *currentSymbol = [self plotSymbolForRecordIndex:i];
						[currentSymbol renderAsVectorInContext:theContext atPoint:viewPoints[i]];	
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
	CGMutablePathRef dataLinePath = CGPathCreateMutable();
	CPScatterPlotInterpolation theInterpolation = self.interpolation;
	BOOL lastPointSkipped = YES;
	CGFloat firstXValue = 0.0;
	CGFloat lastXValue = 0.0;
	NSUInteger lastDrawnPointIndex = NSMaxRange(indexRange);
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
				firstXValue = viewPoint.x;
			} else {
				switch ( theInterpolation ) {
					case CPScatterPlotInterpolationLinear:
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
						break;
					case CPScatterPlotInterpolationStepped:
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoints[i-1].y);
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
						break;
					case CPScatterPlotInterpolationHistogram: {
						CGFloat x = (viewPoints[i-1].x + viewPoints[i].x) / 2.0;
						CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoints[i-1].y);
						CGPathAddLineToPoint(dataLinePath, NULL, x, viewPoint.y);
						CGPathAddLineToPoint(dataLinePath, NULL, viewPoint.x, viewPoint.y);
					}
						break;
					default:	
						[NSException raise:CPException format:@"Interpolation method not supported in scatter plot."];
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

#pragma mark -
#pragma mark Fields

-(NSUInteger)numberOfFields 
{
    return 2;
}

-(NSArray *)fieldIdentifiers 
{
    return [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPScatterPlotFieldX], [NSNumber numberWithUnsignedInt:CPScatterPlotFieldY], nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord 
{
	NSArray *result = nil;
	switch (coord) {
        case CPCoordinateX:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPScatterPlotFieldX]];
            break;
        case CPCoordinateY:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPScatterPlotFieldY]];
            break;
        default:
        	[NSException raise:CPException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
            break;
    }
    return result;
}

#pragma mark -
#pragma mark Data Labels

-(void)positionLabelAnnotation:(CPPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	NSNumber *xValue = [self cachedNumberForField:CPScatterPlotFieldX recordIndex:index];
	NSNumber *yValue = [self cachedNumberForField:CPScatterPlotFieldY recordIndex:index];
	
	BOOL positiveDirection = YES;
	CPPlotRange *yRange = [self.plotSpace plotRangeForCoordinate:CPCoordinateY];
	if ( CPDecimalLessThan(yRange.length, CPDecimalFromInteger(0)) ) {
		positiveDirection = !positiveDirection;
	}
	
	label.anchorPlotPoint = [NSArray arrayWithObjects:xValue, yValue, nil];
	label.contentLayer.hidden = isnan([xValue doubleValue]) || isnan([yValue doubleValue]);
	
	if ( positiveDirection ) {
		label.displacement = CGPointMake(0.0, self.labelOffset);
	}
	else {
		label.displacement = CGPointMake(0.0, -self.labelOffset);
	}
}

#pragma mark -
#pragma mark Responder Chain and User interaction

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result = NO;
	if ( !self.graph || !self.plotArea ) return NO;
    
	id <CPScatterPlotDelegate> theDelegate = self.delegate;
	if ( [theDelegate respondsToSelector:@selector(scatterPlot:plotSymbolWasSelectedAtRecordIndex:)] ) {
    	// Inform delegate if a point was hit
        CGPoint plotAreaPoint = [self.graph convertPoint:interactionPoint toLayer:self.plotArea];
        NSUInteger index = [self indexOfVisiblePointClosestToPlotAreaPoint:plotAreaPoint];
        CGPoint center = [self plotAreaPointOfVisiblePointAtIndex:index];
        CPPlotSymbol *symbol = [self plotSymbolForRecordIndex:index];
        
        CGRect symbolRect = CGRectZero;
        symbolRect.size = symbol.size;
        symbolRect.size.width += 2.0 * plotSymbolMarginForHitDetection;
        symbolRect.size.height += 2.0 * plotSymbolMarginForHitDetection;
        symbolRect.origin = CGPointMake(center.x - 0.5 * CGRectGetWidth(symbolRect), center.y - 0.5 * CGRectGetHeight(symbolRect));
        
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

#pragma mark -
#pragma mark Accessors

-(void)setInterpolation:(CPScatterPlotInterpolation)newInterpolation
{
	if ( newInterpolation != interpolation ) {
		interpolation = newInterpolation;
		[self setNeedsDisplay];
	}
}

-(void)setPlotSymbol:(CPPlotSymbol *)aSymbol
{
	if ( aSymbol != plotSymbol ) {
		[plotSymbol release];
		plotSymbol = [aSymbol copy];
		[self setNeedsDisplay];
	}
}

-(void)setDataLineStyle:(CPLineStyle *)newLineStyle
{
	if ( dataLineStyle != newLineStyle ) {
		dataLineStyle.delegate = nil;
		[dataLineStyle release];
		dataLineStyle = [newLineStyle copy];
		dataLineStyle.delegate = self;
		[self setNeedsDisplay];
	}
}

-(void)setAreaFill:(CPFill *)newFill
{
	if ( newFill != areaFill ) {
		[areaFill release];
		areaFill = [newFill copy];
		[self setNeedsDisplay];
	}
}

-(void)setAreaFill2:(CPFill *)newFill
{
	if ( newFill != areaFill2 ) {
		[areaFill2 release];
		areaFill2 = [newFill copy];
		[self setNeedsDisplay];
	}
}

-(void)setAreaBaseValue:(NSDecimal)newAreaBaseValue
{
	if ( CPDecimalEquals(areaBaseValue, newAreaBaseValue) ) {
		return;
	}
	areaBaseValue = newAreaBaseValue;
	[self setNeedsDisplay];
}

-(void)setAreaBaseValue2:(NSDecimal)newAreaBaseValue
{
	if ( CPDecimalEquals(areaBaseValue2, newAreaBaseValue) ) {
		return;
	}
	areaBaseValue2 = newAreaBaseValue;
	[self setNeedsDisplay];
}

-(void)setXValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPScatterPlotFieldX];
}

-(NSArray *)xValues 
{
    return [[self cachedNumbersForField:CPScatterPlotFieldX] sampleArray];
}

-(void)setYValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPScatterPlotFieldY];
}

-(NSArray *)yValues 
{
    return [[self cachedNumbersForField:CPScatterPlotFieldY] sampleArray];
}

-(void)setPlotSymbols:(NSArray *)newSymbols 
{
    if ( newSymbols != plotSymbols ) {
		[plotSymbols release];
		plotSymbols = [newSymbols mutableCopy];
		[self setNeedsDisplay];
	}
}

@end
