
#import <stdlib.h>
#import "CPScatterPlot.h"
#import "CPLineStyle.h"
#import "CPPlotSpace.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPXYPlotSpace.h"
#import "CPPlotSymbol.h"
#import "CPFill.h"


NSString * const CPScatterPlotBindingXValues = @"xValues";			///< X values.
NSString * const CPScatterPlotBindingYValues = @"yValues";			///< Y values.
NSString * const CPScatterPlotBindingPlotSymbols = @"plotSymbols";	///< Plot symbols.

static NSString * const CPXValuesBindingContext = @"CPXValuesBindingContext";
static NSString * const CPYValuesBindingContext = @"CPYValuesBindingContext";
static NSString * const CPPlotSymbolsBindingContext = @"CPPlotSymbolsBindingContext";

///	@cond
@interface CPScatterPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForXValues;
@property (nonatomic, readwrite, assign) id observedObjectForYValues;
@property (nonatomic, readwrite, assign) id observedObjectForPlotSymbols;

@property (nonatomic, readwrite, copy) NSString *keyPathForXValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForYValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForPlotSymbols;

@property (nonatomic, readwrite, retain) NSArray *xValues;
@property (nonatomic, readwrite, retain) NSArray *yValues;
@property (nonatomic, readwrite, retain) NSArray *plotSymbols;

@end
///	@endcond

/**	@brief A two-dimensional scatter plot.
 **/
@implementation CPScatterPlot

@synthesize observedObjectForXValues;
@synthesize observedObjectForYValues;
@synthesize observedObjectForPlotSymbols;
@synthesize keyPathForXValues;
@synthesize keyPathForYValues;
@synthesize keyPathForPlotSymbols;
@synthesize xValues;
@synthesize yValues;
@synthesize plotSymbols;

/**	@property dataLineStyle
 *  @brief The line style for the data line.
 *	If nil, the line is not drawn.
 **/
@synthesize dataLineStyle;

/**	@property plotSymbol
 *	@brief The plot symbol drawn at each point if the data source does not provide symbols.
 *	If nil, no symbol is drawn.
 **/
@synthesize plotSymbol;

/** @property areaFill 
 *  @brief The fill style for the area underneath the data line.
 *	If nil, the area is not filled.
 **/
@synthesize areaFill;

/**	@property areaBaseValue
 *	@brief The Y coordinate of the straight boundary of the area fill.
 *	If nil, the area is not filled.
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
    if (self = [super initWithFrame:newFrame]) {
		self.dataLineStyle = [CPLineStyle lineStyle];
		self.xValues = nil;
		self.yValues = nil;
		self.plotSymbols = nil;
		self.plotSymbol = nil;
		self.needsDisplayOnBoundsChange = YES;
        self.areaFill = nil;
        self.areaBaseValue = [NSDecimalNumber zero];
    }
    return self;
}

-(void)dealloc
{
    if ( self.observedObjectForXValues ) [self unbind:CPScatterPlotBindingXValues];
    if ( self.observedObjectForYValues ) [self unbind:CPScatterPlotBindingYValues];
    if ( self.observedObjectForPlotSymbols ) [self unbind:CPScatterPlotBindingPlotSymbols];

    self.observedObjectForXValues = nil;
    self.observedObjectForYValues = nil;
    self.observedObjectForPlotSymbols = nil;
    self.keyPathForXValues = nil;
    self.keyPathForYValues = nil;
    self.keyPathForPlotSymbols = nil;
    self.xValues = nil;
    self.yValues = nil;
	self.plotSymbols = nil;
	self.plotSymbol = nil;
    self.dataLineStyle = nil;
    self.areaFill = nil;
    self.areaBaseValue = nil;	
	
    [super dealloc];
}

-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    if ([binding isEqualToString:CPScatterPlotBindingXValues]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPXValuesBindingContext];
        self.observedObjectForXValues = observable;
        self.keyPathForXValues = keyPath;
		[self setDataNeedsReloading];
    }
    else if ([binding isEqualToString:CPScatterPlotBindingYValues]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPYValuesBindingContext];
        self.observedObjectForYValues = observable;
        self.keyPathForYValues = keyPath;
		[self setDataNeedsReloading];
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
		[self setDataNeedsReloading];
    }	
    else if ([bindingName isEqualToString:CPScatterPlotBindingYValues]) {
		[observedObjectForYValues removeObserver:self forKeyPath:self.keyPathForYValues];
        self.observedObjectForYValues = nil;
        self.keyPathForYValues = nil;
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
        
        self.xValues = [self decimalNumbersFromDataSourceForField:CPScatterPlotFieldX recordIndexRange:indexRange];
        self.yValues = [self decimalNumbersFromDataSourceForField:CPScatterPlotFieldY recordIndexRange:indexRange];
		
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
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
    if ( self.xValues == nil || self.yValues == nil ) return;
    if ( self.xValues.count == 0 ) return;
	if ( [self.xValues count] != [self.yValues count] ) {
		[NSException raise:CPException format:@"Number of x and y values do not match"];
	}
		
	// calculate view points
	CGPoint *viewPoints = malloc(self.xValues.count * sizeof(CGPoint));
	
	if ( self.dataLineStyle || self.areaFill || self.plotSymbol || self.plotSymbols.count ) {
        NSDecimalNumber* plotPoint[2];

		for (NSUInteger i = 0; i < [self.xValues count]; i++) {
            plotPoint[CPCoordinateX] = (NSDecimalNumber *)[self.xValues objectAtIndex:i];
            plotPoint[CPCoordinateY] = (NSDecimalNumber *)[self.yValues objectAtIndex:i];
			viewPoints[i] = [self.plotSpace viewPointForPlotPoint:plotPoint];
		}
	}

    // path
    CGMutablePathRef dataLinePath = NULL;
    if ( self.dataLineStyle || self.areaFill ) {
        dataLinePath = CGPathCreateMutable();
		CGPoint alignedPoint = alignPointToUserSpace(theContext, CGPointMake(viewPoints[0].x, viewPoints[0].y));
        CGPathMoveToPoint(dataLinePath, NULL, alignedPoint.x, alignedPoint.y);
		for (NSUInteger i = 1; i < self.xValues.count; i++) {
			alignedPoint = alignPointToUserSpace(theContext, CGPointMake(viewPoints[i].x, viewPoints[i].y));
			CGPathAddLineToPoint(dataLinePath, NULL, alignedPoint.x, alignedPoint.y);
		}        
    }
    
    // draw fill
    if ( self.areaFill && self.areaBaseValue ) {
        NSDecimalNumber* plotPoint[2];
		
        plotPoint[CPCoordinateX] = (NSDecimalNumber *)[self.xValues objectAtIndex:0];
        plotPoint[CPCoordinateY] = (NSDecimalNumber *)self.areaBaseValue;
        CGPoint baseLinePoint = [self.plotSpace viewPointForPlotPoint:plotPoint];
        CGFloat baseLineYValue = baseLinePoint.y;
        
        CGPoint baseViewPoint1 = viewPoints[self.xValues.count-1];
        baseViewPoint1.y = baseLineYValue;
		baseViewPoint1 = alignPointToUserSpace(theContext, baseViewPoint1);
        CGPoint baseViewPoint2 = viewPoints[0];
        baseViewPoint2.y = baseLineYValue;
		baseViewPoint2 = alignPointToUserSpace(theContext, baseViewPoint2);
        
        CGMutablePathRef fillPath = CGPathCreateMutableCopy(dataLinePath);
        CGPathAddLineToPoint(fillPath, NULL, baseViewPoint1.x, baseViewPoint1.y);
        CGPathAddLineToPoint(fillPath, NULL, baseViewPoint2.x, baseViewPoint2.y);
        CGPathCloseSubpath(fillPath);
        
        CGContextBeginPath(theContext);
        CGContextAddPath(theContext, fillPath);
        [self.areaFill fillPathInContext:theContext];
        
        CGPathRelease(fillPath);
    }

	// draw line
	if ( self.dataLineStyle ) {
		CGContextBeginPath(theContext);
		CGContextAddPath(theContext, dataLinePath);
		[self.dataLineStyle setLineStyleInContext:theContext];
		CGContextStrokePath(theContext);
	}
    if ( dataLinePath ) CGPathRelease(dataLinePath);
	
	// draw plot symbols
	if (self.plotSymbol || self.plotSymbols.count) {
		if ( self.plotSymbols.count > 0 ) {
			for (NSUInteger i = 0; i < self.xValues.count; i++) {
				if (i < self.plotSymbols.count) {
					id <NSObject> currentSymbol = [self.plotSymbols objectAtIndex:i];
					if ([currentSymbol isKindOfClass:[CPPlotSymbol class]]) {
						[(CPPlotSymbol *)currentSymbol renderInContext:theContext atPoint:alignPointToUserSpace(theContext, viewPoints[i])];			
					} 
				} 
			}
		}
		else {
			CPPlotSymbol *theSymbol = self.plotSymbol;
			for (NSUInteger i = 0; i < self.xValues.count; i++) {
				[theSymbol renderInContext:theContext atPoint:alignPointToUserSpace(theContext,viewPoints[i])];
			}
		}
	}
	
	free(viewPoints);
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

@end
