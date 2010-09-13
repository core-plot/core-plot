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

static NSString * const CPXValuesBindingContext = @"CPXValuesBindingContext";
static NSString * const CPOpenValuesBindingContext = @"CPOpenValuesBindingContext";
static NSString * const CPHighValuesBindingContext = @"CPHighValuesBindingContext";
static NSString * const CPLowValuesBindingContext = @"CPLowValuesBindingContext";
static NSString * const CPCloseValuesBindingContext = @"CPCloseValuesBindingContext";

/// @cond
@interface CPTradingRangePlot ()

@property (nonatomic, readwrite, assign) id observedObjectForXValues;
@property (nonatomic, readwrite, assign) id observedObjectForOpenValues;
@property (nonatomic, readwrite, assign) id observedObjectForHighValues;
@property (nonatomic, readwrite, assign) id observedObjectForLowValues;
@property (nonatomic, readwrite, assign) id observedObjectForCloseValues;

@property (nonatomic, readwrite, retain) NSValueTransformer *xValuesTransformer;
@property (nonatomic, readwrite, retain) NSValueTransformer *openValuesTransformer;
@property (nonatomic, readwrite, retain) NSValueTransformer *highValuesTransformer;
@property (nonatomic, readwrite, retain) NSValueTransformer *lowValuesTransformer;
@property (nonatomic, readwrite, retain) NSValueTransformer *closeValuesTransformer;

@property (nonatomic, readwrite, copy) NSString *keyPathForXValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForOpenValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForHighValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForLowValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForCloseValues;

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

/** @property observedObjectForXValues
 *	@brief The observed object for x coordinate values when using bindings.
 **/
@synthesize observedObjectForXValues;

/** @property observedObjectForOpenValues
 *	@brief The observed object for open price values when using bindings.
 **/
@synthesize observedObjectForOpenValues;

/** @property observedObjectForHighValues
 *	@brief The observed object for high price values when using bindings.
 **/
@synthesize observedObjectForHighValues;

/** @property observedObjectForLowValues
 *	@brief The observed object for low price values when using bindings.
 **/
@synthesize observedObjectForLowValues;

/** @property observedObjectForCloseValues
 *	@brief The observed object for close price values when using bindings.
 **/
@synthesize observedObjectForCloseValues;

/** @property xValuesTransformer
 *	@brief The x price value transformer used for bindings.
 **/
@synthesize xValuesTransformer;

/** @property openValuesTransformer
 *	@brief The open price value transformer used for bindings.
 **/
@synthesize openValuesTransformer;

/** @property highValuesTransformer
 *	@brief The high price value transformer used for bindings.
 **/
@synthesize highValuesTransformer;

/** @property lowValuesTransformer
 *	@brief The low price value transformer used for bindings.
 **/
@synthesize lowValuesTransformer;

/** @property closeValuesTransformer
 *	@brief The close price value transformer used for bindings.
 **/
@synthesize closeValuesTransformer;

/** @property keyPathForXValues
 *	@brief The key path for binding x coordinate values.
 **/
@synthesize keyPathForXValues;

/** @property keyPathForOpenValues
 *	@brief The key path for binding open price values.
 **/
@synthesize keyPathForOpenValues;

/** @property keyPathForHighValues
 *	@brief The key path for binding high price values.
 **/
@synthesize keyPathForHighValues;

/** @property keyPathForLowValues
 *	@brief The key path for binding low price values.
 **/
@synthesize keyPathForLowValues;

/** @property keyPathForCloseValues
 *	@brief The key path for binding close price values.
 **/
@synthesize keyPathForCloseValues;

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

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		observedObjectForXValues = nil;
		observedObjectForOpenValues = nil;
		observedObjectForHighValues = nil;
		observedObjectForLowValues = nil;
		observedObjectForCloseValues = nil;
		observedObjectForPlotSymbols = nil;
		keyPathForXValues = nil;
		keyPathForCloseValues = nil;
		keyPathForPlotSymbols = nil;
        plotStyle = CPTradingRangePlotStyleOHLC;
		lineStyle = [[CPLineStyle alloc] init];
        increaseFill = [(CPFill *)[CPFill alloc] initWithColor:[CPColor whiteColor]];
        decreaseFill = [(CPFill *)[CPFill alloc] initWithColor:[CPColor blackColor]];
        barWidth = 5.0;
        stickLength = 3.0;
        barCornerRadius = 0.0;

		self.labelField = CPTradingRangePlotFieldClose;
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	if ( observedObjectForXValues ) {
		[observedObjectForXValues removeObserver:self forKeyPath:self.keyPathForXValues];
		observedObjectForXValues = nil;	
	}
	if ( observedObjectForOpenValues ) {
		[observedObjectForOpenValues removeObserver:self forKeyPath:self.keyPathForOpenValues];
		observedObjectForOpenValues = nil;	
	}
	if ( observedObjectForHighValues ) {
		[observedObjectForHighValues removeObserver:self forKeyPath:self.keyPathForHighValues];
		observedObjectForHighValues = nil;	
	}
	if ( observedObjectForLowValues ) {
		[observedObjectForLowValues removeObserver:self forKeyPath:self.keyPathForLowValues];
		observedObjectForLowValues = nil;	
	}
	if ( observedObjectForCloseValues ) {
		[observedObjectForCloseValues removeObserver:self forKeyPath:self.keyPathForCloseValues];
		observedObjectForCloseValues = nil;	
	}
	
	[keyPathForXValues release];
	[keyPathForCloseValues release];
	[keyPathForPlotSymbols release];
	[xValuesTransformer release];
    [openValuesTransformer release];
	[highValuesTransformer release];
    [lowValuesTransformer release];
    [closeValuesTransformer release];
    
	[lineStyle release];
	[increaseFill release];
	[decreaseFill release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Bindings

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
	if ([binding isEqualToString:CPTradingRangePlotBindingXValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPXValuesBindingContext];
		self.observedObjectForXValues = observable;
		self.keyPathForXValues = keyPath;
		[self setDataNeedsReloading];
		
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.xValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }			
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingOpenValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPOpenValuesBindingContext];
		self.observedObjectForOpenValues = observable;
		self.keyPathForOpenValues = keyPath;
		[self setDataNeedsReloading];
        
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.openValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }	
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingHighValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPHighValuesBindingContext];
		self.observedObjectForHighValues = observable;
		self.keyPathForHighValues = keyPath;
		[self setDataNeedsReloading];
        
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.highValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }	
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingLowValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPLowValuesBindingContext];
		self.observedObjectForLowValues = observable;
		self.keyPathForLowValues = keyPath;
		[self setDataNeedsReloading];
        
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.lowValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }	
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingCloseValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPCloseValuesBindingContext];
		self.observedObjectForCloseValues = observable;
		self.keyPathForCloseValues = keyPath;
		[self setDataNeedsReloading];
        
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.closeValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }	
	}
}

-(void)unbind:(NSString *)bindingName
{
	if ([bindingName isEqualToString:CPTradingRangePlotBindingXValues]) {
		[observedObjectForXValues removeObserver:self forKeyPath:self.keyPathForXValues];
		self.observedObjectForXValues = nil;
		self.keyPathForXValues = nil;
        self.xValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	else if ([bindingName isEqualToString:CPTradingRangePlotBindingOpenValues]) {
		[observedObjectForOpenValues removeObserver:self forKeyPath:self.keyPathForOpenValues];
		self.observedObjectForOpenValues = nil;
		self.keyPathForOpenValues = nil;
        self.openValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	else if ([bindingName isEqualToString:CPTradingRangePlotBindingHighValues]) {
		[observedObjectForHighValues removeObserver:self forKeyPath:self.keyPathForHighValues];
		self.observedObjectForHighValues = nil;
		self.keyPathForHighValues = nil;
        self.highValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	else if ([bindingName isEqualToString:CPTradingRangePlotBindingLowValues]) {
		[observedObjectForLowValues removeObserver:self forKeyPath:self.keyPathForLowValues];
		self.observedObjectForLowValues = nil;
		self.keyPathForLowValues = nil;
        self.lowValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	else if ([bindingName isEqualToString:CPTradingRangePlotBindingCloseValues]) {
		[observedObjectForCloseValues removeObserver:self forKeyPath:self.keyPathForCloseValues];
		self.observedObjectForCloseValues = nil;
		self.keyPathForCloseValues = nil;
        self.closeValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	[super unbind:bindingName];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CPXValuesBindingContext) {
		[self setDataNeedsReloading];
	}
	else if (context == CPOpenValuesBindingContext) {
		[self setDataNeedsReloading];
	}
	else if (context == CPHighValuesBindingContext) {
		[self setDataNeedsReloading];
	}
	else if (context == CPLowValuesBindingContext) {
		[self setDataNeedsReloading];
	}
	else if (context == CPCloseValuesBindingContext) {
		[self setDataNeedsReloading];
	}
}

-(Class)valueClassForBinding:(NSString *)binding
{
	if ([binding isEqualToString:CPTradingRangePlotBindingXValues]) {
		return [NSArray class];
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingOpenValues]) {
		return [NSArray class];
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingHighValues]) {
		return [NSArray class];
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingLowValues]) {
		return [NSArray class];
	}
	else if ([binding isEqualToString:CPTradingRangePlotBindingCloseValues]) {
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
	
	NSRange indexRange = NSMakeRange(0, 0);
	
	if ( self.observedObjectForXValues && self.observedObjectForOpenValues && self.observedObjectForHighValues && self.observedObjectForLowValues && self.observedObjectForCloseValues ) {
		// Use bindings to retrieve data
		
		// X values
		NSArray *boundXValues = [self.observedObjectForXValues valueForKeyPath:self.keyPathForXValues];
		NSValueTransformer *theXValuesTransformer = self.xValuesTransformer;
		if ( theXValuesTransformer != nil ) {
			NSMutableArray *newXValues = [NSMutableArray arrayWithCapacity:boundXValues.count];
			for ( id val in boundXValues ) {
				[newXValues addObject:[theXValuesTransformer transformedValue:val]];
			}
			[self cacheNumbers:newXValues forField:CPTradingRangePlotFieldX];
		}
		else {
			[self cacheNumbers:boundXValues forField:CPTradingRangePlotFieldX];
		}
		
		// Open values
		NSArray *boundOpenValues = [self.observedObjectForOpenValues valueForKeyPath:self.keyPathForOpenValues];
		NSValueTransformer *theOpenValuesTransformer = self.openValuesTransformer;
		if ( theOpenValuesTransformer != nil ) {
			NSMutableArray *newOpenValues = [NSMutableArray arrayWithCapacity:boundOpenValues.count];
			for ( id val in boundOpenValues ) {
				[newOpenValues addObject:[theOpenValuesTransformer transformedValue:val]];
			}
			[self cacheNumbers:newOpenValues forField:CPTradingRangePlotFieldOpen];
		}
		else {
			[self cacheNumbers:boundOpenValues forField:CPTradingRangePlotFieldOpen];
		}
		
		// High values
		NSArray *boundHighValues = [self.observedObjectForHighValues valueForKeyPath:self.keyPathForHighValues];
		NSValueTransformer *theHighValuesTransformer = self.highValuesTransformer;
		if ( theHighValuesTransformer != nil ) {
			NSMutableArray *newHighValues = [NSMutableArray arrayWithCapacity:boundHighValues.count];
			for ( id val in boundHighValues ) {
				[newHighValues addObject:[theHighValuesTransformer transformedValue:val]];
			}
			[self cacheNumbers:newHighValues forField:CPTradingRangePlotFieldHigh];
		}
		else {
			[self cacheNumbers:boundHighValues forField:CPTradingRangePlotFieldHigh];
		}
		
		// Low values
		NSArray *boundLowValues = [self.observedObjectForLowValues valueForKeyPath:self.keyPathForLowValues];
		NSValueTransformer *theLowValuesTransformer = self.lowValuesTransformer;
		if ( theLowValuesTransformer != nil ) {
			NSMutableArray *newLowValues = [NSMutableArray arrayWithCapacity:boundLowValues.count];
			for ( id val in boundLowValues ) {
				[newLowValues addObject:[theLowValuesTransformer transformedValue:val]];
			}
			[self cacheNumbers:newLowValues forField:CPTradingRangePlotFieldLow];
		}
		else {
			[self cacheNumbers:boundLowValues forField:CPTradingRangePlotFieldLow];
		}
		
		// Close values
		NSArray *boundCloseValues = [self.observedObjectForCloseValues valueForKeyPath:self.keyPathForCloseValues];
		NSValueTransformer *theCloseValuesTransformer = self.closeValuesTransformer;
		if ( theCloseValuesTransformer != nil ) {
			NSMutableArray *newCloseValues = [NSMutableArray arrayWithCapacity:boundCloseValues.count];
			for ( id val in boundCloseValues ) {
				[newCloseValues addObject:[theCloseValuesTransformer transformedValue:val]];
			}
			[self cacheNumbers:newCloseValues forField:CPTradingRangePlotFieldClose];
		}
		else {
			[self cacheNumbers:boundCloseValues forField:CPTradingRangePlotFieldClose];
		}
		
		indexRange = NSMakeRange(0, self.cachedDataCount);
    }
	else if ( self.dataSource ) {
		CPXYPlotSpace *xyPlotSpace = (CPXYPlotSpace *)self.plotSpace;
		indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
		
		id newXValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldX recordIndexRange:indexRange];
		[self cacheNumbers:newXValues forField:CPTradingRangePlotFieldX];
		id newOpenValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldOpen recordIndexRange:indexRange];
		[self cacheNumbers:newOpenValues forField:CPTradingRangePlotFieldOpen];
		id newHighValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldHigh recordIndexRange:indexRange];
		[self cacheNumbers:newHighValues forField:CPTradingRangePlotFieldHigh];
		id newLowValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldLow recordIndexRange:indexRange];
		[self cacheNumbers:newLowValues forField:CPTradingRangePlotFieldLow];
		id newCloseValues = [self numbersFromDataSourceForField:CPTradingRangePlotFieldClose recordIndexRange:indexRange];
		[self cacheNumbers:newCloseValues forField:CPTradingRangePlotFieldClose];
	}
	else {
		self.xValues = nil;
		self.openValues = nil;
		self.highValues = nil;
		self.lowValues = nil;
		self.closeValues = nil;
	}
	
	// Labels
	[self relabelIndexRange:indexRange];
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
	
    CGPoint openPoint,highPoint,lowPoint, closePoint;
    CPCoordinate independentCoord = CPCoordinateX;
    CPCoordinate dependentCoord = CPCoordinateY;
	
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
			
			// open point
			plotPoint[dependentCoord] = *openBytes++;
			openPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			
			// high point
			plotPoint[dependentCoord] = *highBytes++;
			highPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			
			// low point
			plotPoint[dependentCoord] = *lowBytes++;
			lowPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];
			
			// close point
			plotPoint[dependentCoord] = *closeBytes++;
			closePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:plotPoint] fromLayer:thePlotArea];

			// Draw
			switch ( thePlotStyle ) {
				case CPTradingRangePlotStyleOHLC:
					[self drawOHLCInContext:theContext x:openPoint.x open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
					break;
				case CPTradingRangePlotStyleCandleStick:
					[self drawCandleStickInContext:theContext x:openPoint.x open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
					break;
				default:
					[NSException raise:CPException format:@"Invalid plot style in renderAsVectorInContext"];
					break;
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
			
			// open point
			plotPoint[dependentCoord] = *openBytes++;
			openPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			
			// high point
			plotPoint[dependentCoord] = *highBytes++;
			highPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			
			// low point
			plotPoint[dependentCoord] = *lowBytes++;
			lowPoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];
			
			// close point
			plotPoint[dependentCoord] = *closeBytes++;
			closePoint = [self convertPoint:[thePlotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:thePlotArea];

			// Draw
			switch ( thePlotStyle ) {
				case CPTradingRangePlotStyleOHLC:
					[self drawOHLCInContext:theContext x:openPoint.x open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
					break;
				case CPTradingRangePlotStyleCandleStick:
					[self drawCandleStickInContext:theContext x:openPoint.x open:openPoint.y close:closePoint.y high:highPoint.y low:lowPoint.y];
					break;
				default:
					[NSException raise:CPException format:@"Invalid plot style in renderAsVectorInContext"];
					break;
			}
		}
    }	
}

-(void)drawCandleStickInContext:(CGContextRef)context x:(CGFloat)x open:(CGFloat)open close:(CGFloat)close high:(CGFloat)high low:(CGFloat)low
{
    CPCoordinate widthCoordinate = CPCoordinateX;
	CGFloat halfBarWidth = 0.5 * self.barWidth;
	
    CGFloat point[2];
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = open;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint1 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = close;
    point[widthCoordinate] += halfBarWidth;
	CGPoint alignedPoint2 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = close;
	CGPoint alignedPoint3 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = close;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint4 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = open;
    point[widthCoordinate] -= halfBarWidth;
	CGPoint alignedPoint5 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
	point[CPCoordinateX] = x;
    point[CPCoordinateY] = high;
    CGPoint alignedCenterPoint1 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
	point[CPCoordinateX] = x;
    point[CPCoordinateY] = low;
	CGPoint alignedCenterPoint2 = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
	CGFloat radius = MIN(self.barCornerRadius, halfBarWidth);
	radius = MIN(radius, ABS(close - open));
	
    [self.lineStyle setLineStyleInContext:context];

    CGMutablePathRef path = CGPathCreateMutable();
	CGContextMoveToPoint(context, alignedCenterPoint1.x, alignedCenterPoint1.y);
	CGContextAddLineToPoint(context, alignedCenterPoint2.x, alignedCenterPoint2.y);
	CGContextStrokePath(context);
	CFRelease(path);
	
	path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, alignedPoint1.x, alignedPoint1.y);
	CGPathAddArcToPoint(path, NULL, alignedPoint2.x, alignedPoint2.y, alignedPoint3.x, alignedPoint3.y, radius);
    CGPathAddArcToPoint(path, NULL, alignedPoint4.x, alignedPoint4.y, alignedPoint5.x, alignedPoint5.y, radius);
    CGPathAddLineToPoint(path, NULL, alignedPoint5.x, alignedPoint5.y);
    CGPathCloseSubpath(path);
	
    CGContextSaveGState(context);
	 
	CPFill *currentBarFill = ( open <= close ? self.increaseFill : self.decreaseFill ); 
    if ( currentBarFill != nil ) {
		CGContextBeginPath(context);
		CGContextAddPath(context, path);
		[currentBarFill fillPathInContext:context]; 
	}
	
	CGContextRestoreGState(context);
	
	CGPathRelease(path);
}

-(void)drawOHLCInContext:(CGContextRef)context x:(CGFloat)x open:(CGFloat)open close:(CGFloat)close high:(CGFloat)high low:(CGFloat)low
{
    CGFloat point[2];
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = open;
	CGPoint alignedOpenStartPoint = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = open;
    point[CPCoordinateX] += self.stickLength;	// right side
	CGPoint alignedOpenEndPoint = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = close;
	CGPoint alignedCloseStartPoint = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
    point[CPCoordinateX] = x;
    point[CPCoordinateY] = close;
    point[CPCoordinateX] -= self.stickLength;	// left side
	CGPoint alignedCloseEndPoint = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
    
	
	point[CPCoordinateX] = x;
    point[CPCoordinateY] = high;
    CGPoint alignedHighPoint = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
	point[CPCoordinateX] = x;
    point[CPCoordinateY] = low;
	CGPoint alignedLowPoint = CPAlignPointToUserSpace(context, CGPointMake(point[CPCoordinateX], point[CPCoordinateY]));
	
    [self.lineStyle setLineStyleInContext:context];
    
    CGMutablePathRef path = CGPathCreateMutable();
	CGContextMoveToPoint(context, alignedHighPoint.x, alignedHighPoint.y);
	CGContextAddLineToPoint(context, alignedLowPoint.x, alignedLowPoint.y);
	CGContextMoveToPoint(context, alignedOpenStartPoint.x, alignedOpenStartPoint.y);
	CGContextAddLineToPoint(context, alignedOpenEndPoint.x, alignedOpenEndPoint.y);
	CGContextMoveToPoint(context, alignedCloseStartPoint.x, alignedCloseStartPoint.y);
	CGContextAddLineToPoint(context, alignedCloseEndPoint.x, alignedCloseEndPoint.y);
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

-(void)setIncreaseFill:(CPFill *)value {
	if (increaseFill != value) {
		[increaseFill release];
		increaseFill = [value copy];
		[self setNeedsDisplay];
	}
}

-(void)setDecreaseFill:(CPFill *)value {
	if (decreaseFill != value) {
		[decreaseFill release];
		decreaseFill = [value copy];
		[self setNeedsDisplay];
	}
}

-(void)setBarWidth:(CGFloat)value {
	barWidth = value;
    [self setNeedsDisplay];
}

-(void)setStickLengthh:(CGFloat)value {
	stickLength = value;
    [self setNeedsDisplay];
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
