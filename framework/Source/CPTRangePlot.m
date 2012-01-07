#import "CPTRangePlot.h"

#import "CPTColor.h"
#import "CPTExceptions.h"
#import "CPTFill.h"
#import "CPTLegend.h"
#import "CPTLineStyle.h"
#import "CPTMutableNumericData.h"
#import "CPTNumericData.h"
#import "CPTPathExtensions.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "NSCoderExtensions.h"

/**	@defgroup plotAnimationRangePlot Range Plot
 *	@ingroup plotAnimation
 **/

/**	@if MacOnly
 *	@defgroup plotBindingsRangePlot Range Plot Bindings
 *	@ingroup plotBindings
 *	@endif
 **/

NSString *const CPTRangePlotBindingXValues	   = @"xValues";     ///< X values.
NSString *const CPTRangePlotBindingYValues	   = @"yValues";     ///< Y values.
NSString *const CPTRangePlotBindingHighValues  = @"highValues";  ///< high values.
NSString *const CPTRangePlotBindingLowValues   = @"lowValues";   ///< low values.
NSString *const CPTRangePlotBindingLeftValues  = @"leftValues";  ///< left price values.
NSString *const CPTRangePlotBindingRightValues = @"rightValues"; ///< right price values.

///	@cond
struct CGPointError {
	CGFloat x;
	CGFloat y;
	CGFloat high;
	CGFloat low;
	CGFloat left;
	CGFloat right;
};
typedef struct CGPointError CGPointError;

@interface CPTRangePlot()

@property (nonatomic, readwrite, copy) NSArray *xValues;
@property (nonatomic, readwrite, copy) NSArray *yValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *highValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *lowValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *leftValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *rightValues;

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)calculateViewPoints:(CGPointError *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags;
-(void)alignViewPointsToUserSpace:(CGPointError *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags;
-(NSUInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags extremeNumIsLowerBound:(BOOL)isLowerBound;

-(void)drawRangeInContext:(CGContextRef)theContext viewPoint:(CGPointError *)viewPoint halfGapSize:(CGSize)halfGapSize halfBarWidth:(CGFloat)halfBarWidth alignPoints:(BOOL)alignPoints;

@end

///	@endcond

/**	@brief A plot class representing a range of values in one coordinate,
 *  such as typically used to show errors.
 *  A range plot can show bars (error bars), or an area fill, or both.
 *	@see See @ref plotAnimationRangePlot "Range Plot" for a list of animatable properties.
 *	@if MacOnly
 *	@see See @ref plotBindingsRangePlot "Range Plot Bindings" for a list of supported binding identifiers.
 *	@endif
 **/
@implementation CPTRangePlot

@dynamic xValues;
@dynamic yValues;
@dynamic highValues;
@dynamic lowValues;
@dynamic leftValues;
@dynamic rightValues;

/** @property areaFill
 *	@brief The fill used to render the area.
 *	Set to <code>nil</code> to have no fill. Default is <code>nil</code>.
 **/
@synthesize areaFill;

/** @property barLineStyle
 *	@brief The line style of the range bars.
 *	Set to <code>nil</code> to have no bars. Default is a black line style.
 **/
@synthesize barLineStyle;

/** @property barWidth
 *	@brief Width of the lateral sections of the bars.
 *	@ingroup plotAnimationRangePlot
 **/
@synthesize barWidth;

/** @property gapHeight
 *	@brief Height of the central gap.
 *  Set to zero to have no gap.
 *	@ingroup plotAnimationRangePlot
 **/
@synthesize gapHeight;

/** @property gapWidth
 *	@brief Width of the central gap.
 *  Set to zero to have no gap.
 *	@ingroup plotAnimationRangePlot
 **/
@synthesize gapWidth;

#pragma mark -
#pragma mark init/dealloc

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
	if ( self == [CPTRangePlot class] ) {
		[self exposeBinding:CPTRangePlotBindingXValues];
		[self exposeBinding:CPTRangePlotBindingYValues];
		[self exposeBinding:CPTRangePlotBindingHighValues];
		[self exposeBinding:CPTRangePlotBindingLowValues];
		[self exposeBinding:CPTRangePlotBindingLeftValues];
		[self exposeBinding:CPTRangePlotBindingRightValues];
	}
}

#endif

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTRangePlot object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTRangePlot::barLineStyle barLineStyle @endlink = default line style
 *	- @link CPTRangePlot::areaFill areaFill @endlink = <code>nil</code>
 *	- @link CPTPlot::labelField labelField @endlink = #CPTRangePlotFieldX
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTRangePlot object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		barLineStyle = [[CPTLineStyle alloc] init];
		areaFill	 = nil;

		self.labelField = CPTRangePlotFieldX;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTRangePlot *theLayer = (CPTRangePlot *)layer;
		barLineStyle = [theLayer->barLineStyle retain];
		areaFill	 = nil;
	}
	return self;
}

-(void)dealloc
{
	[barLineStyle release];
	[areaFill release];
	[super dealloc];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.barLineStyle forKey:@"CPTRangePlot.barLineStyle"];
	[coder encodeCGFloat:self.barWidth forKey:@"CPTRangePlot.barWidth"];
	[coder encodeCGFloat:self.gapHeight forKey:@"CPTRangePlot.gapHeight"];
	[coder encodeCGFloat:self.gapWidth forKey:@"CPTRangePlot.gapWidth"];
	[coder encodeObject:self.areaFill forKey:@"CPTRangePlot.areaFill"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		barLineStyle = [[coder decodeObjectForKey:@"CPTRangePlot.barLineStyle"] copy];
		barWidth	 = [coder decodeCGFloatForKey:@"CPTRangePlot.barWidth"];
		gapHeight	 = [coder decodeCGFloatForKey:@"CPTRangePlot.gapHeight"];
		gapWidth	 = [coder decodeCGFloatForKey:@"CPTRangePlot.gapWidth"];
		areaFill	 = [[coder decodeObjectForKey:@"CPTRangePlot.areaFill"] copy];
	}
	return self;
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

	CPTPlotRangeComparisonResult *xRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
	CPTPlotRangeComparisonResult *yRangeFlags = malloc( dataCount * sizeof(CPTPlotRangeComparisonResult) );
	BOOL *nanFlags							  = malloc( dataCount * sizeof(BOOL) );

	CPTPlotRange *xRange = xyPlotSpace.xRange;
	CPTPlotRange *yRange = xyPlotSpace.yRange;

	// Determine where each point lies in relation to range
	if ( self.doublePrecisionCache ) {
		const double *xBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
		const double *yBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const double x = *xBytes++;
			const double y = *yBytes++;
			xRangeFlags[i] = [xRange compareToDouble:x];
			yRangeFlags[i] = [yRange compareToDouble:y];
			nanFlags[i]	   = isnan(x) || isnan(y);
		}
	}
	else {
		// Determine where each point lies in relation to range
		const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
		const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;

		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const NSDecimal *x = xBytes++;
			const NSDecimal *y = yBytes++;

			xRangeFlags[i] = [xRange compareToDecimal:*x];
			yRangeFlags[i] = [yRange compareToDecimal:*y];
			nanFlags[i]	   = NSDecimalIsNotANumber(x); // || NSDecimalIsNotANumber(high) || NSDecimalIsNotANumber(low);
		}
	}

	// Ensure that whenever the path crosses over a region boundary, both points
	// are included. This ensures no lines are left out that shouldn't be.
	pointDrawFlags[0] = (xRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
						 yRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange &&
						 !nanFlags[0]);
	for ( NSUInteger i = 1; i < dataCount; i++ ) {
		pointDrawFlags[i] = NO;
		if ( !visibleOnly && !nanFlags[i - 1] && !nanFlags[i] && ( (xRangeFlags[i - 1] != xRangeFlags[i]) || (xRangeFlags[i - 1] != xRangeFlags[i]) ) ) {
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

-(void)calculateViewPoints:(CGPointError *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags
{
	NSUInteger dataCount	   = self.cachedDataCount;
	CPTPlotArea *thePlotArea   = self.plotArea;
	CPTPlotSpace *thePlotSpace = self.plotSpace;
	CGPoint originTransformed  = [self convertPoint:self.frame.origin fromLayer:thePlotArea];

	// Calculate points
	if ( self.doublePrecisionCache ) {
		const double *xBytes	 = (const double *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
		const double *yBytes	 = (const double *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
		const double *highBytes	 = (const double *)[self cachedNumbersForField:CPTRangePlotFieldHigh].data.bytes;
		const double *lowBytes	 = (const double *)[self cachedNumbersForField:CPTRangePlotFieldLow].data.bytes;
		const double *leftBytes	 = (const double *)[self cachedNumbersForField:CPTRangePlotFieldLeft].data.bytes;
		const double *rightBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldRight].data.bytes;
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const double x	   = *xBytes++;
			const double y	   = *yBytes++;
			const double high  = *highBytes++;
			const double low   = *lowBytes++;
			const double left  = *leftBytes++;
			const double right = *rightBytes++;
			if ( !drawPointFlags[i] || isnan(x) || isnan(y) ) {
				viewPoints[i].x = NAN; // depending coordinates
				viewPoints[i].y = NAN;
			}
			else {
				double plotPoint[2];
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y;
				CGPoint pos = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
				viewPoints[i].x			  = pos.x + originTransformed.x;
				viewPoints[i].y			  = pos.y + originTransformed.y;
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y + high;
				pos						  = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
				viewPoints[i].high		  = pos.y + originTransformed.y;
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y - low;
				pos						  = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
				viewPoints[i].low		  = pos.y + originTransformed.y;
				plotPoint[CPTCoordinateX] = x - left;
				plotPoint[CPTCoordinateY] = y;
				pos						  = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
				viewPoints[i].left		  = pos.x + originTransformed.x;
				plotPoint[CPTCoordinateX] = x + right;
				plotPoint[CPTCoordinateY] = y;
				pos						  = [thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint];
				viewPoints[i].right		  = pos.x + originTransformed.x;
			}
		}
	}
	else {
		const NSDecimal *xBytes		= (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
		const NSDecimal *yBytes		= (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
		const NSDecimal *highBytes	= (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldHigh].data.bytes;
		const NSDecimal *lowBytes	= (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldLow].data.bytes;
		const NSDecimal *leftBytes	= (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldLeft].data.bytes;
		const NSDecimal *rightBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldRight].data.bytes;
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const NSDecimal x	  = *xBytes++;
			const NSDecimal y	  = *yBytes++;
			const NSDecimal high  = *highBytes++;
			const NSDecimal low	  = *lowBytes++;
			const NSDecimal left  = *leftBytes++;
			const NSDecimal right = *rightBytes++;

			if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y) ) {
				viewPoints[i].x = NAN; // depending coordinates
				viewPoints[i].y = NAN;
			}
			else {
				NSDecimal plotPoint[2];
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y;
				CGPoint pos = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
				viewPoints[i].x = pos.x + originTransformed.x;
				viewPoints[i].y = pos.y + originTransformed.y;

				if ( !NSDecimalIsNotANumber(&high) ) {
					plotPoint[CPTCoordinateX] = x;
					NSDecimal yh;
					NSDecimalAdd(&yh, &y, &high, NSRoundPlain);
					plotPoint[CPTCoordinateY] = yh;
					pos						  = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
					viewPoints[i].high		  = pos.y + originTransformed.y;
				}
				else {
					viewPoints[i].high = NAN;
				}

				if ( !NSDecimalIsNotANumber(&low) ) {
					plotPoint[CPTCoordinateX] = x;
					NSDecimal yl;
					NSDecimalSubtract(&yl, &y, &low, NSRoundPlain);
					plotPoint[CPTCoordinateY] = yl;
					pos						  = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
					viewPoints[i].low		  = pos.y + originTransformed.y;
				}
				else {
					viewPoints[i].low = NAN;
				}

				if ( !NSDecimalIsNotANumber(&left) ) {
					NSDecimal xl;
					NSDecimalSubtract(&xl, &x, &left, NSRoundPlain);
					plotPoint[CPTCoordinateX] = xl;
					plotPoint[CPTCoordinateY] = y;
					pos						  = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
					viewPoints[i].left		  = pos.x + originTransformed.x;
				}
				else {
					viewPoints[i].left = NAN;
				}
				if ( !NSDecimalIsNotANumber(&right) ) {
					NSDecimal xr;
					NSDecimalAdd(&xr, &x, &right, NSRoundPlain);
					plotPoint[CPTCoordinateX] = xr;
					plotPoint[CPTCoordinateY] = y;
					pos						  = [thePlotSpace plotAreaViewPointForPlotPoint:plotPoint];
					viewPoints[i].right		  = pos.x + originTransformed.y;
				}
				else {
					viewPoints[i].right = NAN;
				}
			}
		}
	}
}

-(void)alignViewPointsToUserSpace:(CGPointError *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags
{
	NSUInteger dataCount = self.cachedDataCount;

	// Align to device pixels if there is a data line.
	// Otherwise, align to view space, so fills are sharp at edges.
	if ( self.barLineStyle.lineWidth > 0.0 ) {
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			if ( drawPointFlags[i] ) {
				CGFloat x	= viewPoints[i].x;
				CGFloat y	= viewPoints[i].y;
				CGPoint pos = CPTAlignPointToUserSpace( theContext, CGPointMake(viewPoints[i].x, viewPoints[i].y) );
				viewPoints[i].x = pos.x;
				viewPoints[i].y = pos.y;

				pos					= CPTAlignPointToUserSpace( theContext, CGPointMake(x, viewPoints[i].high) );
				viewPoints[i].high	= pos.y;
				pos					= CPTAlignPointToUserSpace( theContext, CGPointMake(x, viewPoints[i].low) );
				viewPoints[i].low	= pos.y;
				pos					= CPTAlignPointToUserSpace( theContext, CGPointMake(viewPoints[i].left, y) );
				viewPoints[i].left	= pos.x;
				pos					= CPTAlignPointToUserSpace( theContext, CGPointMake(viewPoints[i].right, y) );
				viewPoints[i].right = pos.x;
			}
		}
	}
	else {
		for ( NSUInteger i = 0; i < dataCount; i++ ) {
			if ( drawPointFlags[i] ) {
				CGFloat x	= viewPoints[i].x;
				CGFloat y	= viewPoints[i].y;
				CGPoint pos = CPTAlignIntegralPointToUserSpace( theContext, CGPointMake(viewPoints[i].x, viewPoints[i].y) );
				viewPoints[i].x = pos.x;
				viewPoints[i].y = pos.y;

				pos					= CPTAlignIntegralPointToUserSpace( theContext, CGPointMake(x, viewPoints[i].high) );
				viewPoints[i].high	= pos.y;
				pos					= CPTAlignIntegralPointToUserSpace( theContext, CGPointMake(x, viewPoints[i].low) );
				viewPoints[i].low	= pos.y;
				pos					= CPTAlignIntegralPointToUserSpace( theContext, CGPointMake(viewPoints[i].left, y) );
				viewPoints[i].left	= pos.x;
				pos					= CPTAlignIntegralPointToUserSpace( theContext, CGPointMake(viewPoints[i].right, y) );
				viewPoints[i].right = pos.x;
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
#pragma mark Data Loading

/// @cond

-(void)reloadDataInIndexRange:(NSRange)indexRange
{
	[super reloadDataInIndexRange:indexRange];

	if ( self.dataSource ) {
		id newXValues = [self numbersFromDataSourceForField:CPTRangePlotFieldX recordIndexRange:indexRange];
		[self cacheNumbers:newXValues forField:CPTRangePlotFieldX atRecordIndex:indexRange.location];
		id newYValues = [self numbersFromDataSourceForField:CPTRangePlotFieldY recordIndexRange:indexRange];
		[self cacheNumbers:newYValues forField:CPTRangePlotFieldY atRecordIndex:indexRange.location];
		id newHighValues = [self numbersFromDataSourceForField:CPTRangePlotFieldHigh recordIndexRange:indexRange];
		[self cacheNumbers:newHighValues forField:CPTRangePlotFieldHigh atRecordIndex:indexRange.location];
		id newLowValues = [self numbersFromDataSourceForField:CPTRangePlotFieldLow recordIndexRange:indexRange];
		[self cacheNumbers:newLowValues forField:CPTRangePlotFieldLow atRecordIndex:indexRange.location];
		id newLeftValues = [self numbersFromDataSourceForField:CPTRangePlotFieldLeft recordIndexRange:indexRange];
		[self cacheNumbers:newLeftValues forField:CPTRangePlotFieldLeft atRecordIndex:indexRange.location];
		id newRightValues = [self numbersFromDataSourceForField:CPTRangePlotFieldRight recordIndexRange:indexRange];
		[self cacheNumbers:newRightValues forField:CPTRangePlotFieldRight atRecordIndex:indexRange.location];
	}
	else {
		self.xValues	 = nil;
		self.yValues	 = nil;
		self.highValues	 = nil;
		self.lowValues	 = nil;
		self.leftValues	 = nil;
		self.rightValues = nil;
	}
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.hidden ) {
		return;
	}

	CPTMutableNumericData *xValueData = [self cachedNumbersForField:CPTRangePlotFieldX];
	CPTMutableNumericData *yValueData = [self cachedNumbersForField:CPTRangePlotFieldY];

	if ( (xValueData == nil) || (yValueData == nil) ) {
		return;
	}
	NSUInteger dataCount = self.cachedDataCount;
	if ( dataCount == 0 ) {
		return;
	}
	if ( xValueData.numberOfSamples != yValueData.numberOfSamples ) {
		[NSException raise:CPTException format:@"Number of x and y values do not match"];
	}

	[super renderAsVectorInContext:theContext];

	// Calculate view points, and align to user space
	CGPointError *viewPoints = malloc( dataCount * sizeof(CGPointError) );
	BOOL *drawPointFlags	 = malloc( dataCount * sizeof(BOOL) );

	CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];
	if ( self.alignsPointsToPixels ) {
		[self alignViewPointsToUserSpace:viewPoints withContent:theContext drawPointFlags:drawPointFlags];
	}

	// Get extreme points
	NSUInteger lastDrawnPointIndex	= [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:NO];
	NSUInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:YES];

	if ( firstDrawnPointIndex != NSNotFound ) {
		if ( self.areaFill ) {
			CGMutablePathRef fillPath = CGPathCreateMutable();

			// First do the top points
			for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
				CGFloat x = viewPoints[i].x;
				CGFloat y = viewPoints[i].high;
				if ( isnan(y) ) {
					y = viewPoints[i].y;
				}

				if ( !isnan(x) && !isnan(y) ) {
					if ( i == firstDrawnPointIndex ) {
						CGPathMoveToPoint(fillPath, NULL, x, y);
					}
					else {
						CGPathAddLineToPoint(fillPath, NULL, x, y);
					}
				}
			}

			// Then reverse over bottom points
			for ( NSUInteger j = lastDrawnPointIndex; j >= firstDrawnPointIndex; j-- ) {
				CGFloat x = viewPoints[j].x;
				CGFloat y = viewPoints[j].low;
				if ( isnan(y) ) {
					y = viewPoints[j].y;
				}

				if ( !isnan(x) && !isnan(y) ) {
					CGPathAddLineToPoint(fillPath, NULL, x, y);
				}
				if ( j == firstDrawnPointIndex ) {
					// This could be done a bit more elegant
					break;
				}
			}

			CGContextBeginPath(theContext);
			CGContextAddPath(theContext, fillPath);

			// Close the path to have a closed loop
			CGPathCloseSubpath(fillPath);

			CGContextSaveGState(theContext);

			// Pick the current linestyle with a low alpha component
			[self.areaFill fillPathInContext:theContext];

			CGPathRelease(fillPath);
		}

		CPTLineStyle *theBarLineStyle = self.barLineStyle;

		if ( theBarLineStyle ) {
			[theBarLineStyle setLineStyleInContext:theContext];

			CGSize halfGapSize	 = CGSizeMake(self.gapWidth * (CGFloat)0.5, self.gapHeight * (CGFloat)0.5);
			CGFloat halfBarWidth = self.barWidth * (CGFloat)0.5;
			BOOL alignPoints	 = self.alignsPointsToPixels;

			for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
				[self drawRangeInContext:theContext
							   viewPoint:&viewPoints[i]
							 halfGapSize:halfGapSize
							halfBarWidth:halfBarWidth
							 alignPoints:alignPoints];
			}
		}

		free(viewPoints);
		free(drawPointFlags);
	}
}

-(void)drawRangeInContext:(CGContextRef)theContext
				viewPoint:(CGPointError *)viewPoint
			  halfGapSize:(CGSize)halfGapSize
			 halfBarWidth:(CGFloat)halfBarWidth
			  alignPoints:(BOOL)alignPoints
{
	if ( !isnan(viewPoint->x) && !isnan(viewPoint->y) ) {
		CGMutablePathRef path = CGPathCreateMutable();

		// centre-high
		if ( !isnan(viewPoint->high) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->x, viewPoint->y + halfGapSize.height);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->x, viewPoint->high);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		// centre-low
		if ( !isnan(viewPoint->low) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->x, viewPoint->y - halfGapSize.height);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->x, viewPoint->low);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		// top bar
		if ( !isnan(viewPoint->high) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->x - halfBarWidth, viewPoint->high);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->x + halfBarWidth, viewPoint->high);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		// bottom bar
		if ( !isnan(viewPoint->low) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->x - halfBarWidth, viewPoint->low);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->x + halfBarWidth, viewPoint->low);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		// centre-left
		if ( !isnan(viewPoint->left) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->x - halfGapSize.width, viewPoint->y);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->left, viewPoint->y);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		// centre-right
		if ( !isnan(viewPoint->right) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->x + halfGapSize.width, viewPoint->y);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->right, viewPoint->y);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		// left bar
		if ( !isnan(viewPoint->left) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->left, viewPoint->y - halfBarWidth);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->left, viewPoint->y + halfBarWidth);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		// right bar
		if ( !isnan(viewPoint->right) ) {
			CGPoint alignedHighPoint = CGPointMake(viewPoint->right, viewPoint->y - halfBarWidth);
			CGPoint alignedLowPoint	 = CGPointMake(viewPoint->right, viewPoint->y + halfBarWidth);
			if ( alignPoints ) {
				alignedHighPoint = CPTAlignPointToUserSpace(theContext, alignedHighPoint);
				alignedLowPoint	 = CPTAlignPointToUserSpace(theContext, alignedLowPoint);
			}
			CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
			CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
		}

		CGContextBeginPath(theContext);
		CGContextAddPath(theContext, path);
		CGContextStrokePath(theContext);
		CGPathRelease(path);
	}
}

-(void)drawSwatchForLegend:(CPTLegend *)legend atIndex:(NSUInteger)index inRect:(CGRect)rect inContext:(CGContextRef)context
{
	[super drawSwatchForLegend:legend atIndex:index inRect:rect inContext:context];

	CPTFill *theFill = self.areaFill;

	if ( theFill ) {
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

		CGContextBeginPath(context);
		CGContextAddPath(context, swatchPath);
		[theFill fillPathInContext:context];

		CGPathRelease(swatchPath);
	}

	CPTLineStyle *theBarLineStyle = self.barLineStyle;

	if ( theBarLineStyle ) {
		[theBarLineStyle setLineStyleInContext:context];

		CGPointError viewPoint;
		viewPoint.x		= CGRectGetMidX(rect);
		viewPoint.y		= CGRectGetMidY(rect);
		viewPoint.high	= CGRectGetMaxY(rect);
		viewPoint.low	= CGRectGetMinY(rect);
		viewPoint.left	= CGRectGetMinX(rect);
		viewPoint.right = CGRectGetMaxX(rect);

		[self drawRangeInContext:context
					   viewPoint:&viewPoint
					 halfGapSize:CGSizeMake(MIN(self.gapWidth, rect.size.width / (CGFloat)2.0) * (CGFloat)0.5, MIN(self.gapHeight, rect.size.height / (CGFloat)2.0) * (CGFloat)0.5)
					halfBarWidth:MIN(MIN(self.barWidth, rect.size.width), rect.size.height) * (CGFloat)0.5
					 alignPoints:YES];
	}
}

///	@endcond

#pragma mark -
#pragma mark Animation

+(BOOL)needsDisplayForKey:(NSString *)aKey
{
	static NSArray *keys = nil;

	if ( !keys ) {
		keys = [[NSArray alloc] initWithObjects:
				@"barWidth",
				@"gapHeight",
				@"gapWidth",
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
	return 6;
}

-(NSArray *)fieldIdentifiers
{
	return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:CPTRangePlotFieldX],
			[NSNumber numberWithUnsignedInt:CPTRangePlotFieldY],
			[NSNumber numberWithUnsignedInt:CPTRangePlotFieldHigh],
			[NSNumber numberWithUnsignedInt:CPTRangePlotFieldLow],
			[NSNumber numberWithUnsignedInt:CPTRangePlotFieldLeft],
			[NSNumber numberWithUnsignedInt:CPTRangePlotFieldRight],
			nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPTCoordinate)coord
{
	NSArray *result = nil;

	switch ( coord ) {
		case CPTCoordinateX:
			result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTRangePlotFieldX]];
			break;

		case CPTCoordinateY:
			result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTRangePlotFieldY]];
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
	NSNumber *xValue = [self cachedNumberForField:CPTRangePlotFieldX recordIndex:index];

	BOOL positiveDirection = YES;
	CPTPlotRange *yRange   = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];

	if ( CPTDecimalLessThan( yRange.length, CPTDecimalFromInteger(0) ) ) {
		positiveDirection = !positiveDirection;
	}

	NSNumber *yValue;
	NSArray *yValues	   = [NSArray arrayWithObject:[self cachedNumberForField:CPTRangePlotFieldY recordIndex:index]];
	NSArray *yValuesSorted = [yValues sortedArrayUsingSelector:@selector(compare:)];
	if ( positiveDirection ) {
		yValue = [yValuesSorted lastObject];
	}
	else {
		yValue = [yValuesSorted objectAtIndex:0];
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
#pragma mark Accessors

///	@cond

-(void)setBarLineStyle:(CPTLineStyle *)newLineStyle
{
	if ( barLineStyle != newLineStyle ) {
		[barLineStyle release];
		barLineStyle = [newLineStyle copy];
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

-(void)setBarWidth:(CGFloat)newBarWidth
{
	if ( barWidth != newBarWidth ) {
		barWidth = newBarWidth;
		[self setNeedsDisplay];
	}
}

-(void)setGapHeight:(CGFloat)newGapHeight
{
	if ( gapHeight != newGapHeight ) {
		gapHeight = newGapHeight;
		[self setNeedsDisplay];
	}
}

-(void)setGapWidth:(CGFloat)newGapWidth
{
	if ( gapWidth != newGapWidth ) {
		gapWidth = newGapWidth;
		[self setNeedsDisplay];
	}
}

-(void)setXValues:(NSArray *)newValues
{
	[self cacheNumbers:newValues forField:CPTRangePlotFieldX];
}

-(NSArray *)xValues
{
	return [[self cachedNumbersForField:CPTRangePlotFieldX] sampleArray];
}

-(void)setYValues:(NSArray *)newValues
{
	[self cacheNumbers:newValues forField:CPTRangePlotFieldY];
}

-(NSArray *)yValues
{
	return [[self cachedNumbersForField:CPTRangePlotFieldY] sampleArray];
}

-(CPTMutableNumericData *)highValues
{
	return [self cachedNumbersForField:CPTRangePlotFieldHigh];
}

-(void)setHighValues:(CPTMutableNumericData *)newValues
{
	[self cacheNumbers:newValues forField:CPTRangePlotFieldHigh];
}

-(CPTMutableNumericData *)lowValues
{
	return [self cachedNumbersForField:CPTRangePlotFieldLow];
}

-(void)setLowValues:(CPTMutableNumericData *)newValues
{
	[self cacheNumbers:newValues forField:CPTRangePlotFieldLow];
}

-(CPTMutableNumericData *)leftValues
{
	return [self cachedNumbersForField:CPTRangePlotFieldLeft];
}

-(void)setLeftValues:(CPTMutableNumericData *)newValues
{
	[self cacheNumbers:newValues forField:CPTRangePlotFieldLeft];
}

-(CPTMutableNumericData *)rightValues
{
	return [self cachedNumbersForField:CPTRangePlotFieldRight];
}

-(void)setRightValues:(CPTMutableNumericData *)newValues
{
	[self cacheNumbers:newValues forField:CPTRangePlotFieldRight];
}

///	@endcond

@end
