
#import "CPScatterPlot.h"
#import "CPLineStyle.h"
#import "CPPlotSpace.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPXYPlotSpace.h"
#import "CPPlotSymbol.h"
#import "stdlib.h"

NSString * const CPScatterPlotBindingXValues = @"xValues";
NSString * const CPScatterPlotBindingYValues = @"yValues";

static NSString * const CPXValuesBindingContext = @"CPXValuesBindingContext";
static NSString * const CPYValuesBindingContext = @"CPYValuesBindingContext";


@interface CPScatterPlot ()

@property (nonatomic, readwrite, assign) id observedObjectForXValues;
@property (nonatomic, readwrite, assign) id observedObjectForYValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForXValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForYValues;

@property (nonatomic, readwrite, retain) NSArray *xValues;
@property (nonatomic, readwrite, retain) NSArray *yValues;
@property (nonatomic, readwrite, retain) NSMutableArray *plotSymbols;

@end


@implementation CPScatterPlot

@synthesize observedObjectForXValues;
@synthesize observedObjectForYValues;
@synthesize keyPathForXValues;
@synthesize keyPathForYValues;
@synthesize dataLineStyle;
@synthesize xValues;
@synthesize yValues;
@synthesize plotSymbols;
@synthesize defaultPlotSymbol;

#pragma mark -
#pragma mark init/dealloc

+(void)initialize
{
    [self exposeBinding:CPScatterPlotBindingXValues];	
    [self exposeBinding:CPScatterPlotBindingYValues];	
}

-(id)initWithFrame:(CGRect)newFrame
{
    if (self = [super initWithFrame:newFrame]) {
		self.dataLineStyle = [CPLineStyle lineStyle];
		self.plotSymbols = [[[NSMutableArray alloc] init] autorelease];
		self.defaultPlotSymbol = nil;
		self.needsDisplayOnBoundsChange = YES;
    }

    return self;
}

-(void)dealloc
{
    if ( self.observedObjectForXValues ) [self unbind:CPScatterPlotBindingXValues];
    if ( self.observedObjectForYValues ) [self unbind:CPScatterPlotBindingYValues];
	
    self.observedObjectForXValues = nil;
    self.observedObjectForYValues = nil;
    self.keyPathForXValues = nil;
    self.keyPathForYValues = nil;
    self.xValues = nil;
    self.yValues = nil;
	self.plotSymbols = nil;
	self.defaultPlotSymbol = nil;
    self.dataLineStyle = nil;
	
    [super dealloc];
}

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
#pragma mark Data Loading

-(void)reloadData 
{    
    [super reloadData];
	
    CPXYPlotSpace *xyPlotSpace = (CPXYPlotSpace *)self.plotSpace;
    self.xValues = nil;
    self.yValues = nil;
	
    if ( self.observedObjectForXValues && self.observedObjectForYValues ) {
        // Use bindings to retrieve data
        self.xValues = [self.observedObjectForXValues valueForKeyPath:self.keyPathForXValues];
        self.yValues = [self.observedObjectForYValues valueForKeyPath:self.keyPathForYValues];
    }
    else if ( self.dataSource ) {
        // Expand the index range each end, to make sure that plot lines go to offscreen points
        NSUInteger numberOfRecords = [self.dataSource numberOfRecordsForPlot:self];
        NSRange indexRange = [self recordIndexRangeForPlotRange:xyPlotSpace.xRange];
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
		CGPoint viewPoint;
		
        NSDecimalNumber* plotPoint[2];
		for (NSUInteger ii = 0; ii < [self.xValues count]; ii++) {
            plotPoint[CPCoordinateX] = (NSDecimalNumber *)[self.xValues objectAtIndex:ii];
            plotPoint[CPCoordinateY] = (NSDecimalNumber *)[self.yValues objectAtIndex:ii];
			viewPoint = [self.plotSpace viewPointForPlotPoint:plotPoint];
			viewPoints[ii] = viewPoint;
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
	[self setNeedsDisplay];
}

-(void)setDefaultPlotSymbol:(CPPlotSymbol *)aSymbol
{
	if (aSymbol != defaultPlotSymbol) {
		[defaultPlotSymbol release];
		defaultPlotSymbol = [aSymbol copy];
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
