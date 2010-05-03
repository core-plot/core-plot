#import <stdlib.h>
#import "CPScatterPlot.h"
#import "CPLineStyle.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPXYPlotSpace.h"
#import "CPPlotSymbol.h"
#import "CPFill.h"


NSString * const CPScatterPlotBindingXValues = @"xValues";							///< X values.
NSString * const CPScatterPlotBindingYValues = @"yValues";							///< Y values.
NSString * const CPScatterPlotBindingPlotSymbols = @"plotSymbols";					///< Plot symbols.

static NSString * const CPXValuesBindingContext = @"CPXValuesBindingContext";
static NSString * const CPYValuesBindingContext = @"CPYValuesBindingContext";
static NSString * const CPLowerErrorValuesBindingContext = @"CPLowerErrorValuesBindingContext";
static NSString * const CPUpperErrorValuesBindingContext = @"CPUpperErrorValuesBindingContext";
static NSString * const CPPlotSymbolsBindingContext = @"CPPlotSymbolsBindingContext";

/// @cond
@interface CPScatterPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForXValues;
@property (nonatomic, readwrite, assign) id observedObjectForYValues;
@property (nonatomic, readwrite, assign) id observedObjectForPlotSymbols;

@property (nonatomic, readwrite, retain) NSValueTransformer *xValuesTransformer;
@property (nonatomic, readwrite, retain) NSValueTransformer *yValuesTransformer;

@property (nonatomic, readwrite, copy) NSString *keyPathForXValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForYValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForPlotSymbols;

@property (nonatomic, readwrite, copy) NSArray *xValues;
@property (nonatomic, readwrite, copy) NSArray *yValues;
@property (nonatomic, readwrite, retain) NSArray *plotSymbols;

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPXYPlotSpace *)plotSpace includeVisiblePointsOnly:(BOOL)visibleOnly;
-(void)calculateViewPoints:(CGPoint *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags;
-(void)alignViewPointsToUserSpace:(CGPoint *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags;

-(NSUInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags extremumIsLowerBound:(BOOL)isLowerBound;

CGFloat squareOfDistanceBetweenPoints(CGPoint point1, CGPoint point2);

@end
/// @endcond

#pragma mark -

/** @brief A two-dimensional scatter plot.
 **/
@implementation CPScatterPlot

@synthesize observedObjectForXValues;
@synthesize observedObjectForYValues;
@synthesize observedObjectForPlotSymbols;
@synthesize xValuesTransformer;
@synthesize yValuesTransformer;
@synthesize keyPathForXValues;
@synthesize keyPathForYValues;
@synthesize keyPathForPlotSymbols;
@synthesize plotSymbols;

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

/** @property areaBaseValue
 *	@brief The Y coordinate of the straight boundary of the area fill.
 *	If not a number, the area is not filled.
 *
 *	Typically set to the minimum value of the Y range, but it can be any value that gives the desired appearance.
 **/
@synthesize areaBaseValue;

#pragma mark -
#pragma mark init/dealloc

+(void)initialize
{
	if (self == [CPScatterPlot class]) {
		[self exposeBinding:CPScatterPlotBindingXValues];	
		[self exposeBinding:CPScatterPlotBindingYValues];	
		[self exposeBinding:CPScatterPlotBindingPlotSymbols];	
	}
}

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		observedObjectForXValues = nil;
		observedObjectForYValues = nil;
		observedObjectForPlotSymbols = nil;
		keyPathForXValues = nil;
		keyPathForYValues = nil;
		keyPathForPlotSymbols = nil;
		dataLineStyle = [[CPLineStyle alloc] init];
		plotSymbol = nil;
		areaFill = nil;
		areaBaseValue = [[NSDecimalNumber notANumber] decimalValue];
		plotSymbols = nil;
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
	if ( observedObjectForYValues ) {
		[observedObjectForYValues removeObserver:self forKeyPath:self.keyPathForYValues];
		observedObjectForYValues = nil;	
	}
	if ( observedObjectForPlotSymbols ) {
		[observedObjectForPlotSymbols removeObserver:self forKeyPath:self.keyPathForPlotSymbols];
		observedObjectForPlotSymbols = nil;	
	}

	[keyPathForXValues release];
	[keyPathForYValues release];
	[keyPathForPlotSymbols release];
	[dataLineStyle release];
	[plotSymbol release];
	[areaFill release];
	[plotSymbols release];
	[xValuesTransformer release];
    [yValuesTransformer release];
    	
	[super dealloc];
}

#pragma mark -
#pragma mark Bindings

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
	if ([binding isEqualToString:CPScatterPlotBindingXValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPXValuesBindingContext];
		self.observedObjectForXValues = observable;
		self.keyPathForXValues = keyPath;
		[self setDataNeedsReloading];
		
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.xValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }			
	}
	else if ([binding isEqualToString:CPScatterPlotBindingYValues]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPYValuesBindingContext];
		self.observedObjectForYValues = observable;
		self.keyPathForYValues = keyPath;
		[self setDataNeedsReloading];
        
		NSString *transformerName = [options objectForKey:@"NSValueTransformerNameBindingOption"];
		if ( transformerName != nil ) {
            self.yValuesTransformer = [NSValueTransformer valueTransformerForName:transformerName];
        }	
	}
	else if ([binding isEqualToString:CPScatterPlotBindingPlotSymbols]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:CPPlotSymbolsBindingContext];
		self.observedObjectForPlotSymbols = observable;
		self.keyPathForPlotSymbols = keyPath;
		[self setDataNeedsReloading];
	}
}

-(void)unbind:(NSString *)bindingName
{
	if ([bindingName isEqualToString:CPScatterPlotBindingXValues]) {
		[observedObjectForXValues removeObserver:self forKeyPath:self.keyPathForXValues];
		self.observedObjectForXValues = nil;
		self.keyPathForXValues = nil;
        self.xValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	else if ([bindingName isEqualToString:CPScatterPlotBindingYValues]) {
		[observedObjectForYValues removeObserver:self forKeyPath:self.keyPathForYValues];
		self.observedObjectForYValues = nil;
		self.keyPathForYValues = nil;
        self.yValuesTransformer = nil;
		[self setDataNeedsReloading];
	}	
	else if ([bindingName isEqualToString:CPScatterPlotBindingPlotSymbols]) {
		[observedObjectForPlotSymbols removeObserver:self forKeyPath:self.keyPathForPlotSymbols];
		self.observedObjectForPlotSymbols = nil;
		self.keyPathForPlotSymbols = nil;
		[self setDataNeedsReloading];
	}	
	[super unbind:bindingName];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CPXValuesBindingContext) {
		[self setDataNeedsReloading];
	}
	else if (context == CPYValuesBindingContext) {
		[self setDataNeedsReloading];
	}
	else if (context == CPPlotSymbolsBindingContext) {
		[self setDataNeedsReloading];
	}
}

-(Class)valueClassForBinding:(NSString *)binding
{
	if ([binding isEqualToString:CPScatterPlotBindingXValues]) {
		return [NSArray class];
	}
	else if ([binding isEqualToString:CPScatterPlotBindingYValues]) {
		return [NSArray class];
	}
	else if ([binding isEqualToString:CPScatterPlotBindingPlotSymbols]) {
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
	
	self.xValues = nil;
	self.yValues = nil;
	self.plotSymbols = nil;
	
	if ( self.observedObjectForXValues && self.observedObjectForYValues ) {
		// Use bindings to retrieve data
		self.xValues = [self.observedObjectForXValues valueForKeyPath:self.keyPathForXValues];
		self.yValues = [self.observedObjectForYValues valueForKeyPath:self.keyPathForYValues];

		if ( xValuesTransformer != nil ) {
			NSMutableArray *newXValues = [NSMutableArray arrayWithCapacity:self.xValues.count];
			for ( id val in self.xValues ) {
				[newXValues addObject:[xValuesTransformer transformedValue:val]];
			}
			self.xValues = newXValues;
		}
        
		if ( yValuesTransformer != nil ) {
			NSMutableArray *newYValues = [NSMutableArray arrayWithCapacity:self.yValues.count];
			for ( id val in self.yValues ) {
				[newYValues addObject:[yValuesTransformer transformedValue:val]];
			}
			self.yValues = newYValues;
		}
        
		self.plotSymbols = [self.observedObjectForPlotSymbols valueForKeyPath:self.keyPathForPlotSymbols];
	}
	else if ( self.dataSource ) {
		// Expand the index range each end, to make sure that plot lines go to offscreen points
		NSUInteger numberOfRecords = [self.dataSource numberOfRecordsForPlot:self];
		CPXYPlotSpace *xyPlotSpace = (CPXYPlotSpace *)self.plotSpace;
		NSRange indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
		NSRange expandedRange = CPExpandedRange(indexRange, 1);
		NSRange completeIndexRange = NSMakeRange(0, numberOfRecords);
		indexRange = NSIntersectionRange(expandedRange, completeIndexRange);
		
		self.xValues = [self numbersFromDataSourceForField:CPScatterPlotFieldX recordIndexRange:indexRange];
		self.yValues = [self numbersFromDataSourceForField:CPScatterPlotFieldY recordIndexRange:indexRange];
		
		// Plot symbols
		if ( [self.dataSource respondsToSelector:@selector(symbolsForScatterPlot:recordIndexRange:)] ) {
			self.plotSymbols = [(id <CPScatterPlotDataSource>)self.dataSource symbolsForScatterPlot:self recordIndexRange:indexRange];
		}
		else if ([self.dataSource respondsToSelector:@selector(symbolForScatterPlot:recordIndex:)]) {
			NSMutableArray *symbols = [NSMutableArray arrayWithCapacity:indexRange.length];
			for ( NSUInteger recordIndex = indexRange.location; recordIndex < indexRange.location + indexRange.length; recordIndex++ ) {
				CPPlotSymbol *theSymbol = [(id <CPScatterPlotDataSource>)self.dataSource symbolForScatterPlot:self recordIndex:recordIndex];
				if (theSymbol) {
					[symbols addObject:theSymbol];
				}
				else {
					[symbols addObject:[NSNull null]];
				}
			}
			self.plotSymbols = symbols;
		}
	}
}

#pragma mark -
#pragma mark Determing Which Points to Draw

-(void)calculatePointsToDraw:(BOOL *)pointDrawFlags forPlotSpace:(CPXYPlotSpace *)xyPlotSpace includeVisiblePointsOnly:(BOOL)visibleOnly
{    
	NSUInteger n = self.xValues.count;
    if ( n == 0 ) return;
    
    CPPlotRangeComparisonResult *xRangeFlags = malloc(self.xValues.count * sizeof(CPPlotRangeComparisonResult));
    CPPlotRangeComparisonResult *yRangeFlags = malloc(self.yValues.count * sizeof(CPPlotRangeComparisonResult));

    // Determine where each point lies in relation to range
    for (NSUInteger i = 0; i < n; i++) {
        NSNumber *xValue = [self.xValues objectAtIndex:i];
		NSNumber *yValue = [self.yValues objectAtIndex:i];
        xRangeFlags[i] = [xyPlotSpace.xRange compareToNumber:xValue];
		yRangeFlags[i] = [xyPlotSpace.yRange compareToNumber:yValue];
    }
        
    // Ensure that whenever the path crosses over a region boundary, both points 
    // are included. This ensures no lines are left out that shouldn't be.
    pointDrawFlags[0] = (xRangeFlags[0] == CPPlotRangeComparisonResultNumberInRange && 
						 yRangeFlags[0] == CPPlotRangeComparisonResultNumberInRange);
    for (NSUInteger i = 1; i < n; i++) {
    	pointDrawFlags[i] = NO;
		if ( !visibleOnly && ((xRangeFlags[i-1] != xRangeFlags[i]) || (yRangeFlags[i-1] != yRangeFlags[i])) ) {
            pointDrawFlags[i-1] = YES;
            pointDrawFlags[i] = YES;
        }
        else if ( (xRangeFlags[i] == CPPlotRangeComparisonResultNumberInRange) && 
			      (yRangeFlags[i] == CPPlotRangeComparisonResultNumberInRange) ) {
            pointDrawFlags[i] = YES;
        }
    }

    free(xRangeFlags);
	free(yRangeFlags);
}

-(void)calculateViewPoints:(CGPoint *)viewPoints withDrawPointFlags:(BOOL *)drawPointFlags 
{	
    // Calculate points
	BOOL doubleFastPath = [[self.xValues lastObject] isKindOfClass:[NSDecimalNumber class]] != NO;
    for (NSUInteger i = 0; i < self.xValues.count; i++) {
		id xValue = [self.xValues objectAtIndex:i];
		id yValue = [self.yValues objectAtIndex:i];
		if (doubleFastPath) {
			double doublePrecisionPlotPoint[2];
			doublePrecisionPlotPoint[CPCoordinateX] = [xValue doubleValue];
			doublePrecisionPlotPoint[CPCoordinateY] = [yValue doubleValue];
			viewPoints[i] = [self convertPoint:[self.plotSpace plotAreaViewPointForDoublePrecisionPlotPoint:doublePrecisionPlotPoint] fromLayer:self.plotArea];
		}
		else {
			NSDecimal plotPoint[2];
			plotPoint[CPCoordinateX] = [xValue decimalValue];
			plotPoint[CPCoordinateY] = [yValue decimalValue];
			viewPoints[i] = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
		}
    }	
}

-(void)alignViewPointsToUserSpace:(CGPoint *)viewPoints withContent:(CGContextRef)theContext drawPointFlags:(BOOL *)drawPointFlags
{
	for (NSUInteger i = 0; i < self.xValues.count; i++) {
		if ( !drawPointFlags[i] ) continue;
		viewPoints[i] = CPAlignPointToUserSpace(theContext, viewPoints[i]);      
	}
}

-(NSUInteger)extremeDrawnPointIndexForFlags:(BOOL *)pointDrawFlags extremumIsLowerBound:(BOOL)isLowerBound 
{
	NSInteger result = NSNotFound;
	NSInteger delta = (isLowerBound ? 1 : -1);
	NSUInteger xValuesCount = self.xValues.count;
	if ( xValuesCount > 0 ) {
		NSUInteger initialIndex = (isLowerBound ? 0 : xValuesCount - 1);
		for ( NSUInteger i = initialIndex; i < xValuesCount; i += delta ) {
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
	CGPoint *viewPoints = malloc(self.xValues.count * sizeof(CGPoint));
	BOOL *drawPointFlags = malloc(self.xValues.count * sizeof(BOOL));	
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:YES];
    [self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];
	
	NSUInteger result = [self extremeDrawnPointIndexForFlags:drawPointFlags extremumIsLowerBound:YES];
	if ( result != NSNotFound ) {
		CGFloat minimumDistanceSquared = squareOfDistanceBetweenPoints(viewPoint, viewPoints[result]);
		for ( NSUInteger i = result + 1; i < self.xValues.count; ++i ) {
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
	CGPoint *viewPoints = malloc(self.xValues.count * sizeof(CGPoint));
	BOOL *drawPointFlags = malloc(self.xValues.count * sizeof(BOOL));
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
	if ( self.xValues == nil || self.yValues == nil ) return;
	if ( self.xValues.count == 0 ) return;
	if ( !(self.dataLineStyle || self.areaFill || self.plotSymbol || self.plotSymbols.count) ) return;
	if ( self.xValues.count != self.yValues.count ) {
		[NSException raise:CPException format:@"Number of x and y values do not match"];
	}
	
	[super renderAsVectorInContext:theContext];
	
	// Calculate view points, and align to user space
	CGPoint *viewPoints = malloc(self.xValues.count * sizeof(CGPoint));
	BOOL *drawPointFlags = malloc(self.xValues.count * sizeof(BOOL));
	[self calculatePointsToDraw:drawPointFlags forPlotSpace:(id)self.plotSpace includeVisiblePointsOnly:NO];
	[self calculateViewPoints:viewPoints withDrawPointFlags:drawPointFlags];
	[self alignViewPointsToUserSpace:viewPoints withContent:theContext drawPointFlags:drawPointFlags];
	
	// Get extreme points
	NSUInteger lastDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremumIsLowerBound:NO];
	NSUInteger firstDrawnPointIndex = [self extremeDrawnPointIndexForFlags:drawPointFlags extremumIsLowerBound:YES];
	if ( firstDrawnPointIndex != NSNotFound ) {
		// Path
		CGMutablePathRef dataLinePath = NULL;
		if ( self.dataLineStyle || self.areaFill ) {
			dataLinePath = CGPathCreateMutable();
			CGPathMoveToPoint(dataLinePath, NULL, viewPoints[firstDrawnPointIndex].x, viewPoints[firstDrawnPointIndex].y);
			NSUInteger i = firstDrawnPointIndex + 1;
			while ( i <= lastDrawnPointIndex ) {
				CGPathAddLineToPoint(dataLinePath, NULL, viewPoints[i].x, viewPoints[i].y);
				i++;
			} 
		}
		
		// Draw fill
		NSDecimal temporaryAreaBaseValue = self.areaBaseValue;
		if ( self.areaFill && (!NSDecimalIsNotANumber(&temporaryAreaBaseValue)) ) {		
			id xValue = [self.xValues objectAtIndex:firstDrawnPointIndex];
			
			CGPoint baseLinePoint;
			NSDecimal plotPoint[2];
			plotPoint[CPCoordinateX] = [xValue decimalValue];
			plotPoint[CPCoordinateY] = self.areaBaseValue;
			baseLinePoint = [self convertPoint:[self.plotSpace plotAreaViewPointForPlotPoint:plotPoint] fromLayer:self.plotArea];
			
			CGFloat baseLineYValue = baseLinePoint.y;
			
			CGPoint baseViewPoint1 = viewPoints[lastDrawnPointIndex];
			baseViewPoint1.y = baseLineYValue;
			baseViewPoint1 = CPAlignPointToUserSpace(theContext, baseViewPoint1);
			
			CGPoint baseViewPoint2 = viewPoints[firstDrawnPointIndex];
			baseViewPoint2.y = baseLineYValue;
			baseViewPoint2 = CPAlignPointToUserSpace(theContext, baseViewPoint2);
			
			CGMutablePathRef fillPath = CGPathCreateMutableCopy(dataLinePath);
			CGPathAddLineToPoint(fillPath, NULL, baseViewPoint1.x, baseViewPoint1.y);
			CGPathAddLineToPoint(fillPath, NULL, baseViewPoint2.x, baseViewPoint2.y);
			CGPathCloseSubpath(fillPath);
			
			CGContextBeginPath(theContext);
			CGContextAddPath(theContext, fillPath);
			[self.areaFill fillPathInContext:theContext];
			
			CGPathRelease(fillPath);
		}
		
		// Draw line
		if ( self.dataLineStyle ) {
			CGContextBeginPath(theContext);
			CGContextAddPath(theContext, dataLinePath);
			[self.dataLineStyle setLineStyleInContext:theContext];
			CGContextStrokePath(theContext);
		}
		if ( dataLinePath ) CGPathRelease(dataLinePath);
		
		// Draw plot symbols
		if (self.plotSymbol || self.plotSymbols.count) {
			for (NSUInteger i = 0; i < self.xValues.count; i++) {
				if ( drawPointFlags[i] ) {
					CPPlotSymbol *currentSymbol = self.plotSymbol;
					if ( i < self.plotSymbols.count ) currentSymbol = [self.plotSymbols objectAtIndex:i];
					if ( [currentSymbol isKindOfClass:[CPPlotSymbol class]] ) {
						[currentSymbol renderInContext:theContext atPoint:viewPoints[i]];			
					}
				}
			}
		}
	}
	
	free(viewPoints);
	free(drawPointFlags);
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
#pragma mark Accessors

-(void)setPlotSymbol:(CPPlotSymbol *)aSymbol
{
	if (aSymbol != plotSymbol) {
		[plotSymbol release];
		plotSymbol = [aSymbol copy];
		[self setNeedsDisplay];
	}
}

-(void)setDataLineStyle:(CPLineStyle *)value {
	if (dataLineStyle != value) {
		[dataLineStyle release];
		dataLineStyle = [value copy];
		[self setNeedsDisplay];
	}
}

-(void)setAreaBaseValue:(NSDecimal)newAreaBaseValue
{
	if (CPDecimalEquals(areaBaseValue, newAreaBaseValue))
	{
		return;
	}
	areaBaseValue = newAreaBaseValue;
	[self setNeedsDisplay];
}

-(void)setXValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPScatterPlotFieldX];
}

-(NSArray *)xValues 
{
    return [self cachedNumbersForField:CPScatterPlotFieldX];
}

-(void)setYValues:(NSArray *)newValues 
{
    [self cacheNumbers:newValues forField:CPScatterPlotFieldY];
}

-(NSArray *)yValues 
{
    return [self cachedNumbersForField:CPScatterPlotFieldY];
}

@end
