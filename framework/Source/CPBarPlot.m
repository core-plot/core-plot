#import "CPBarPlot.h"
#import "CPXYPlotSpace.h"
#import "CPColor.h"
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotArea.h"
#import "CPPlotRange.h"
#import "CPGradient.h"
#import "CPUtilities.h"
#import "CPExceptions.h"
#import "CPTextLayer.h"
#import "CPTextStyle.h"

NSString * const CPBarPlotBindingBarLocations = @"barLocations";	///< Bar locations.
NSString * const CPBarPlotBindingBarLengths = @"barLengths";		///< Bar lengths.

static NSString * const CPBarLocationsBindingContext = @"CPBarLocationsBindingContext";
static NSString * const CPBarLengthsBindingContext = @"CPBarLengthsBindingContext";

/// @cond
@interface CPBarPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForBarLocationValues;
@property (nonatomic, readwrite, assign) id observedObjectForBarLengthValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForBarLocationValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForBarLengthValues;
@property (nonatomic, readwrite, copy) NSArray *barLocations;
@property (nonatomic, readwrite, copy) NSArray *barLengths;
@property (nonatomic, readwrite, retain) NSMutableArray *barLabelTextLayers;

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)index;
-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index;

-(void)addLabelLayers;

@end
/// @endcond

#pragma mark -

/** @brief A two-dimensional bar plot.
 **/
@implementation CPBarPlot

@synthesize observedObjectForBarLocationValues;
@synthesize observedObjectForBarLengthValues;
@synthesize keyPathForBarLocationValues;
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

/** @property plotRange
 *	@brief Sets the plot range for the independent axis.
 *
 *	If a plot range is provided, the bars are spaced evenly throughout the plot range. If plotRange is nil,
 *	bar locations are provided by Cocoa bindings or the bar plot datasource. If locations are not provided by
 *	either bindings or the datasource, the first bar will be placed at zero (0) and subsequent bars will be at
 *	successive positive integer coordinates.
 **/
@synthesize plotRange;

/** @property barLabelOffset
 *  @brief Sets the offset of the value label above the bar
 **/
@synthesize barLabelOffset;

/** @property barLabelTextStyle
 *  @brief Sets the textstyle of the value label above the bar
 **/
@synthesize barLabelTextStyle;

@synthesize barLabelTextLayers;

/** @property delegate
 *	@brief The scatter plot delegate.
 **/
@synthesize delegate;

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
	barLineStyle.lineWidth = 1.0;
	barLineStyle.lineColor = [CPColor blackColor];
	barPlot.lineStyle = barLineStyle;
	[barLineStyle release];
	barPlot.barsAreHorizontal = horizontal;
	barPlot.barWidth = 10.0;
	barPlot.cornerRadius = 2.0;
	CPGradient *fillGradient = [CPGradient gradientWithBeginningColor:color endingColor:[CPColor blackColor]];
	fillGradient.angle = (horizontal ? -90.0 : 0.0);
	barPlot.fill = [CPFill fillWithGradient:fillGradient];
	return [barPlot autorelease];
}

#pragma mark -
#pragma mark Initialization

+(void)initialize
{
	if (self == [CPBarPlot class]) {
		[self exposeBinding:CPBarPlotBindingBarLocations];
		[self exposeBinding:CPBarPlotBindingBarLengths];
	}
}

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		observedObjectForBarLocationValues = nil;
		observedObjectForBarLengthValues = nil;
		keyPathForBarLocationValues = nil;
		keyPathForBarLengthValues = nil;
		lineStyle = [[CPLineStyle alloc] init];
		fill = [[CPFill fillWithColor:[CPColor blackColor]] retain];
		barWidth = 10.0;
		barOffset = 0.0;
		cornerRadius = 0.0;
		baseValue = [[NSDecimalNumber zero] decimalValue];
		barLocations = nil;
		barLengths = nil;
		barsAreHorizontal = NO;
		plotRange = nil;
		barLabelOffset = 10.0;
		barLabelTextStyle = nil;
        barLabelTextLayers = nil;
		delegate = nil;
        
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	if ( observedObjectForBarLocationValues ) {
		[observedObjectForBarLocationValues removeObserver:self forKeyPath:self.keyPathForBarLocationValues];
		observedObjectForBarLocationValues = nil;	
	}
	if ( observedObjectForBarLengthValues ) {
		[observedObjectForBarLengthValues removeObserver:self forKeyPath:self.keyPathForBarLengthValues];
		observedObjectForBarLengthValues = nil;	
	}
	
	[keyPathForBarLocationValues release];
	[keyPathForBarLengthValues release];
	[lineStyle release];
	[fill release];
	[barLocations release];
	[barLengths release];
	[plotRange release];
    [barLabelTextLayers release];
    [barLabelTextStyle release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Bindings

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
	if ( [binding isEqualToString:CPBarPlotBindingBarLocations] ) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPBarLocationsBindingContext];
		self.observedObjectForBarLocationValues = observable;
		self.keyPathForBarLocationValues = keyPath;
		[self setDataNeedsReloading];
	}
	else if ( [binding isEqualToString:CPBarPlotBindingBarLengths] ) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPBarLengthsBindingContext];
		self.observedObjectForBarLengthValues = observable;
		self.keyPathForBarLengthValues = keyPath;
		[self setDataNeedsReloading];
	}
}

-(void)unbind:(NSString *)bindingName
{
	if ( [bindingName isEqualToString:CPBarPlotBindingBarLocations] ) {
		[observedObjectForBarLocationValues removeObserver:self forKeyPath:keyPathForBarLocationValues];
		self.observedObjectForBarLocationValues= nil;
		self.keyPathForBarLocationValues = nil;
		[self setDataNeedsReloading];
	}	
	else if ( [bindingName isEqualToString:CPBarPlotBindingBarLengths] ) {
		[observedObjectForBarLengthValues removeObserver:self forKeyPath:keyPathForBarLengthValues];
		self.observedObjectForBarLengthValues = nil;
		self.keyPathForBarLengthValues = nil;
		[self setDataNeedsReloading];
	}	
	[super unbind:bindingName];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ( context == CPBarLocationsBindingContext ) {
		[self setDataNeedsReloading];
	}
	else if ( context == CPBarLengthsBindingContext ) {
		[self setDataNeedsReloading];
	}
}

-(Class)valueClassForBinding:(NSString *)binding
{
	if ( [binding isEqualToString:CPBarPlotBindingBarLocations] ) {
		return [NSArray class];
	}
	else if ( [binding isEqualToString:CPBarPlotBindingBarLengths] ) {
		return [NSArray class];
	}
	else {
		return [super valueClassForBinding:binding];
	}
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadData 
{	 
	[super reloadData];
	
	self.barLocations = nil;
	self.barLengths = nil;

	// Bar lengths
	if ( self.observedObjectForBarLengthValues ) {
		// Use bindings to retrieve data
		self.barLengths = [self.observedObjectForBarLengthValues valueForKeyPath:self.keyPathForBarLengthValues];
	}
	else if ( self.dataSource ) {
		CPXYPlotSpace *xyPlotSpace = (CPXYPlotSpace *)self.plotSpace;
		NSRange indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
		self.barLengths = [self numbersFromDataSourceForField:CPBarPlotFieldBarLength recordIndexRange:indexRange];
	}
	
	// Locations of bars
	if ( self.plotRange ) {
		// Spread bars evenly over the plot range
		NSDecimal delta = [[NSDecimalNumber one] decimalValue];
		double doublePrecisionDelta = 1.0;
		if ( self.barLengths.count > 1 ) {
			delta = CPDecimalDivide(self.plotRange.length, CPDecimalFromUnsignedInteger(self.barLengths.count - 1));
			doublePrecisionDelta  = CPDecimalDoubleValue(self.plotRange.length) / (double)(self.barLengths.count - 1);
		}
		
		NSMutableArray *newLocations = [NSMutableArray arrayWithCapacity:self.barLengths.count];
        double locationDouble = CPDecimalDoubleValue(self.plotRange.location);
		for ( NSUInteger ii = 0; ii < self.barLengths.count; ii++ ) {
			id dependentCoordValue = [self.barLengths objectAtIndex:ii];
			if ([dependentCoordValue isKindOfClass:[NSDecimalNumber class]]) {
				NSDecimal location = CPDecimalMultiply(delta, CPDecimalFromUnsignedInteger(ii));
				if ( self.plotRange ) {
					location = CPDecimalAdd(location, self.plotRange.location);			
				}
				[newLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
			}
			else {
				double barLocation = doublePrecisionDelta * (double)ii + locationDouble;
				[newLocations addObject:[NSNumber numberWithDouble:barLocation]];
			}
		}
		self.barLocations = newLocations;
	}
	else if ( self.observedObjectForBarLocationValues ) {
		// Use bindings to retrieve locations
		self.barLocations = [self.observedObjectForBarLocationValues valueForKeyPath:self.keyPathForBarLocationValues];
	}
	else if ( self.dataSource ) {
		// Get locations from the datasource
		CPXYPlotSpace *xyPlotSpace = (CPXYPlotSpace *)self.plotSpace;
		NSRange indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
		self.barLocations = [self numbersFromDataSourceForField:CPBarPlotFieldBarLocation recordIndexRange:indexRange];
	}
	else {
		// Make evenly spaced locations starting at zero
		NSMutableArray *newLocations = [NSMutableArray arrayWithCapacity:self.barLengths.count];
		for ( NSUInteger ii = 0; ii < self.barLengths.count; ii++ ) {
			id dependentCoordValue = [self.barLengths objectAtIndex:ii];
			if ([dependentCoordValue isKindOfClass:[NSDecimalNumber class]]) {
				[newLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromUnsignedInteger(ii)]];
			}
			else {
				[newLocations addObject:[NSNumber numberWithDouble:(double)ii]];
			}
		}
		self.barLocations = newLocations;
	}
}

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers 
{
    [super layoutSublayers];
    [self addLabelLayers];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	if ( self.barLocations == nil || self.barLengths == nil ) return;
    if ( self.barLocations.count == 0 ) return;
	if ( self.barLocations.count != self.barLengths.count ) {
		[NSException raise:CPException format:@"Number of bar locations and lengths do not match"];
	};
	
	[super renderAsVectorInContext:theContext];

	NSUInteger barCount = self.barLengths.count;
    for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
        // Draw
        [self drawBarInContext:theContext recordIndex:ii];
    }   
}

-(CGMutablePathRef)newBarPathWithContext:(CGContextRef)context recordIndex:(NSUInteger)index
{
    CGPoint tipPoint, basePoint;
    CPCoordinate independentCoord = ( self.barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
    CPCoordinate dependentCoord = ( self.barsAreHorizontal ? CPCoordinateX : CPCoordinateY );
    NSArray *locations = self.barLocations;
    NSArray *lengths = self.barLengths;
	
	id dependentCoordValue = [lengths objectAtIndex:index];
	id independentCoordValue = [locations objectAtIndex:index];
	
	if ( ![dependentCoordValue isKindOfClass:[NSDecimalNumber class]] ) {
		double plotPoint[2];
		plotPoint[independentCoord] = [independentCoordValue doubleValue];
		
		// Tip point
		plotPoint[dependentCoord] = [dependentCoordValue doubleValue];
		tipPoint = [self convertPoint:[self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:self.plotArea];
		
		// Base point
		plotPoint[dependentCoord] = CPDecimalDoubleValue(self.baseValue);
		basePoint = [self convertPoint:[self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:self.plotArea];
	}
	else {
		NSDecimal plotPoint[2];
		plotPoint[independentCoord] = [[locations objectAtIndex:index] decimalValue];
		
		// Tip point
		plotPoint[dependentCoord] = [[lengths objectAtIndex:index] decimalValue];
		tipPoint = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
		
		// Base point
		plotPoint[dependentCoord] = baseValue;
		basePoint = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
	}
	
	// Offset
	CGFloat viewOffset = self.barOffset * self.barWidth;
	if ( self.barsAreHorizontal ) {
		basePoint.y += viewOffset;
		tipPoint.y += viewOffset;
	}
	else {
		basePoint.x += viewOffset;
		tipPoint.x += viewOffset;
	}
	
	// This function is used to create a path which is used for both
	// drawing a bar and for doing hit-testing on a click/touch event
    CPCoordinate widthCoordinate = ( self.barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
	CGFloat halfBarWidth = 0.5 * self.barWidth;
	
    CGFloat point[2];
    point[CPCoordinateX] = basePoint.x;
    point[CPCoordinateY] = basePoint.y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint1 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if (context) {
		// may not have a context if doing hit testing
		alignedPoint1 = CPAlignPointToUserSpace(context, alignedPoint1);
	}	
    
    point[CPCoordinateX] = tipPoint.x;
    point[CPCoordinateY] = tipPoint.y;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint2 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if (context) {
		alignedPoint2 = CPAlignPointToUserSpace(context, alignedPoint2);
	}	
	    
    point[CPCoordinateX] = tipPoint.x;
    point[CPCoordinateY] = tipPoint.y;
	CGPoint alignedPoint3 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if (context) {
		alignedPoint3 = CPAlignPointToUserSpace(context, alignedPoint3);
	}	
	
    point[CPCoordinateX] = tipPoint.x;
    point[CPCoordinateY] = tipPoint.y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint4 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if (context) {
		alignedPoint4 = CPAlignPointToUserSpace(context, alignedPoint4);
	}	
    
    point[CPCoordinateX] = basePoint.x;
    point[CPCoordinateY] = basePoint.y;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint5 = CGPointMake(point[CPCoordinateX], point[CPCoordinateY]);
	if (context) {
		alignedPoint5 = CPAlignPointToUserSpace(context, alignedPoint5);
	}	
	
	CGFloat radius = MIN(self.cornerRadius, halfBarWidth);
	if ( self.barsAreHorizontal ) {
		radius = MIN(radius, ABS(tipPoint.x - basePoint.x));
	}
	else {
		radius = MIN(radius, ABS(tipPoint.y - basePoint.y));
	}
	
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, alignedPoint1.x, alignedPoint1.y);
	CGPathAddArcToPoint(path, NULL, alignedPoint2.x, alignedPoint2.y, alignedPoint3.x, alignedPoint3.y, radius);
    CGPathAddArcToPoint(path, NULL, alignedPoint4.x, alignedPoint4.y, alignedPoint5.x, alignedPoint5.y, radius);
    CGPathAddLineToPoint(path, NULL, alignedPoint5.x, alignedPoint5.y);
    CGPathCloseSubpath(path);
	
	return path;
}

-(void)drawBarInContext:(CGContextRef)context recordIndex:(NSUInteger)index
{
	CGMutablePathRef path = [self newBarPathWithContext:context recordIndex:index];

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
#pragma mark Labels

-(void)addLabelLayers
{
	// Remove existing labels
    [self.barLabelTextLayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    // Prepare to create new ones
	self.barLabelTextLayers = [NSMutableArray array];
    BOOL dataSourceSuppliesLabels = [self.dataSource respondsToSelector:@selector(barLabelForBarPlot:recordIndex:)];
    if ( !dataSourceSuppliesLabels && barLabelTextStyle == nil ) return;
    
    // Iterate over bars
    CPCoordinate independentCoord = ( self.barsAreHorizontal ? CPCoordinateY : CPCoordinateX );
    CPCoordinate dependentCoord = ( self.barsAreHorizontal ? CPCoordinateX : CPCoordinateY );
    NSArray *locations = self.barLocations;
    NSArray *lengths = self.barLengths;
	NSUInteger barCount = lengths.count;
    for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
        NSDecimal plotPoint[2];
        CGPoint tipPoint;
        plotPoint[independentCoord] = [[locations objectAtIndex:ii] decimalValue];
        plotPoint[dependentCoord] = [[lengths objectAtIndex:ii] decimalValue];
        tipPoint = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
        
        CGPoint basePoint;
        plotPoint[independentCoord] = [[locations objectAtIndex:ii] decimalValue];
        plotPoint[dependentCoord] = self.baseValue;
        basePoint = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
        
        // Account for offset
        CGFloat viewOffset = self.barOffset * self.barWidth;
        if ( self.barsAreHorizontal ) {
            basePoint.y += viewOffset;
            tipPoint.y += viewOffset;
        }
        else {
            basePoint.x += viewOffset;
            tipPoint.x += viewOffset;
        }        
                
        // Create label
        CPTextLayer *label = nil;
        if ( dataSourceSuppliesLabels ) {
        	id <CPBarPlotDataSource> ds = (id)self.dataSource;
            label = [ds barLabelForBarPlot:self recordIndex:ii];
            if ( [label isKindOfClass:[NSNull class]] ) continue;
        }
        if ( !label ) {
        	NSString *text = [[self.barLengths objectAtIndex:ii] description];
            label = [[CPTextLayer alloc] initWithText:text style:self.barLabelTextStyle];
            [label autorelease];
        }
        
        // Position label
        CGPoint newPosition;
        if ( self.barsAreHorizontal ) {
            if ( tipPoint.x < basePoint.x ) {
                [label setAnchorPoint:CGPointMake(1, 0.5)];
                newPosition = CGPointMake(tipPoint.x - self.barLabelOffset, tipPoint.y);
            } else {
                [label setAnchorPoint:CGPointMake(0, 0.5)];
                newPosition = CGPointMake(tipPoint.x + self.barLabelOffset, tipPoint.y);
            }
        } else {
            if ( tipPoint.y < basePoint.y ) {
                [label setAnchorPoint:CGPointMake(0.5, 1)];
                newPosition = CGPointMake(tipPoint.x, tipPoint.y - self.barLabelOffset);
            } else {
                [label setAnchorPoint:CGPointMake(0.5, 0)];
                newPosition = CGPointMake(tipPoint.x, tipPoint.y + self.barLabelOffset);
            }
        }
        
        // Pixel align
        CGSize labelSize = label.bounds.size;
        CGPoint anchor = [label anchorPoint];
        newPosition.x = round(newPosition.x) - round(labelSize.width * anchor.x) + (labelSize.width * anchor.x);
		newPosition.y = round(newPosition.y) - round(labelSize.height * anchor.y) + (labelSize.height * anchor.y);
        [label setPosition:newPosition];
    
    	// Add to layer tree
        [barLabelTextLayers addObject:label];
        [self addSublayer:label];
    }
}

#pragma mark -
#pragma mark Responder Chain and User interaction

-(BOOL)pointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
	BOOL result = NO;
	CPGraph *theGraph = self.graph;
	CPPlotArea *thePlotArea = self.plotArea;
	if ( !theGraph || !thePlotArea ) return NO;
	
	id <CPBarPlotDelegate> theDelegate = self.delegate;
	if ( [theDelegate respondsToSelector:@selector(barPlot:barWasSelectedAtRecordIndex:)] ) {
    	// Inform delegate if a point was hit
        CGPoint plotAreaPoint = [theGraph convertPoint:interactionPoint toLayer:thePlotArea];
		
		NSUInteger barCount = self.barLengths.count;
		for ( NSUInteger ii = 0; ii < barCount; ii++ ) {
			CGMutablePathRef path = [self newBarPathWithContext:NULL recordIndex:ii];
			
			if ( CGPathContainsPoint(path, nil, plotAreaPoint, false) ) {
				[theDelegate barPlot:self barWasSelectedAtRecordIndex:ii];
				CGPathRelease(path);
				return YES;
			}
			
			CGPathRelease(path);			
		}   
    }
    else {
        result = [super pointingDeviceDownEvent:event atPoint:interactionPoint];
    }
    
	return result;
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
        [self setNeedsLayout];
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
	if ( !CPDecimalEquals(baseValue, newBaseValue) ) 
    {
		baseValue = newBaseValue;
		[self setNeedsDisplay];
        [self setNeedsLayout];
	}
}

-(void)setBarsAreHorizontal:(BOOL)newBarsAreHorizontal 
{
	if (barsAreHorizontal != newBarsAreHorizontal) {
		barsAreHorizontal = newBarsAreHorizontal;
		[self setNeedsDisplay];
        [self setNeedsLayout];
	}
}

-(void)setBarLabelOffset:(CGFloat)newOffset 
{
    if ( barLabelOffset != newOffset ) {
        barLabelOffset = newOffset;
        [self setNeedsLayout];
    }
}

-(void)setBarLabelTextStyle:(CPTextStyle *)newStyle 
{
    if ( barLabelTextStyle != newStyle ) {
        barLabelTextStyle = [newStyle copy];
        [self setNeedsLayout];
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
