
#import "CPRangePlot.h"
#import "CPMutableNumericData.h"
#import "CPNumericData.h"
#import "CPLineStyle.h"
#import "CPColor.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPPlotSpaceAnnotation.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPXYPlotSpace.h"
#import "CPPlotSpace.h"
#import "CPFill.h"

NSString * const CPRangePlotBindingXValues = @"xValues";		///< X values.
NSString * const CPRangePlotBindingYValues = @"yValues";		///< Y values.
NSString * const CPRangePlotBindingHighValues = @"highValues";	///< high values.
NSString * const CPRangePlotBindingLowValues = @"lowValues";	///< low values.
NSString * const CPRangePlotBindingLeftValues = @"leftValues";	///< left price values.
NSString * const CPRangePlotBindingRightValues = @"rightValues";///< right price values.

struct CGPointError {
	CGFloat x;
	CGFloat y;
	CGFloat high;
	CGFloat low;
	CGFloat left;
	CGFloat right;
};
typedef struct CGPointError CGPointError;

@interface CPRangePlot ()

@property (nonatomic, readwrite, copy) NSArray *xValues;
@property (nonatomic, readwrite, copy) NSArray *yValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *highValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *lowValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *leftValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *rightValues;

@end

/**	@brief A plot class representing a range of values in one coordinate,
 *  such as typically used to show errors.
 *  A range plot can show bars (error bars), or an area fill, or both.
 **/
@implementation CPRangePlot

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
	if ( self == [CPRangePlot class] ) {
		[self exposeBinding:CPRangePlotBindingXValues];	
		[self exposeBinding:CPRangePlotBindingYValues];	
		[self exposeBinding:CPRangePlotBindingHighValues];	
		[self exposeBinding:CPRangePlotBindingLowValues];	
		[self exposeBinding:CPRangePlotBindingLeftValues];	
		[self exposeBinding:CPRangePlotBindingRightValues];	
	}
}
#endif

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		barLineStyle = [[CPLineStyle alloc] init];
		areaFill = nil;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPRangePlot *theLayer = (CPRangePlot *)layer;
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

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly
{    
	NSUInteger dataCount = self.cachedDataCount;
    if ( dataCount == 0 ) return;
	
    CPPlotRangeComparisonResult *xRangeFlags = malloc(dataCount * sizeof(CPPlotRangeComparisonResult));
    CPPlotRangeComparisonResult *yRangeFlags = malloc(dataCount * sizeof(CPPlotRangeComparisonResult));
    BOOL *nanFlags = malloc(dataCount * sizeof(BOOL));
    
    CPPlotRange *xRange = xyPlotSpace.xRange;
    CPPlotRange *yRange = xyPlotSpace.yRange;
    
    // Determine where each point lies in relation to range
    if ( self.doublePrecisionCache ) {
        const double *xBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldX].data.bytes;
        const double *yBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldY].data.bytes;
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
        const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldX].data.bytes;
        const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldY].data.bytes;
        
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
    pointDrawFlags[0] = (xRangeFlags[0] == CPPlotRangeComparisonResultNumberInRange && 
                         yRangeFlags[0] == CPPlotRangeComparisonResultNumberInRange && 
                         !nanFlags[0]);
    for ( NSUInteger i = 1; i < dataCount; i++ ) {
        pointDrawFlags[i] = NO;
        if ( !visibleOnly && !nanFlags[i-1] && !nanFlags[i] && ((xRangeFlags[i-1] != xRangeFlags[i]) || (xRangeFlags[i-1] != xRangeFlags[i]))) {
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

-(void)calculateViewPoints:(CGPointError *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags 
{
	NSUInteger dataCount = self.cachedDataCount;
	CPPlotArea *thePlotArea = self.plotArea;
	CPPlotSpace *thePlotSpace = self.plotSpace;
	
    // Calculate points
    if ( self.doublePrecisionCache ) {
        const double *xBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldX].data.bytes;
        const double *yBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldX].data.bytes;
        const double *highBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldHigh].data.bytes;
        const double *lowBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldLow].data.bytes;
        const double *leftBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldLeft].data.bytes;
        const double *rightBytes = (const double *)[self cachedNumbersForField:CPRangePlotFieldRight].data.bytes;
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
				plotPoint[CPCoordinateY] = y;
				CGPoint pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].x = pos.x;
				viewPoints[i].y = pos.y;
				plotPoint[CPCoordinateX] = x;
				plotPoint[CPCoordinateY] = y + high;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].high = pos.y;
				plotPoint[CPCoordinateX] = x;
				plotPoint[CPCoordinateY] = y - low;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].low = pos.y;
				plotPoint[CPCoordinateX] = x-left;
				plotPoint[CPCoordinateY] = y;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].left = pos.x;
				plotPoint[CPCoordinateX] = x+right;
				plotPoint[CPCoordinateY] = y;
				pos = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].right = pos.x;
			}
        }
    }
    else {
        const NSDecimal *xBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldX].data.bytes;
        const NSDecimal *yBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldY].data.bytes;
        const NSDecimal *highBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldHigh].data.bytes;
        const NSDecimal *lowBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldLow].data.bytes;
        const NSDecimal *leftBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldLeft].data.bytes;
        const NSDecimal *rightBytes = (const NSDecimal *)[self cachedNumbersForField:CPRangePlotFieldRight].data.bytes;
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
				plotPoint[CPCoordinateX] = x;
				plotPoint[CPCoordinateY] = y;
				CGPoint pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
				viewPoints[i].x = pos.x;
				viewPoints[i].y = pos.y;

				if (!NSDecimalIsNotANumber(&high)) {
					plotPoint[CPCoordinateX] = x;
					NSDecimal yh;
					NSDecimalAdd(&yh, &y, &high, NSRoundPlain);
					plotPoint[CPCoordinateY] = yh;
					pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
					viewPoints[i].high = pos.y;
				} else {
					viewPoints[i].high = NAN;				}

				if (!NSDecimalIsNotANumber(&low)) {
					plotPoint[CPCoordinateX] = x;
					NSDecimal yl;
					NSDecimalSubtract(&yl, &y, &low, NSRoundPlain);
					plotPoint[CPCoordinateY] = yl;
					pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
					viewPoints[i].low = pos.y;
				} else {
					viewPoints[i].low = NAN;
				}

				if (!NSDecimalIsNotANumber(&left)) {
					NSDecimal xl;
					NSDecimalSubtract(&xl, &x, &left, NSRoundPlain);
					plotPoint[CPCoordinateX] = xl;
					plotPoint[CPCoordinateY] = y;
					pos = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
					viewPoints[i].left = pos.x;
				} else {
					viewPoints[i].left = NAN;
				}
				if (!NSDecimalIsNotANumber(&right)) {
					NSDecimal xr;
					NSDecimalAdd(&xr, &x, &right, NSRoundPlain);
					plotPoint[CPCoordinateX] = xr;
					plotPoint[CPCoordinateY] = y;
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
			CGPoint pos = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x,viewPoints[i].y));      
			viewPoints[i].x = pos.x;
			viewPoints[i].y = pos.y;

			pos = CPAlignPointToUserSpace(theContext, CGPointMake(x,viewPoints[i].high));      
			viewPoints[i].high = pos.y;
			pos = CPAlignPointToUserSpace(theContext, CGPointMake(x,viewPoints[i].low));      
			viewPoints[i].low = pos.y;
			pos = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left,y));      
			viewPoints[i].left = pos.x;
			pos = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right,y));      
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
		id newXValues = [self numbersFromDataSourceForField:CPRangePlotFieldX recordIndexRange:indexRange];
		[self cacheNumbers:newXValues forField:CPRangePlotFieldX atRecordIndex:indexRange.location];
		id newYValues = [self numbersFromDataSourceForField:CPRangePlotFieldY recordIndexRange:indexRange];
		[self cacheNumbers:newYValues forField:CPRangePlotFieldY atRecordIndex:indexRange.location];
		id newHighValues = [self numbersFromDataSourceForField:CPRangePlotFieldHigh recordIndexRange:indexRange];
		[self cacheNumbers:newHighValues forField:CPRangePlotFieldHigh atRecordIndex:indexRange.location];
		id newLowValues = [self numbersFromDataSourceForField:CPRangePlotFieldLow recordIndexRange:indexRange];
		[self cacheNumbers:newLowValues forField:CPRangePlotFieldLow atRecordIndex:indexRange.location];
		id newLeftValues = [self numbersFromDataSourceForField:CPRangePlotFieldLeft recordIndexRange:indexRange];
		[self cacheNumbers:newLeftValues forField:CPRangePlotFieldLeft atRecordIndex:indexRange.location];
		id newRightValues = [self numbersFromDataSourceForField:CPRangePlotFieldRight recordIndexRange:indexRange];
		[self cacheNumbers:newRightValues forField:CPRangePlotFieldRight atRecordIndex:indexRange.location];
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
	CPMutableNumericData *xValueData = [self cachedNumbersForField:CPRangePlotFieldX];
	CPMutableNumericData *yValueData = [self cachedNumbersForField:CPRangePlotFieldY];
	
	if ( xValueData == nil || yValueData == nil) return;
	NSUInteger dataCount = self.cachedDataCount;
	if ( dataCount == 0 ) return;
	if (xValueData.numberOfSamples != yValueData.numberOfSamples) {
		[NSException raise:CPException format:@"Number of x and y values do not match"];
	}
	
	// Calculate view points, and align to user space
	CGPointError *viewPoints = malloc(dataCount * sizeof(CGPointError));
	BOOL *drawPointFlags = malloc(dataCount * sizeof(BOOL));
   
	CPXYPlotSpace *thePlotSpace = (CPXYPlotSpace *)self.plotSpace;
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
                    CGPoint alignedPoint = CPAlignPointToUserSpace(theContext, CGPointMake(x,y));
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
                    CGPoint alignedPoint = CPAlignPointToUserSpace(theContext, CGPointMake(x,y));
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
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].y + 0.5f * self.gapHeight));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].high));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }

                    // centre-low
                    if (!isnan(viewPoints[i].low)) {
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].y - 0.5f * self.gapHeight));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].low));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // top bar
                    if (!isnan(viewPoints[i].high) ) {
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x - 0.5f * self.barWidth,viewPoints[i].high));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x + 0.5f * self.barWidth, viewPoints[i].high));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // bottom bar
                    if (!isnan(viewPoints[i].low) ) {
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x -  0.5f * self.barWidth, viewPoints[i].low));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x +  0.5f * self.barWidth, viewPoints[i].low));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }

                    // centre-left
                    if (!isnan(viewPoints[i].left)) {
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x -  0.5f * self.gapWidth, viewPoints[i].y));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left, viewPoints[i].y));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // centre-right
                    if (!isnan(viewPoints[i].right)) {
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x +  0.5f * self.gapWidth, viewPoints[i].y));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right, viewPoints[i].y));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    } 
                    
                    // left bar
                    if (!isnan(viewPoints[i].left) ) {
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left, viewPoints[i].y -  0.5f * self.barWidth));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].left, viewPoints[i].y +  0.5f * self.barWidth));
                        CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
                        CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
                    }
                    
                    // right bar
                    if (!isnan(viewPoints[i].right) ) {
                        CGPoint alignedHighPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right, viewPoints[i].y -  0.5f * self.barWidth));
                        CGPoint alignedLowPoint = CPAlignPointToUserSpace(theContext, CGPointMake(viewPoints[i].right, viewPoints[i].y +  0.5f * self.barWidth));
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
			[NSNumber numberWithUnsignedInt:CPRangePlotFieldX], 
			[NSNumber numberWithUnsignedInt:CPRangePlotFieldY], 
			[NSNumber numberWithUnsignedInt:CPRangePlotFieldHigh], 
			[NSNumber numberWithUnsignedInt:CPRangePlotFieldLow], 
			[NSNumber numberWithUnsignedInt:CPRangePlotFieldLeft], 
			[NSNumber numberWithUnsignedInt:CPRangePlotFieldRight], 
			nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord 
{
	NSArray *result = nil;
	switch (coord) {
        case CPCoordinateX:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPRangePlotFieldX]];
            break;
        case CPCoordinateY:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPRangePlotFieldY]];			
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
	NSNumber *xValue = [self cachedNumberForField:CPRangePlotFieldX recordIndex:index];

	BOOL positiveDirection = YES;
	CPPlotRange *yRange = [self.plotSpace plotRangeForCoordinate:CPCoordinateY];
	if ( CPDecimalLessThan(yRange.length, CPDecimalFromInteger(0)) ) {
		positiveDirection = !positiveDirection;
	}
	
	NSNumber *yValue;
	NSArray *yValues = [NSArray arrayWithObject:[self cachedNumberForField:CPRangePlotFieldY recordIndex:index]];
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

-(void)setBarLineStyle:(CPLineStyle *)newLineStyle
{
	if ( barLineStyle != newLineStyle ) {
		[barLineStyle release];
		barLineStyle = [newLineStyle copy];
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

-(void)setXValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPRangePlotFieldX];
}

-(NSArray *)xValues 
{
    return [[self cachedNumbersForField:CPRangePlotFieldX] sampleArray];
}

-(void)setYValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPRangePlotFieldY];
}

-(NSArray *)yValues 
{
    return [[self cachedNumbersForField:CPRangePlotFieldY] sampleArray];
}

-(CPMutableNumericData *)highValues 
{
    return [self cachedNumbersForField:CPRangePlotFieldHigh];
}

-(void)setHighValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPRangePlotFieldHigh];
}

-(CPMutableNumericData *)lowValues 
{
    return [self cachedNumbersForField:CPRangePlotFieldLow];
}

-(void)setLowValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPRangePlotFieldLow];
}

-(CPMutableNumericData *)leftValues 
{
    return [self cachedNumbersForField:CPRangePlotFieldLeft];
}

-(void)setLeftValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPRangePlotFieldLeft];
}

-(CPMutableNumericData *)rightValues 
{
    return [self cachedNumbersForField:CPRangePlotFieldRight];
}

-(void)setRightValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPRangePlotFieldRight];
}

@end
