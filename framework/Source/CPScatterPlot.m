
#import "CPScatterPlot.h"
#import "CPLineStyle.h"
#import "CPPlotSpace.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPXYPlotSpace.h"
#import "CPPlotSymbol.h"
#import "stdlib.h"

NSString *CPScatterPlotBindingXValues = @"xValues";
NSString *CPScatterPlotBindingYValues = @"yValues";

static NSString *CPXValuesBindingContext = @"CPXValuesBindingContext";
static NSString *CPYValuesBindingContext = @"CPYValuesBindingContext";


@interface CPScatterPlot ()

@property (nonatomic, readwrite, retain) id observedObjectForXValues;
@property (nonatomic, readwrite, retain) id observedObjectForYValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForXValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForYValues;

@property (nonatomic, readwrite, retain) NSArray *xValues;
@property (nonatomic, readwrite, retain) NSArray *yValues;
@property (nonatomic, readwrite, retain) NSMutableArray *plotSymbols;

@end


@implementation CPScatterPlot

@synthesize numericType;
@synthesize observedObjectForXValues;
@synthesize observedObjectForYValues;
@synthesize keyPathForXValues;
@synthesize keyPathForYValues;
@synthesize hasErrorBars;
@synthesize dataLineStyle;
@synthesize xValues;
@synthesize yValues;
@synthesize plotSymbols;
@synthesize defaultPlotSymbol;

#pragma mark -
#pragma mark init/dealloc

+(void)initialize
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
#else
    [self exposeBinding:CPScatterPlotBindingXValues];	
    [self exposeBinding:CPScatterPlotBindingYValues];	
#endif
	
}

-(id)initWithFrame:(CGRect)newFrame
{
    if (self = [super initWithFrame:newFrame]) {
        self.numericType = CPNumericTypeFloat;
		self.dataLineStyle = [CPLineStyle lineStyle];
		self.plotSymbols = [[[NSMutableArray alloc] init] autorelease];
		self.defaultPlotSymbol = nil;
		self.needsDisplayOnBoundsChange = YES;
    }

    return self;
}

-(void)dealloc
{
#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
#else
    if ( self.observedObjectForXValues ) [self unbind:CPScatterPlotBindingXValues];
    if ( self.observedObjectForYValues ) [self unbind:CPScatterPlotBindingYValues];
#endif
	
    self.xValues = nil;
    self.yValues = nil;
	self.plotSymbols = nil;
	self.defaultPlotSymbol = nil;
	
    [super dealloc];
}

#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
#else
-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
	
    [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    if ([binding isEqualToString:CPScatterPlotBindingXValues]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPXValuesBindingContext];
        self.observedObjectForXValues = observable;
        self.keyPathForXValues = keyPath;
    }
    else if ([binding isEqualToString:CPScatterPlotBindingYValues]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPYValuesBindingContext];
        self.observedObjectForYValues = observable;
        self.keyPathForYValues = keyPath;
    }
    [self setNeedsDisplay];
}

-(void)unbind:(NSString *)bindingName
{
    if ([bindingName isEqualToString:CPScatterPlotBindingXValues]) {
		[observedObjectForXValues removeObserver:self forKeyPath:keyPathForXValues];
        self.observedObjectForXValues = nil;
        self.keyPathForXValues = nil;
    }	
    else if ([bindingName isEqualToString:CPScatterPlotBindingYValues]) {
		[observedObjectForYValues removeObserver:self forKeyPath:keyPathForYValues];
        self.observedObjectForYValues = nil;
        self.keyPathForYValues = nil;
    }	
	[super unbind:bindingName];
	[self reloadData];
}
#endif

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CPXValuesBindingContext) {
        [self reloadData];
    }
    if (context == CPYValuesBindingContext) {
        [self reloadData];
    }
}

#pragma mark -
#pragma mark Accessors

-(void)setPlotSymbol:(CPPlotSymbol *)aSymbol atIndex:(NSUInteger)index
{
	NSObject *newSymbol;
	
	if (aSymbol) {
		newSymbol = aSymbol;
	} else {
		newSymbol = [NSNull null];
	}
	
	if (index < [self.plotSymbols count]) {
		[self.plotSymbols replaceObjectAtIndex:index withObject:newSymbol];	
	} else {
		for (NSUInteger i = [self.plotSymbols count]; i < index; i++) {
			[self.plotSymbols addObject:[NSNull null]];
		}
		[self.plotSymbols addObject:newSymbol];
	}
}

#pragma mark -
#pragma mark Data Loading

-(void)reloadData 
{    
    [super reloadData];
	
    CPXYPlotSpace *cartesianPlotSpace = (CPXYPlotSpace *)self.plotSpace;
    self.xValues = nil;
    self.yValues = nil;
	
    if ( self.observedObjectForXValues && self.observedObjectForYValues ) {
        // Use bindings to retrieve data
        self.xValues = [self.observedObjectForXValues valueForKeyPath:self.keyPathForXValues];
        self.yValues = [self.observedObjectForYValues valueForKeyPath:self.keyPathForYValues];
    }
    else if ( self.dataSource ) {
        // Expand the index range each end, to make sure that plot lines go to offscreen points
        NSUInteger numberOfRecords = [self.dataSource numberOfRecords];
        NSRange indexRange = [self recordIndexRangeForPlotRange:cartesianPlotSpace.xRange];
        NSRange expandedRange = CPExpandedRange(indexRange, 1);
        NSRange completeIndexRange = NSMakeRange(0, numberOfRecords);
        indexRange = NSIntersectionRange(expandedRange, completeIndexRange);
        
        self.xValues = [self decimalNumbersFromDataSourceForField:CPScatterPlotFieldX recordIndexRange:indexRange];
        self.yValues = [self decimalNumbersFromDataSourceForField:CPScatterPlotFieldY recordIndexRange:indexRange];
    }
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
    if ( self.xValues == nil || self.yValues == nil ) return;
    
	if ([self.xValues count] != [self.yValues count])
		[NSException raise:CPException format:@"Number of x and y values do not match"];
		
	// calculate view points
	CGPoint *viewPoints = malloc([self.xValues count] * sizeof(CGPoint));
	
	if (self.dataLineStyle || self.defaultPlotSymbol || [self.plotSymbols count]) {
		NSMutableArray *plotPoint = [NSMutableArray array];
		CGPoint viewPoint;
		
		for (NSUInteger ii = 0; ii < [self.xValues count]; ii++) {
			[plotPoint insertObject:[self.xValues objectAtIndex:ii] atIndex:0];
			[plotPoint insertObject:[self.yValues objectAtIndex:ii] atIndex:1];
			viewPoint = [self.plotSpace viewPointForPlotPoint:plotPoint];
			viewPoints[ii] = viewPoint;
			[plotPoint removeAllObjects];
		}
	}
	
	// draw line
	if (self.dataLineStyle) {
		CGMutablePathRef dataLine = CGPathCreateMutable();

		if ([self.xValues count] > 0) {
			CGPathMoveToPoint(dataLine, NULL, viewPoints[0].x, viewPoints[0].y);
		}
		for (NSUInteger ii = 1; ii < [self.xValues count]; ii++) {
			CGPathAddLineToPoint(dataLine, NULL, viewPoints[ii].x, viewPoints[ii].y);
		}
		
		CGContextBeginPath(theContext);
		CGContextAddPath(theContext, dataLine);
		[self.dataLineStyle setLineStyleInContext:theContext];
		CGContextStrokePath(theContext);
		
		CGPathRelease(dataLine);
	}
	
	// draw plot symbols
	if (self.defaultPlotSymbol || [self.plotSymbols count]) {
		for (NSUInteger ii = 0; ii < [self.xValues count]; ii++) {
			if (ii < [self.plotSymbols count]) {
				id <NSObject> symbol = [self.plotSymbols objectAtIndex:ii];
				if ([symbol isKindOfClass:[CPPlotSymbol class]]) {
					[(CPPlotSymbol *)symbol renderInContext:theContext atPoint:viewPoints[ii]];			
				} 
                else {
					[self.defaultPlotSymbol renderInContext:theContext atPoint:viewPoints[ii]];
				}
			} 
            else {
				[self.defaultPlotSymbol renderInContext:theContext atPoint:viewPoints[ii]];
			}
		}
	}
	
	free(viewPoints);
}

@end
