#import <stdlib.h>
#import "CPMutableNumericData.h"
#import "CPNumericData.h"
#import "CPTradingRangePlot.h"
#import "CPLineStyle.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPPlotSpaceAnnotation.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPXYPlotSpace.h"
#import "CPPlotSymbol.h"
#import "CPFill.h"
#import "CPColor.h"

NSString * const CPTradingRangePlotBindingXValues = @"xValues";			///< X values.
NSString * const CPTradingRangePlotBindingOpenValues = @"openValues";	///< Open price values.
NSString * const CPTradingRangePlotBindingHighValues = @"highValues";	///< High price values.
NSString * const CPTradingRangePlotBindingLowValues = @"lowValues";		///< Low price values.
NSString * const CPTradingRangePlotBindingCloseValues = @"closeValues";	///< Close price values.

/// @cond
@interface CPTradingRangePlot ()

@property (nonatomic, readwrite, copy) CPMutableNumericData *xValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *openValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *highValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *lowValues;
@property (nonatomic, readwrite, copy) CPMutableNumericData *closeValues;

-(void)drawCandleStickInContext:(CGContextRef)context x:(CGFloat)x open:(CGFloat)open close:(CGFloat)close high:(CGFloat)high low:(CGFloat)low;
-(void)drawOHLCInContext:(CGContextRef)context x:(CGFloat)x open:(CGFloat)open close:(CGFloat)close high:(CGFloat)high low:(CGFloat)low;

@end
/// @endcond

#pragma mark -

/** @brief A trading range financial plot.
 **/
@implementation CPTradingRangePlot

@dynamic xValues;
@dynamic openValues;
@dynamic highValues;
@dynamic lowValues;
@dynamic closeValues;

/** @property lineStyle
 *	@brief The line style used to draw candlestick or OHLC symbol 
 **/
@synthesize lineStyle;

/** @property increaseFill
 *	@brief The fill used with a candlestick plot when close >= open.
 **/
@synthesize increaseFill;

/** @property decreaseFill
 *	@brief The fill used with a candlestick plot when close < open.
 **/
@synthesize decreaseFill;

/** @property plotStyle
 *	@brief The style of trading range plot drawn.
 **/
@synthesize plotStyle;

/** @property barWidth
 *	@brief The width of bars in candlestick plots (view coordinates).
 **/
@synthesize barWidth;

/** @property stickLength
 *	@brief The length of close and open sticks on OHLC plots (view coordinates).
 **/
@synthesize stickLength;

/** @property barCornerRadius
 *	@brief The corner radius used for candlestick plots.
 *  Defaults to 0.0.
 **/
@synthesize barCornerRadius;

#pragma mark -
#pragma mark init/dealloc

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
+(void)initialize
{
	if ( self == [CPTradingRangePlot class] ) {
		[self exposeBinding:CPTradingRangePlotBindingXValues];	
		[self exposeBinding:CPTradingRangePlotBindingOpenValues];	
		[self exposeBinding:CPTradingRangePlotBindingHighValues];	
		[self exposeBinding:CPTradingRangePlotBindingLowValues];	
		[self exposeBinding:CPTradingRangePlotBindingCloseValues];	
	}
}
#endif

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
        plotStyle = CPTradingRangePlotStyleOHLC;
		lineStyle = [[CPLineStyle alloc] init];
		lineStyle.delegate = self;
        increaseFill = [(CPFill *)[CPFill alloc] initWithColor:[CPColor whiteColor]];
        decreaseFill = [(CPFill *)[CPFill alloc] initWithColor:[CPColor blackColor]];
        barWidth = 5.0;
        stickLength = 3.0;
        barCornerRadius = 0.0;
		
		self.labelField = CPTradingRangePlotFieldClose;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPTradingRangePlot *theLayer = (CPTradingRangePlot *)layer;
		
		plotStyle = theLayer->plotStyle;
		lineStyle = [theLayer->lineStyle retain];
		increaseFill = [theLayer->increaseFill retain];
		decreaseFill = [theLayer->decreaseFill retain];
		barWidth = theLayer->barWidth;
		stickLength = theLayer->stickLength;
		barCornerRadius = theLayer->barCornerRadius;
	}
	return self;
}

-(void)dealloc
{
	[lineStyle release];
	[increaseFill release];
	[decreaseFill release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadDataInIndexRange:(NSRange)indexRange
{	 
	[super reloadDataInIndexRange:indexRange];
	
	if ( self.dataSource ) {
		id newXValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldX recordIndexRange:indexRange];
		[self cacheNumbers:newXValues forField:CPTradingRangePlotFieldX atRecordIndex:indexRange.location];
		id newOpenValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldOpen recordIndexRange:indexRange];
		[self cacheNumbers:newOpenValues forField:CPTradingRangePlotFieldOpen atRecordIndex:indexRange.location];
		id newHighValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldHigh recordIndexRange:indexRange];
		[self cacheNumbers:newHighValues forField:CPTradingRangePlotFieldHigh atRecordIndex:indexRange.location];
		id newLowValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldLow recordIndexRange:indexRange];
		[self cacheNumbers:newLowValues forField:CPTradingRangePlotFieldLow atRecordIndex:indexRange.location];
		id newCloseValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldClose recordIndexRange:indexRange];
		[self cacheNumbers:newCloseValues forField:CPTradingRangePlotFieldClose atRecordIndex:indexRange.location];
	}
	else {
		self.xValues = nil;
		self.openValues = nil;
		self.highValues = nil;
		self.lowValues = nil;
		self.closeValues = nil;
	}
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
    CPMutableNumericData *locations = [self cachedNumbersForField:CPTradingRangePlotFieldX];
    CPMutableNumericData *opens = [self cachedNumbersForField:CPTradingRangePlotFieldOpen];
	CPMutableNumericData *highs = [self cachedNumbersForField:CPTradingRangePlotFieldHigh];
	CPMutableNumericData *lows = [self cachedNumbersForField:CPTradingRangePlotFieldLow];
	CPMutableNumericData *closes = [self cachedNumbersForField:CPTradingRangePlotFieldClose];
	
	NSUInteger sampleCount = locations.numberOfSamples;
	if ( sampleCount == 0 ) return;
   	if ( opens == nil || highs == nil|| lows == nil|| closes == nil ) return;
    
	if ( (opens.numberOfSamples != sampleCount) || (highs.numberOfSamples != sampleCount) || (lows.numberOfSamples != sampleCount) || (closes.numberOfSamples != sampleCount) ) {
		[NSException raise:CPException format:@"Mismatching number of data values in trading range plot"];
	}
	
	[super renderAsVectorInContext:theContext];
    [self.lineStyle setLineStyleInContext:theContext];
	
    CGPoint openPoint, highPoint, lowPoint, closePoint;
    const CPCoordinate independentCoord = CPCoordinateX;
    const CPCoordinate dependentCoord = CPCoordinateY;
	
	CPPlotArea *thePlotArea = self.plotArea;
	CPPlotSpace *thePlotSpace = self.plotSpace;
	CPTradingRangePlotStyle thePlotStyle = self.plotStyle;
	
    if ( self.doublePrecisionCache ) {
        const double *locationBytes = (const double *)locations.data.bytes;
        const double *openBytes = (const double *)opens.data.bytes;
        const double *highBytes = (const double *)highs.data.bytes;
        const double *lowBytes = (const double *)lows.data.bytes;
        const double *closeBytes = (const double *)closes.data.bytes;
		
        for ( NSUInteger i = 0; i < sampleCount; i++ ) {
            double plotPoint[2];
            plotPoint[independentCoord] = *locationBytes++;
			if ( isnan(plotPoint[independentCoord]) ) {
				openBytes++;
				highBytes++;
				lowBytes++;
				closeBytes++;
				continue;
			}
			
			// open point
			plotPoint[dependentCoord] = *openBytes++;
			if ( isnan(plotPoint[dependentCoord]) ) {
				openPoint = CGPointMake(NAN, NAN);
			}
			else {
				openPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			// high point
			plotPoint[dependentCoord] = *highBytes++;
			if ( isnan(plotPoint[dependentCoord]) ) {
				highPoint = CGPointMake(NAN, NAN);
			}
			else {
				highPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			// low point
			plotPoint[dependentCoord] = *lowBytes++;
			if ( isnan(plotPoint[dependentCoord]) ) {
				lowPoint = CGPointMake(NAN, NAN);
			}
			else {
				lowPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			// close point
			plotPoint[dependentCoord] = *closeBytes++;
			if ( isnan(plotPoint[dependentCoord]) ) {
				closePoint = CGPointMake(NAN, NAN);
			}
			else {
				closePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			CGFloat xCoord = openPoint.x;
			if ( isnan(xCoord) ) {
				xCoord = highPoint.x;
			}
			else if ( isnan(xCoord) ) {
				xCoord = lowPoint.x;
			}
			else if ( isnan(xCoord) ) {
				xCoord = closePoint.x;
			}
			
			if ( !isnan(xCoord) ) {
				// Draw
				switch ( thePlotStyle ) {
					case CPTradingRangePlotStyleOHLC:
						[self drawOHLCInContext:theContext x:xCoord open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
						break;
					case CPTradingRangePlotStyleCandleStick:
						[self drawCandleStickInContext:theContext x:xCoord open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
						break;
					default:
						[NSException raise:CPException format:@"Invalid plot style in renderAsVectorInContext"];
						break;
				}
			}
		}
    }
    else {
        const NSDecimal *locationBytes = (const NSDecimal *)locations.data.bytes;
        const NSDecimal *openBytes = (const NSDecimal *)opens.data.bytes;
        const NSDecimal *highBytes = (const NSDecimal *)highs.data.bytes;
        const NSDecimal *lowBytes = (const NSDecimal *)lows.data.bytes;
        const NSDecimal *closeBytes = (const NSDecimal *)closes.data.bytes;
		
        for ( NSUInteger i = 0; i < sampleCount; i++ ) {
			NSDecimal plotPoint[2];
            plotPoint[independentCoord] = *locationBytes++;
			if ( NSDecimalIsNotANumber(&plotPoint[independentCoord]) ) {
				openBytes++;
				highBytes++;
				lowBytes++;
				closeBytes++;
				continue;
			}
			
			// open point
			plotPoint[dependentCoord] = *openBytes++;
			if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
				openPoint = CGPointMake(NAN, NAN);
			}
			else {
				openPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			// high point
			plotPoint[dependentCoord] = *highBytes++;
			if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
				highPoint = CGPointMake(NAN, NAN);
			}
			else {
				highPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			// low point
			plotPoint[dependentCoord] = *lowBytes++;
			if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
				lowPoint = CGPointMake(NAN, NAN);
			}
			else {
				lowPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			// close point
			plotPoint[dependentCoord] = *closeBytes++;
			if ( NSDecimalIsNotANumber(&plotPoint[dependentCoord]) ) {
				closePoint = CGPointMake(NAN, NAN);
			}
			else {
				closePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			}
			
			CGFloat xCoord = openPoint.x;
			if ( isnan(xCoord) ) {
				xCoord = highPoint.x;
			}
			else if ( isnan(xCoord) ) {
				xCoord = lowPoint.x;
			}
			else if ( isnan(xCoord) ) {
				xCoord = closePoint.x;
			}
			
			if ( !isnan(xCoord) ) {
				// Draw
				switch ( thePlotStyle ) {
					case CPTradingRangePlotStyleOHLC:
						[self drawOHLCInContext:theContext x:xCoord open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
						break;
					case CPTradingRangePlotStyleCandleStick:
						[self drawCandleStickInContext:theContext x:xCoord open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
						break;
					default:
						[NSException raise:CPException format:@"Invalid plot style in renderAsVectorInContext"];
						break;
				}
			}
		}
    }	
}

-(void)drawCandleStickInContext:(CGContextRef)context x:(CGFloat)x open:(CGFloat)open close:(CGFloat)close high:(CGFloat)high low:(CGFloat)low
{
 	CGFloat halfBarWidth = 0.5 * self.barWidth;
	
	// high - low
	if ( !isnan(high) && !isnan(low) ) {
		CGPoint alignedCenterPoint1 = CPAlignPointToUserSpace(context, CGPointMake(x, high));
		CGPoint alignedCenterPoint2 = CPAlignPointToUserSpace(context, CGPointMake(x, low));
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, alignedCenterPoint1.x, alignedCenterPoint1.y);
		CGPathAddLineToPoint(path, NULL, alignedCenterPoint2.x, alignedCenterPoint2.y);
		
		CGContextBeginPath(context);
		CGContextAddPath(context, path);
		CGContextStrokePath(context);

		CGPathRelease(path);
	}
	
	// open-close
	if ( !isnan(open) && !isnan(close) ) {
		CPFill *currentBarFill = ( open <= close ? self.increaseFill : self.decreaseFill ); 
		if ( currentBarFill ) {
			CGFloat radius = MIN(self.barCornerRadius, halfBarWidth);
			radius = MIN(radius, ABS(close - open));
			
			CGPoint alignedPoint1 = CPAlignPointToUserSpace(context, CGPointMake(x + halfBarWidth, open));
			CGPoint alignedPoint2 = CPAlignPointToUserSpace(context, CGPointMake(x + halfBarWidth, close));
			CGPoint alignedPoint3 = CPAlignPointToUserSpace(context, CGPointMake(x, close));
			CGPoint alignedPoint4 = CPAlignPointToUserSpace(context, CGPointMake(x - halfBarWidth, close));
			CGPoint alignedPoint5 = CPAlignPointToUserSpace(context, CGPointMake(x - halfBarWidth, open));
			
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathMoveToPoint(path, NULL, alignedPoint1.x, alignedPoint1.y);
			CGPathAddArcToPoint(path, NULL, alignedPoint2.x, alignedPoint2.y, alignedPoint3.x, alignedPoint3.y, radius);
			CGPathAddArcToPoint(path, NULL, alignedPoint4.x, alignedPoint4.y, alignedPoint5.x, alignedPoint5.y, radius);
			CGPathAddLineToPoint(path, NULL, alignedPoint5.x, alignedPoint5.y);
			CGPathCloseSubpath(path);
			
			CGContextBeginPath(context);
			CGContextAddPath(context, path);
			[currentBarFill fillPathInContext:context]; 
			
			CGPathRelease(path);
		}
	}
}

-(void)drawOHLCInContext:(CGContextRef)context x:(CGFloat)x open:(CGFloat)open close:(CGFloat)close high:(CGFloat)high low:(CGFloat)low
{
	CGFloat theStickLength = self.stickLength;
    CGMutablePathRef path = CGPathCreateMutable();
	
	// high-low
	if ( !isnan(high) && !isnan(low) ) {
		CGPoint alignedHighPoint = CPAlignPointToUserSpace(context, CGPointMake(x, high));
		CGPoint alignedLowPoint = CPAlignPointToUserSpace(context, CGPointMake(x, low));
		CGPathMoveToPoint(path, NULL, alignedHighPoint.x, alignedHighPoint.y);
		CGPathAddLineToPoint(path, NULL, alignedLowPoint.x, alignedLowPoint.y);
	}
	
	// open
	if ( !isnan(open) ) {
		CGPoint alignedOpenStartPoint = CPAlignPointToUserSpace(context, CGPointMake(x, open));
		CGPoint alignedOpenEndPoint = CPAlignPointToUserSpace(context, CGPointMake(x + theStickLength, open)); // right side
		CGPathMoveToPoint(path, NULL, alignedOpenStartPoint.x, alignedOpenStartPoint.y);
		CGPathAddLineToPoint(path, NULL, alignedOpenEndPoint.x, alignedOpenEndPoint.y);
	}
	
	// close
	if ( !isnan(close) ) {
		CGPoint alignedCloseStartPoint = CPAlignPointToUserSpace(context, CGPointMake(x, close));
		CGPoint alignedCloseEndPoint = CPAlignPointToUserSpace(context, CGPointMake(x - theStickLength, close)); // left side
		CGPathMoveToPoint(path, NULL, alignedCloseStartPoint.x, alignedCloseStartPoint.y);
		CGPathAddLineToPoint(path, NULL, alignedCloseEndPoint.x, alignedCloseEndPoint.y);
	}
	
	CGContextBeginPath(context);
	CGContextAddPath(context, path);
	CGContextStrokePath(context);
	CGPathRelease(path);
}

#pragma mark -
#pragma mark Fields

-(NSUInteger)numberOfFields 
{
    return 5;
}

-(NSArray *)fieldIdentifiers 
{
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldX], 
			[NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldOpen], 
			[NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldClose], 
			[NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldHigh], 
			[NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldLow], 
			nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord 
{
	NSArray *result = nil;
	switch (coord) {
        case CPCoordinateX:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldX]];
            break;
        case CPCoordinateY:
            result = [NSArray arrayWithObjects:
					  [NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldOpen], 
					  [NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldLow], 
					  [NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldHigh], 
					  [NSNumber numberWithUnsignedInt:CPTradingRangePlotFieldClose], 
					  nil];
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
	BOOL positiveDirection = YES;
	CPPlotRange *yRange = [self.plotSpace plotRangeForCoordinate:CPCoordinateY];
	if ( CPDecimalLessThan(yRange.length, CPDecimalFromInteger(0)) ) {
		positiveDirection = !positiveDirection;
	}
	
	NSNumber *xValue = [self cachedNumberForField:CPTradingRangePlotFieldX recordIndex:index];
	NSNumber *yValue;
	NSArray *yValues = [NSArray arrayWithObjects:[self cachedNumberForField:CPTradingRangePlotFieldOpen recordIndex:index],
						[self cachedNumberForField:CPTradingRangePlotFieldClose recordIndex:index],
						[self cachedNumberForField:CPTradingRangePlotFieldHigh recordIndex:index],
						[self cachedNumberForField:CPTradingRangePlotFieldLow recordIndex:index], nil];
	NSArray *yValuesSorted = [yValues sortedArrayUsingSelector:@selector(compare:)];
	if ( positiveDirection ) {
		yValue = [yValuesSorted lastObject];
	}
	else {
		yValue = [yValuesSorted objectAtIndex:0];
	}
	
	label.anchorPlotPoint = [NSArray arrayWithObjects:xValue, yValue, nil];
	
	if ( positiveDirection ) {
		label.displacement = CGPointMake(0.0, self.labelOffset);
	}
	else {
		label.displacement = CGPointMake(0.0, -self.labelOffset);
	}
	
	label.contentLayer.hidden = isnan([xValue doubleValue]) || isnan([yValue doubleValue]);
}

#pragma mark -
#pragma mark Accessors

-(void)setLineStyle:(CPLineStyle *)newLineStyle
{
	if ( lineStyle != newLineStyle ) {
		lineStyle.delegate = nil;
		[lineStyle release];
		lineStyle = [newLineStyle copy];
		lineStyle.delegate = self;
		[self setNeedsDisplay];
	}
}

-(void)setIncreaseFill:(CPFill *)newFill
{
	if ( increaseFill != newFill ) {
		[increaseFill release];
		increaseFill = [newFill copy];
		[self setNeedsDisplay];
	}
}

-(void)setDecreaseFill:(CPFill *)newFill
{
	if ( decreaseFill != newFill ) {
		[decreaseFill release];
		decreaseFill = [newFill copy];
		[self setNeedsDisplay];
	}
}

-(void)setBarWidth:(CGFloat)newWidth
{
	if ( barWidth != newWidth ) {
		barWidth = newWidth;
		[self setNeedsDisplay];
	}
}

-(void)setStickLength:(CGFloat)newLength
{
	if ( stickLength != newLength ) {
		stickLength = newLength;
		[self setNeedsDisplay];
	}
}

-(void)setXValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPTradingRangePlotFieldX];
}

-(CPMutableNumericData *)xValues 
{
    return [self cachedNumbersForField:CPTradingRangePlotFieldX];
}

-(CPMutableNumericData *)openValues 
{
    return [self cachedNumbersForField:CPTradingRangePlotFieldOpen];
}

-(void)setOpenValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPTradingRangePlotFieldOpen];
}

-(CPMutableNumericData *)highValues 
{
    return [self cachedNumbersForField:CPTradingRangePlotFieldHigh];
}

-(void)setHighValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPTradingRangePlotFieldHigh];
}

-(CPMutableNumericData *)lowValues 
{
    return [self cachedNumbersForField:CPTradingRangePlotFieldLow];
}

-(void)setLowValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPTradingRangePlotFieldLow];
}

-(CPMutableNumericData *)closeValues 
{
    return [self cachedNumbersForField:CPTradingRangePlotFieldClose];
}

-(void)setCloseValues:(CPMutableNumericData *)newValues 
{
    [self cacheNumbers:newValues forField:CPTradingRangePlotFieldClose];
}


@end
