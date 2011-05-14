#import "CPTRangePlot.h"
#import "CPTMutableNumericData.h"
#import "CPTNumericData.h"
#import "CPTLineStyle.h"
#import "CPTColor.h"
#import "CPTPlotArea.h"
#import "CPTPlotSpace.h"
#import "CPTPlotSpaceAnnotation.h"
#import "CPTExceptions.h"
#import "CPTUtilities.h"
#import "CPTXYPlotSpace.h"
#import "CPTPlotSpace.h"
#import "CPTFill.h"

NSString * const CPTRangePlotBindingXValues = @"xValues";		///< X values.
NSString * const CPTRangePlotBindingYValues = @"yValues";		///< Y values.
NSString * const CPTRangePlotBindingHighValues = @"highValues";	///< high values.
NSString * const CPTRangePlotBindingLowValues = @"lowValues";	///< low values.
NSString * const CPTRangePlotBindingLeftValues = @"leftValues";	///< left price values.
NSString * const CPTRangePlotBindingRightValues = @"rightValues";///< right price values.

/**	@cond */
struct CGPointError {
	CGFloat x;
	CGFloat y;
	CGFloat high;
	CGFloat low;
	CGFloat left;
	CGFloat right;
};
typedef struct CGPointError CGPointError;

@interface CPTRangePlot ()

@property (nonatomic, readwrite, copy) NSArray *xValues;
@property (nonatomic, readwrite, copy) NSArray *yValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *highValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *lowValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *leftValues;
@property (nonatomic, readwrite, copy) CPTMutableNumericData *rightValues;

@end
/**	@endcond */

/**	@brief A plot class representing a range of values in one coordinate,
 *  such as typically used to show errors.
 *  A range plot can show bars (error bars), or an area fill, or both.
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
 *	Set to nil to have no fill. Default is nil.
 **/
@synthesize areaFill;

/** @property barLineStyle
 *	@brief The line style of the range bars.
 *	Set to nil to have no bars. Default is a black line style.
 **/
@synthesize barLineStyle;

/** @property barWidth
 *	@brief Width of the lateral sections of the bars.
 **/
@synthesize barWidth;

/** @property gapHeight
 *	@brief Height of the central gap.
 *  Set to zero to have no gap.
 **/
@synthesize gapHeight;

/** @property gapWidth
 *	@brief Width of the central gap.
 *  Set to zero to have no gap.
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

-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		barLineStyle = [[CPTLineStyle alloc] init];
		areaFill = nil;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTRangePlot *theLayer = (CPTRangePlot *)layer;
		barLineStyle = [theLayer->barLineStyle retain];
		areaFill = nil;
	}
	return self;
}


-(void)dealloc
{
	[barLineStyle release];
	[areaFill release];
	[super dealloc];
}

#pragma mark -
#pragma mark Determining Which Points to Draw

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPTXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly
{    
	NSUInteger dataCount = self.cachedDataCount;
    if ( dataCount == 0 ) return;
	
    CPTPlotRangeComparisonResult *xRangeFlags = malloc(dataCount * sizeof(CPTPlotRangeComparisonResult));
    CPTPlotRangeComparisonResult *yRangeFlags = malloc(dataCount * sizeof(CPTPlotRangeComparisonResult));
    BOOL *nanFlags = malloc(dataCount * sizeof(BOOL));
    
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
            nanFlags[i] = isnan(x) || isnan(y); 
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
            nanFlags[i] = NSDecimalIsNotANumber(x);// || NSDecimalIsNotANumber(high) || NSDecimalIsNotANumber(low);
        }
    }
    
    // Ensure that whenever the path crosses over a region boundary, both points 
    // are included. This ensures no lines are left out that shouldn't be.
    pointDrawFlags[0] = (xRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange && 
                         yRangeFlags[0] == CPTPlotRangeComparisonResultNumberInRange && 
                         !nanFlags[0]);
    for ( NSUInteger i = 1; i < dataCount; i++ ) {
        pointDrawFlags[i] = NO;
        if ( !visibleOnly && !nanFlags[i-1] && !nanFlags[i] && ((xRangeFlags[i-1] != xRangeFlags[i]) || (xRangeFlags[i-1] != xRangeFlags[i]))) {
            pointDrawFlags[i-1] = YES;
            pointDrawFlags[i] = YES;
        }
        else if ( (xRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) && 
                 (yRangeFlags[i] == CPTPlotRangeComparisonResultNumberInRange) &&
                 !nanFlags[i]) {
            pointDrawFlags[i] = YES;
        }
    }
    
    free(xRangeFlags);
    free(yRangeFlags);
    free(nanFlags);
}

-(void)calculateViewPoints:(CGPointError *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags 
{
	NSUInteger dataCount = self.cachedDataCount;
	CPTPlotArea *thePlotArea = self.plotArea;
	CPTPlotSpace *thePlotSpace = self.plotSpace;
	
    // Calculate points
    if ( self.doublePrecisionCache ) {
        const double *xBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
        const double *yBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
        const double *highBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldHigh].data.bytes;
        const double *lowBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldLow].data.bytes;
        const double *leftBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldLeft].data.bytes;
        const double *rightBytes = (const double *)[self cachedNumbersForField:CPTRangePlotFieldRight].data.bytes;
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const double x = *xBytes++;
			const double y = *yBytes++;
			const double high = *highBytes++;
			const double low = *lowBytes++;			
			const double left = *leftBytes++;
			const double right = *rightBytes++;			
			if ( !drawPointFlags[i] || isnan(x) || isnan(y)) {
				viewPoints[i].x = NAN; // depending coordinates
				viewPoints[i].y = NAN;
			}
			else {
				double plotPoint[2];
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y;
				CGPoint pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].x = pos.x;
				viewPoints[i].y = pos.y;
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y + high;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].high = pos.y;
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y - low;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].low = pos.y;
				plotPoint[CPTCoordinateX] = x-left;
				plotPoint[CPTCoordinateY] = y;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].left = pos.x;
				plotPoint[CPTCoordinateX] = x+right;
				plotPoint[CPTCoordinateY] = y;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].right = pos.x;
			}
        }
    }
    else {
        const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldX].data.bytes;
        const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldY].data.bytes;
        const NSDecimal *highBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldHigh].data.bytes;
        const NSDecimal *lowBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldLow].data.bytes;
        const NSDecimal *leftBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldLeft].data.bytes;
        const NSDecimal *rightBytes = (const NSDecimal *)[self cachedNumbersForField:CPTRangePlotFieldRight].data.bytes;
        for ( NSUInteger i = 0; i < dataCount; i++ ) {
			const NSDecimal x = *xBytes++;
			const NSDecimal y = *yBytes++;
			const NSDecimal high = *highBytes++;
			const NSDecimal low = *lowBytes++;
			const NSDecimal left = *leftBytes++;
			const NSDecimal right = *rightBytes++;

			if ( !drawPointFlags[i] || NSDecimalIsNotANumber(&x) || NSDecimalIsNotANumber(&y)) {
				viewPoints[i].x = NAN; // depending coordinates
				viewPoints[i].y = NAN;
			}
			else {
				NSDecimal plotPoint[2];
				plotPoint[CPTCoordinateX] = x;
				plotPoint[CPTCoordinateY] = y;
				CGPoint pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].x = pos.x;
				viewPoints[i].y = pos.y;

				if (!NSDecimalIsNotANumber(&high)) {
					plotPoint[CPTCoordinateX] = x;
					NSDecimal yh;
					NSDecimalAdd(&yh, &y, &high, NSRoundPlain);
					plotPoint[CPTCoordinateY] = yh;
					pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
					viewPoints[i].high = pos.y;
				} else {
					viewPoints[i].high = NAN;				}

				if (!NSDecimalIsNotANumber(&low)) {
					plotPoint[CPTCoordinateX] = x;
					NSDecimal yl;
					NSDecimalSubtract(&yl, &y, &low, NSRoundPlain);
					plotPoint[CPTCoordinateY] = yl;
					pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
					viewPoints[i].low = pos.y;
				} else {
					viewPoints[i].low = NAN;
				}

				if (!NSDecimalIsNotANumber(&left)) {
					NSDecimal xl;
					NSDecimalSubtract(&xl, &x, &left, NSRoundPlain);
					plotPoint[CPTCoordinateX] = xl;
					plotPoint[CPTCoordinateY] = y;
					pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
					viewPoints[i].left = pos.x;
				} else {
					viewPoints[i].left = NAN;
				}
				if (!NSDecimalIsNotANumber(&right)) {
					NSDecimal xr;
					NSDecimalAdd(&xr, &x, &right, NSRoundPlain);
					plotPoint[CPTCoordinateX] = xr;
					plotPoint[CPTCoordinateY] = y;
					pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
					viewPoints[i].right = pos.x; 
				} else {
					viewPoints[i].right = NAN; 
				}
			}
        }
    }
}

-(void)alignViewPointsToUserSpace:(CGPointError *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags
{
	NSUInteger dataCount = self.cachedDataCount;
	for ( NSUInteger i = 0; i < dataCount; i++ ) {
		if ( drawPointFlags[i] ) {
			CGFloat x = viewPoints[i].x;
			CGFloat y = viewPoints[i].y;
			CGPoint pos = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x,viewPoints[i].y));      
			viewPoints[i].x = pos.x;
			viewPoints[i].y = pos.y;

			pos = CPTAlignPointToUserSpace(theContext, CGPointMake(x,viewPoints[i].high));      
			viewPoints[i].high = pos.y;
			pos = CPTAlignPointToUserSpace(theContext, CGPointMake(x,viewPoints[i].low));      
			viewPoints[i].low = pos.y;
			pos = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left,y));      
			viewPoints[i].left = pos.x;
			pos = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right,y));      
			viewPoints[i].right = pos.x;
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
#pragma mark Data Loading
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
		self.xValues = nil;
		self.yValues = nil;
		self.highValues = nil;
		self.lowValues = nil;
		self.leftValues = nil;
		self.rightValues = nil;
	}
}


-(void)renderAsVectorInContext:(CGContextRef)theContext {
	CPTMutableNumericData *xValueData = [self cachedNumbersForField:CPTRangePlotFieldX];
	CPTMutableNumericData *yValueData = [self cachedNumbersForField:CPTRangePlotFieldY];
	
	if ( xValueData == nil || yValueData == nil) return;
	NSUInteger dataCount = self.cachedDataCount;
	if ( dataCount == 0 ) return;
	if (xValueData.numberOfSamples != yValueData.numberOfSamples) {
		[NSException raise:CPTException format:@"Number of x and y values do not match"];
	}
	
	// Calculate view points, and align to user space
	CGPointError *viewPoints = malloc(dataCount * sizeof(CGPointError));
	BOOL *drawPointFlags = malloc(dataCount * sizeof(BOOL));
   
	CPTXYPlotSpace *thePlotSpace = (CPTXYPlotSpace *)self.plotSpace;
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:thePlotSpace includeVisiblePointsOnly:NO];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];
	[self alignViewPointsToUserSpace:viewPoints withContent:theContext drawPointFlags:drawPointFlags];
	
	// Get extreme points
	NSUInteger lastDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:NO];
	NSUInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremeNumIsLowerBound:YES];

	if ( firstDrawnPointIndex != NSNotFound ) {
        if ( areaFill ) {
            CGMutablePathRef fillPath = CGPathCreateMutable();
            
            // First do the top points
            for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
                CGFloat x = viewPoints[i].x;
                CGFloat y = viewPoints[i].high;
                if(isnan(y))
                    y = viewPoints[i].y;
                
                if (!isnan(x) && !isnan(y)) { 
                    CGPoint alignedPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(x,y));
                    if (i == firstDrawnPointIndex) {
                        CGPathMoveToPoint(fillPath, NULL, alignedPoint.x, alignedPoint.y);
                    } else {
                        CGPathAddLineToPoint(fillPath, NULL, alignedPoint.x, alignedPoint.y);
                    }
                }
            }
            
            // Then reverse over bottom points
            for ( NSUInteger j = lastDrawnPointIndex; j >= firstDrawnPointIndex; j-- ) {
                CGFloat x = viewPoints[j].x;
                CGFloat y = viewPoints[j].low;
                if(isnan(y))
                    y = viewPoints[j].y;

                if (!isnan(x) && !isnan(y)) { 
                    CGPoint alignedPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(x,y));
                    CGPathAddLineToPoint(fillPath, NULL, alignedPoint.x, alignedPoint.y);
                }
                if (j == firstDrawnPointIndex) {
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
            [areaFill fillPathInContext:theContext];
            
            CGPathRelease(fillPath);
        }
        
        if ( barLineStyle ) {
            for ( NSUInteger i = firstDrawnPointIndex; i <= lastDrawnPointIndex; i++ ) {
                if (!isnan(viewPoints[i].x) && !isnan(viewPoints[i].y)) { //depending coordinates
                    CGMutablePathRef path = CGPathCreateMutable();
                        
                        
                    // centre-high
                    if (!isnan(viewPoints[i].high)) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].y + 0.5f * self.gapHeight));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].high));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }

                    // centre-low
                    if (!isnan(viewPoints[i].low)) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].y - 0.5f * self.gapHeight));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].low));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // top bar
                    if (!isnan(viewPoints[i].high) ) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x - 0.5f * self.barWidth,viewPoints[i].high));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x + 0.5f * self.barWidth, viewPoints[i].high));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // bottom bar
                    if (!isnan(viewPoints[i].low) ) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x -  0.5f * self.barWidth, viewPoints[i].low));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x +  0.5f * self.barWidth, viewPoints[i].low));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }

                    // centre-left
                    if (!isnan(viewPoints[i].left)) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x -  0.5f * self.gapWidth, viewPoints[i].y));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left, viewPoints[i].y));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // centre-right
                    if (!isnan(viewPoints[i].right)) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x +  0.5f * self.gapWidth, viewPoints[i].y));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right, viewPoints[i].y));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    } 
                    
                    // left bar
                    if (!isnan(viewPoints[i].left) ) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left, viewPoints[i].y -  0.5f * self.barWidth));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left, viewPoints[i].y +  0.5f * self.barWidth));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // right bar
                    if (!isnan(viewPoints[i].right) ) {
                        CGPoint alignedHighPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right, viewPoints[i].y -  0.5f * self.barWidth));
                        CGPoint alignedLowPoint = CPTAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right, viewPoints[i].y +  0.5f * self.barWidth));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    CGContextBeginPath(theContext);
                    CGContextAddPath(theContext, path);
                    [self.barLineStyle setLineStyleInContext:theContext];
                    CGContextStrokePath(theContext);
                    CGPathRelease(path);
                }
            }
        }
        
		free(viewPoints);
		free(drawPointFlags);	
	}
}
	
#pragma mark -
#pragma mark Fields

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
	switch (coord) {
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

#pragma mark -
#pragma mark Data Labels


-(void)positionLabelAnnotation:(CPTPlotSpaceAnnotation *)label forIndex:(NSUInteger)index
{
	NSNumber *xValue = [self cachedNumberForField:CPTRangePlotFieldX recordIndex:index];

	BOOL positiveDirection = YES;
	CPTPlotRange *yRange = [self.plotSpace plotRangeForCoordinate:CPTCoordinateY];
	if ( CPTDecimalLessThan(yRange.length, CPTDecimalFromInteger(0)) ) {
		positiveDirection = !positiveDirection;
	}
	
	NSNumber *yValue;
	NSArray *yValues = [NSArray arrayWithObject:[self cachedNumberForField:CPTRangePlotFieldY recordIndex:index]];
	NSArray *yValuesSorted = [yValues sortedArrayUsingSelector:@selector(compare:)];
	if ( positiveDirection ) {
		yValue = [yValuesSorted lastObject];
	}
	else {
		yValue = [yValuesSorted objectAtIndex:0];
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
#pragma mark Accessors

-(void)setBarLineStyle:(CPTLineStyle *)newLineStyle
{
	if ( barLineStyle != newLineStyle ) {
		[barLineStyle release];
		barLineStyle = [newLineStyle copy];
		[self setNeedsDisplay];
	}
}

-(void)setAreaFill:(CPTFill *)newFill
{
    if ( newFill != areaFill ) {
    	[areaFill release];
        areaFill = [newFill copy];
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

@end
