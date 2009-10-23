
#import "CPBarPlot.h"
#import "CPXYPlotSpace.h"
#import "CPColor.h"
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotRange.h"
#import "CPGradient.h"
#import "CPUtilities.h"
#import "CPExceptions.h"

NSString * const CPBarPlotBindingBarLengths = @"barLengths";	///< Bar lengths.

static NSString * const CPBarLengthsBindingContext = @"CPBarLengthsBindingContext";

/// @cond
@interface CPBarPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForBarLengthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForBarLengthValues;
@property (nonatomic, readwrite, copy) NSArray *barLengths;
@property (nonatomic, readwrite, copy) NSArray *barLocations;

-(void)drawBarInContext:(CGContextRef)context fromBasePoint:(CGPoint *)basePoint toTipPoint:(CGPoint *)tipPoint recordIndex:(NSUInteger)index;

@end
/// @endcond

/** @brief A two-dimensional bar plot.
 **/
@implementation CPBarPlot

@synthesize observedObjectForBarLengthValues;
@synthesize keyPathForBarLengthValues;

/** @property cornerRadius
 *	@brief The corner radius for the end of the bars.
 **/
@synthesize cornerRadius;

/** @property barOffset
 *	@brief The starting offset of the first bar in units of bar width.
 **/
@synthesize barOffset;

/** @property barWidth
 *	@brief The width of each bar.
 **/
@synthesize barWidth;

/** @property lineStyle
 *	@brief The line style for the bar outline.
 *	If nil, the outline is not drawn.
 **/
@synthesize lineStyle;

/** @property fill 
 *	@brief The fill style for the bars.
 *	If nil, the bars are not filled.
 **/
@synthesize fill;

/** @property barsAreHorizontal
 *	@brief If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 **/
@synthesize barsAreHorizontal;

/** @property baseValue
 *	@brief The coordinate value of the fixed end of the bars.
 **/
@synthesize baseValue;

/** @property doublePrecisionBaseValue
 *	@brief The coordinate value of the fixed end of the bars, as a double.
 **/
@synthesize doublePrecisionBaseValue;

/** @property plotRange
 *	@brief Sets the plot range for the independent axis.
 *
 *	The bars are spaced evenly throughout the plot range. If plotRange is nil, the first bar will be placed
 *	at zero (0) and subsequent bars will be at successive positive integer coordinates.
 **/
@synthesize plotRange;



#pragma mark -
#pragma mark Convenience Factory Methods

/** @brief Creates and returns a new CPBarPlot instance initialized with a bar fill consisting of a linear gradient between black and the given color.
 *	@param color The beginning color.
 *	@param horizontal If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 *	@return A new CPBarPlot instance initialized with a linear gradient bar fill.
 **/
+(CPBarPlot *)tubularBarPlotWithColor:(CPColor *)color horizontalBars:(BOOL)horizontal
{
	CPBarPlot *barPlot = [[CPBarPlot alloc] init];
	CPLineStyle *barLineStyle = [[CPLineStyle alloc] init];
	barLineStyle.lineWidth = 1.0f;
	barLineStyle.lineColor = [CPColor blackColor];
	barPlot.lineStyle = barLineStyle;
	[barLineStyle release];
	barPlot.barsAreHorizontal = horizontal;
	barPlot.barWidth = 10.0f;
	barPlot.cornerRadius = 2.0f;
	CPGradient *fillGradient = [CPGradient gradientWithBeginningColor:color endingColor:[CPColor blackColor]];
	fillGradient.angle = (horizontal ? -90.0f : 0.0f);
	barPlot.fill = [CPFill fillWithGradient:fillGradient];
	return [barPlot autorelease];
}

#pragma mark -
#pragma mark Initialization

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		observedObjectForBarLengthValues = nil;
		keyPathForBarLengthValues = nil;
		lineStyle = [[CPLineStyle alloc] init];
		fill = [[CPFill fillWithColor:[CPColor blackColor]] retain];
		barWidth = 10.0f;
		barOffset = 0.0f;
		cornerRadius = 0.0f;
		baseValue = [[NSDecimalNumber zero] decimalValue];
		doublePrecisionBaseValue = 0.0f;
		barLengths = nil;
		barsAreHorizontal = NO;
		plotRange = nil;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	if ( observedObjectForBarLengthValues ) [self unbind:CPBarPlotBindingBarLengths];

	observedObjectForBarLengthValues = nil;
	[keyPathForBarLengthValues release];
	[lineStyle release];
	[fill release];
	[barLengths release];
	[plotRange release];
	[super dealloc];
}

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
	if ([binding isEqualToString:CPBarPlotBindingBarLengths]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPBarLengthsBindingContext];
		self.observedObjectForBarLengthValues = observable;
		self.keyPathForBarLengthValues = keyPath;
	}
	[self setNeedsDisplay];
}

-(void)unbind:(NSString *)bindingName
{
	if ([bindingName isEqualToString:CPBarPlotBindingBarLengths]) {
		[observedObjectForBarLengthValues removeObserver:self forKeyPath:keyPathForBarLengthValues];
		self.observedObjectForBarLengthValues = nil;
		self.keyPathForBarLengthValues = nil;
	}	
	[super unbind:bindingName];
	[self reloadData];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CPBarLengthsBindingContext) {
		[self reloadData];
	}
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadData 
{	 
	[super reloadData];
	
	CPXYPlotSpace *xyPlotSpace = (CPXYPlotSpace *)self.plotSpace;
	self.barLengths = nil;
	

    // Bar lengths
    if ( self.observedObjectForBarLengthValues ) {
        // Use bindings to retrieve data
        self.barLengths = [self.observedObjectForBarLengthValues valueForKeyPath:self.keyPathForBarLengthValues];
    }
    else if ( self.dataSource ) {
        NSRange indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
        self.barLengths = [self numbersFromDataSourceForField:CPBarPlotFieldBarLength recordIndexRange:indexRange];
    }
    
    // Locations of bars
    NSDecimal delta = [[NSDecimalNumber one] decimalValue];
	double doublePrecisionDelta = 1.0;
    if ( self.plotRange && self.barLengths.count > 1 ) {
        delta = CPDecimalDivide(self.plotRange.length, CPDecimalFromInt(self.barLengths.count - 1));
		doublePrecisionDelta  = self.plotRange.doublePrecisionLength / (double)(self.barLengths.count - 1);
    }
    
    NSMutableArray *newLocations = [NSMutableArray arrayWithCapacity:self.barLengths.count];
    for (NSUInteger ii = 0; ii < self.barLengths.count; ii++) {
        id dependentCoordValue = [self.barLengths objectAtIndex:ii];
		if ([dependentCoordValue isKindOfClass:[NSDecimalNumber class]]) {
			NSDecimal location = CPDecimalMultiply(delta, CPDecimalFromInt(ii));
			if ( self.plotRange ) {
				location = CPDecimalAdd(location, self.plotRange.location);			
			}
			[newLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        }
        else {
            double location = doublePrecisionDelta * (double)ii + self.plotRange.doublePrecisionLocation;
            [newLocations addObject:[NSNumber numberWithDouble:location]];
        }
    }
    self.barLocations = newLocations;
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
    if ( self.barLengths == nil ) return;
    if ( self.lineStyle == nil && self.fill == nil ) return;
	
	[super renderAsVectorInContext:theContext];

    CGPoint tipPoint, basePoint;
    CPCoordinate independentCoord = ( self.barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
    CPCoordinate dependentCoord = ( self.barsAreHorizontal ? CPCoordinateX : CPCoordinateY );
    NSArray *locations = self.barLocations;
    NSArray *lengths = self.barLengths;
    for (NSUInteger ii = 0; ii < [lengths count]; ii++) {
		id dependentCoordValue = [lengths objectAtIndex:ii];
        id independentCoordValue = [locations objectAtIndex:ii];
		
		if ( [dependentCoordValue isKindOfClass:[NSDecimalNumber class]] ) {
			double plotPoint[2];
            plotPoint[independentCoord] = [independentCoordValue doubleValue];
			
			// Tip point
			plotPoint[dependentCoord] = [dependentCoordValue doubleValue];
			tipPoint = [self.plotSpace viewPointInLayer:self forDoublePrecisionPlotPoint:plotPoint];
			
			// Base point
			plotPoint[dependentCoord] = self.doublePrecisionBaseValue;
			basePoint = [self.plotSpace viewPointInLayer:self forDoublePrecisionPlotPoint:plotPoint];
		}
		else {
			NSDecimal plotPoint[2];
            plotPoint[independentCoord] = [[locations objectAtIndex:ii] decimalValue];
			
			// Tip point
			plotPoint[dependentCoord] = [[lengths objectAtIndex:ii] decimalValue];
			tipPoint = [self.plotSpace viewPointInLayer:self forPlotPoint:plotPoint];
			
			// Base point
			plotPoint[dependentCoord] = baseValue;
			basePoint = [self.plotSpace viewPointInLayer:self forPlotPoint:plotPoint];
		}
		
        // Offset
        CGFloat viewOffset = self.barOffset * barWidth;
        if ( self.barsAreHorizontal ) {
            basePoint.y += viewOffset;
            tipPoint.y += viewOffset;
        }
        else {
            basePoint.x += viewOffset;
            tipPoint.x += viewOffset;
        }
        
        // Draw
        [self drawBarInContext:theContext fromBasePoint:&basePoint toTipPoint:&tipPoint recordIndex:ii];
    }   
}

-(void)drawBarInContext:(CGContextRef)context fromBasePoint:(CGPoint *)basePoint toTipPoint:(CGPoint *)tipPoint recordIndex:(NSUInteger)index
{
    CPCoordinate widthCoordinate = ( self.barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
	CGFloat halfBarWidth = 0.5 * self.barWidth;
	
    CGFloat point[2];
    point[CPCoordinateX] = basePoint->x;
    point[CPCoordinateY] = basePoint->y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint1 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = tipPoint->x;
    point[CPCoordinateY] = tipPoint->y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint2 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = tipPoint->x;
    point[CPCoordinateY] = tipPoint->y;
	CGPoint alignedPoint3 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
    point[CPCoordinateX] = tipPoint->x;
    point[CPCoordinateY] = tipPoint->y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint4 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = basePoint->x;
    point[CPCoordinateY] = basePoint->y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint5 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
	CGFloat radius = MIN(self.cornerRadius, halfBarWidth);
	if ( self.barsAreHorizontal ) {
		radius = MIN(radius, ABS(tipPoint->x - basePoint->x));
	}
	else {
		radius = MIN(radius, ABS(tipPoint->y - basePoint->y));
	}
	
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, alignedPoint1.x, alignedPoint1.y);
	CGPathAddArcToPoint(path, NULL, alignedPoint2.x, alignedPoint2.y, alignedPoint3.x, alignedPoint3.y, radius);
    CGPathAddArcToPoint(path, NULL, alignedPoint4.x, alignedPoint4.y, alignedPoint5.x, alignedPoint5.y, radius);
    CGPathAddLineToPoint(path, NULL, alignedPoint5.x, alignedPoint5.y);
    CGPathCloseSubpath(path);
	
    CGContextSaveGState(context);
	
	// If data source returns nil, default fill is used.
	// If data source returns NSNull object, no fill is drawn.
	CPFill *currentBarFill = self.fill;
	if ( [self.dataSource respondsToSelector:@selector(barFillForBarPlot:recordIndex:)] ) {
		CPFill *dataSourceFill = [(id <CPBarPlotDataSource>)self.dataSource barFillForBarPlot:self recordIndex:index];
		if ( nil != dataSourceFill ) currentBarFill = dataSourceFill;
	}
	if ( currentBarFill != nil && ![currentBarFill isKindOfClass:[NSNull class]] ) {
		CGContextBeginPath(context);
		CGContextAddPath(context, path);
		[currentBarFill fillPathInContext:context]; 
	}
	
	if ( self.lineStyle ) {
		CGContextBeginPath(context);
		CGContextAddPath(context, path);
		[self.lineStyle setLineStyleInContext:context];
		CGContextStrokePath(context);
	}

	CGContextRestoreGState(context);
	
	CGPathRelease(path);
}

#pragma mark -
#pragma mark Accessors

-(NSArray *)barLengths {
    return [self cachedNumbersForField:CPBarPlotFieldBarLength];
}

-(void)setBarLengths:(NSArray *)newLengths 
{
    [self cacheNumbers:[[newLengths copy] autorelease] forField:CPBarPlotFieldBarLength];
}

-(NSArray *)barLocations {
    return [self cachedNumbersForField:CPBarPlotFieldBarLocation];
}

-(void)setBarLocations:(NSArray *)newLocations 
{
    [self cacheNumbers:[[newLocations copy] autorelease] forField:CPBarPlotFieldBarLocation];
}

-(void)setLineStyle:(CPLineStyle *)newLineStyle 
{
    if (lineStyle != newLineStyle) {
        [lineStyle release];
        lineStyle = [newLineStyle copy];
        [self setNeedsDisplay];
    }
}

-(void)setFill:(CPFill *)newFill 
{
    if (fill != newFill) {
        [fill release];
        fill = [newFill copy];
        [self setNeedsDisplay];
    }
}

-(void)setBarWidth:(CGFloat)newBarWidth {
	if (barWidth != newBarWidth) {
		barWidth = ABS(newBarWidth);
		[self setNeedsDisplay];
	}
}

-(void)setBarOffset:(CGFloat)newBarOffset 
{
    if (barOffset != newBarOffset) {
        barOffset = newBarOffset;
        [self setNeedsDisplay];
    }
}

-(void)setCornerRadius:(CGFloat)newCornerRadius 
{
    if (cornerRadius != newCornerRadius) {
        cornerRadius = ABS(newCornerRadius);
        [self setNeedsDisplay];
    }
}

-(void)setBaseValue:(NSDecimal)newBaseValue 
{
	if ( !CPDecimalEquals(baseValue, newBaseValue) ) {
		baseValue = newBaseValue;
		[self setNeedsDisplay];
	}
}

-(void)setDoublePrecisionBaseValue:(double)newDoublePrecisionBaseValue {
	if (doublePrecisionBaseValue != newDoublePrecisionBaseValue) {
		doublePrecisionBaseValue = newDoublePrecisionBaseValue;
		[self setNeedsDisplay];
	}
}

-(void)setBarsAreHorizontal:(BOOL)newBarsAreHorizontal {
	if (barsAreHorizontal != newBarsAreHorizontal) {
		barsAreHorizontal = newBarsAreHorizontal;
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Fields

-(NSUInteger)numberOfFields 
{
    return 2;
}

-(NSArray *)fieldIdentifiers 
{
    return [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInt:CPBarPlotFieldBarLocation], [NSNumber numberWithUnsignedInt:CPBarPlotFieldBarLength], nil];
}

-(NSArray *)fieldIdentifiersForCoordinate:(CPCoordinate)coord 
{
	NSArray *result = nil;
	switch (coord) {
        case CPCoordinateX:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:(self.barsAreHorizontal ? CPBarPlotFieldBarLength : CPBarPlotFieldBarLocation)]];
            break;
        case CPCoordinateY:
            result = [NSArray arrayWithObject:[NSNumber numberWithUnsignedInt:(self.barsAreHorizontal ? CPBarPlotFieldBarLocation : CPBarPlotFieldBarLength)]];
            break;
        default:
        	[NSException raise:CPException format:@"Invalid coordinate passed to fieldIdentifiersForCoordinate:"];
            break;
    }
    return result;
}

@end
