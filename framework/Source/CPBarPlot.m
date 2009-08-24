
#import "CPBarPlot.h"
#import "CPXYPlotSpace.h"
#import "CPColor.h"
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotRange.h"
#import "CPGradient.h"
#import "CPUtilities.h"

NSString * const CPBarPlotBindingBarLengths = @"barLengths";	///< Bar lengths.

static NSString * const CPBarLengthsBindingContext = @"CPBarLengthsBindingContext";

///	@cond
@interface CPBarPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForBarLengthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForBarLengthValues;
@property (nonatomic, readwrite, retain) NSArray *barLengths;

-(void)drawBarInContext:(CGContextRef)context fromBasePoint:(CGPoint *)basePoint toTipPoint:(CGPoint *)tipPoint recordIndex:(NSUInteger)index;

@end
///	@endcond

/**	@brief A two-dimensional bar plot.
 **/
@implementation CPBarPlot

@synthesize observedObjectForBarLengthValues;
@synthesize keyPathForBarLengthValues;
@synthesize barLengths;

/**	@property cornerRadius
 *	@brief The corner radius for the end of the bars.
 **/
@synthesize cornerRadius;

/**	@property barOffset
 *	@brief The starting offset of the first bar in units of bar width.
 **/
@synthesize barOffset;

/**	@property barWidth
 *	@brief The width of each bar.
 **/
@synthesize barWidth;

/**	@property lineStyle
 *  @brief The line style for the bar outline.
 *	If nil, the outline is not drawn.
 **/
@synthesize lineStyle;

/** @property fill 
 *  @brief The fill style for the bars.
 *	If nil, the bars are not filled.
 **/
@synthesize fill;

/**	@property barsAreHorizontal
 *	@brief If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 **/
@synthesize barsAreHorizontal;

/**	@property baseValue
 *	@brief The coordinate value of the fixed end of the bars.
 **/
@synthesize baseValue;

/**	@property doublePrecisionBaseValue
 *	@brief The coordinate value of the fixed end of the bars, as a double.
 **/
@synthesize doublePrecisionBaseValue;

/**	@property plotRange
 *	@brief Sets the plot range for the independent axis.
 *
 *	The bars are spaced evenly throughout the plot range. If plotRange is nil, the first bar will be placed
 *	at zero (0) and subsequent bars will be at successive positive integer coordinates.
 **/
@synthesize plotRange;



#pragma mark -
#pragma mark Convenience Factory Methods

/** @brief Creates and returns a new CPBarPlot instance initialized with a bar fill consisting of a linear gradient between black and the given color.
 *  @param color The beginning color.
 *  @param horizontal If YES, the bars will have a horizontal orientation, otherwise they will be vertical.
 *  @return A new CPBarPlot instance initialized with a linear gradient bar fill.
 **/
+(CPBarPlot *)tubularBarPlotWithColor:(CPColor *)color horizontalBars:(BOOL)horizontal
{
    CPBarPlot *barPlot = [[CPBarPlot alloc] init];
    CPLineStyle *barLineStyle = [CPLineStyle lineStyle];
    barLineStyle.lineWidth = 1.0f;
    barLineStyle.lineColor = [CPColor blackColor];
    barPlot.lineStyle = barLineStyle;
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
	if (self = [super initWithFrame:newFrame]) {
        self.barsAreHorizontal = NO;
        self.baseValue = [[NSDecimalNumber zero] decimalValue];
        self.barWidth = 10.0f;
        self.cornerRadius = 0.0f;
        self.barOffset = 0.0f;
        self.lineStyle = [CPLineStyle lineStyle];
        self.fill = [CPFill fillWithColor:[CPColor blackColor]];
        self.plotRange = nil;
	}
	return self;
}

-(void)dealloc
{
    self.keyPathForBarLengthValues = nil;
    self.observedObjectForBarLengthValues = nil;
    self.lineStyle = nil;
    self.fill = nil;
    self.barLengths = nil;
    self.plotRange = nil;
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
	
    if ( self.observedObjectForBarLengthValues ) {
        // Use bindings to retrieve data
        self.barLengths = [self.observedObjectForBarLengthValues valueForKeyPath:self.keyPathForBarLengthValues];
    }
    else if ( self.dataSource ) {
        NSRange indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
        self.barLengths = [self numbersFromDataSourceForField:CPBarPlotFieldBarLength recordIndexRange:indexRange];
    }
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
    if ( self.barLengths == nil ) return;
    if ( self.lineStyle == nil && self.fill == nil ) return;
	
    // Determine location of bars in plot space
    NSDecimal delta = [[NSDecimalNumber one] decimalValue];
	double doublePrecisionDelta = 1.0;
    if ( self.plotRange && self.barLengths.count > 1 ) {
        delta = CPDecimalDivide(self.plotRange.length, CPDecimalFromInt(self.barLengths.count - 1));
		doublePrecisionDelta  = self.plotRange.doublePrecisionLength / (double)(self.barLengths.count - 1);
    }
    
    CGPoint tipPoint, basePoint;
    CPCoordinate independentCoord = ( barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
    CPCoordinate dependentCoord = ( barsAreHorizontal ? CPCoordinateX : CPCoordinateY );
    for (NSUInteger ii = 0; ii < [self.barLengths count]; ii++) {
		id dependentCoordValue = [self.barLengths objectAtIndex:ii];
		if ([dependentCoordValue isKindOfClass:[NSDecimalNumber class]])
		{
			double plotPoint[2];
			// Independent coordinate
			plotPoint[independentCoord] = doublePrecisionDelta * (double)ii;
			if ( self.plotRange ) {
				plotPoint[independentCoord] = plotPoint[independentCoord] + self.plotRange.doublePrecisionLocation;			
			}
			
			// Tip point
			plotPoint[dependentCoord] = [dependentCoordValue doubleValue];
			tipPoint = [self.plotSpace viewPointForDoublePrecisionPlotPoint:plotPoint];
			
			// Base point
			plotPoint[dependentCoord] = self.doublePrecisionBaseValue;
			basePoint = [self.plotSpace viewPointForDoublePrecisionPlotPoint:plotPoint];
		}
		else
		{
			NSDecimal plotPoint[2];
			// Independent coordinate
			plotPoint[independentCoord] = CPDecimalMultiply(delta, CPDecimalFromInt(ii));
			if ( self.plotRange ) {
				plotPoint[independentCoord] = CPDecimalAdd(plotPoint[independentCoord], self.plotRange.location);			
			}
			
			// Tip point
			plotPoint[dependentCoord] = [[self.barLengths objectAtIndex:ii] decimalValue];
			tipPoint = [self.plotSpace viewPointForPlotPoint:plotPoint];
			
			// Base point
			plotPoint[dependentCoord] = self.baseValue;
			basePoint = [self.plotSpace viewPointForPlotPoint:plotPoint];
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
    CPCoordinate widthCoordinate = ( barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
    CGFloat point1[2];
    point1[0] = basePoint->x;
    point1[1] = basePoint->y;
    point1[widthCoordinate] += 0.5 * barWidth;
    point1[0] = round(point1[0]);
    point1[1] = round(point1[1]);
    
    CGFloat point2[2];
    point2[0] = tipPoint->x;
    point2[1] = tipPoint->y;
    point2[widthCoordinate] += 0.5 * barWidth;
    point2[0] = round(point2[0]);
    point2[1] = round(point2[1]);
    
    CGFloat point3[2];
    point3[0] = tipPoint->x;
    point3[1] = tipPoint->y;
    point3[0] = round(point3[0]);
    point3[1] = round(point3[1]);
	
    CGFloat point4[2];
    point4[0] = tipPoint->x;
    point4[1] = tipPoint->y;
    point4[widthCoordinate] -= 0.5 * barWidth;
    point4[0] = round(point4[0]);
    point4[1] = round(point4[1]);
    
    CGFloat point5[2];
    point5[0] = basePoint->x;
    point5[1] = basePoint->y;
    point5[widthCoordinate] -= 0.5 * barWidth;
    point5[0] = round(point5[0]);
    point5[1] = round(point5[1]);
	
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point1[0], point1[1]);
	CGPathAddArcToPoint(path, NULL, point2[0], point2[1], point3[0], point3[1], cornerRadius);
    CGPathAddArcToPoint(path, NULL, point4[0], point4[1], point5[0], point5[1], cornerRadius);
    CGPathAddLineToPoint(path, NULL, point5[0], point5[1]);
    
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

-(void)setLineStyle:(CPLineStyle *)value {
    if (lineStyle != value) {
        [lineStyle release];
        lineStyle = [value copy];
        [self setNeedsDisplay];
    }
}

-(void)setFill:(CPFill *)value {
    if (fill != value) {
        [fill release];
        fill = [value copy];
        [self setNeedsDisplay];
    }
}

-(void)setBarWidth:(CGFloat)value {
    if (barWidth != value) {
        barWidth = fabs(value);
        [self setNeedsDisplay];
    }
}

-(void)setBarOffset:(CGFloat)value {
    if (barOffset != value) {
        barOffset = value;
        [self setNeedsDisplay];
    }
}

-(void)setCornerRadius:(CGFloat)value {
    if (cornerRadius != value) {
        cornerRadius = fabs(value);
        [self setNeedsDisplay];
    }
}

-(void)setBaseValue:(NSDecimal)value {
	if (CPDecimalEquals(baseValue, value))
	{
		return;
	}
	baseValue = value;
	doublePrecisionBaseValue = [[NSDecimalNumber decimalNumberWithDecimal:baseValue] doubleValue];
	[self setNeedsDisplay];
}

-(void)setBarsAreHorizontal:(BOOL)value {
    if (barsAreHorizontal != value) {
        barsAreHorizontal = value;
        [self setNeedsDisplay];
    }
}

@end
