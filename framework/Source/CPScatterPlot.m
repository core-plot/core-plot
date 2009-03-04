
#import "CPScatterPlot.h"
#import "CPLineStyle.h"
#import "CPPlotSpace.h"
#import "CPExceptions.h"
#import "CPUtilities.h"
#import "CPCartesianPlotSpace.h"

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

#pragma mark -
#pragma mark init/dealloc

+(void)initialize
{
    [self exposeBinding:CPScatterPlotBindingXValues];	
    [self exposeBinding:CPScatterPlotBindingYValues];	
}

-(id)init
{
    if (self = [super init]) {
        self.numericType = CPNumericTypeFloat;
		self.dataLineStyle = [CPLineStyle lineStyle];
    }
    return self;
}



-(void)dealloc
{
    if ( self.observedObjectForXValues ) [self unbind:CPScatterPlotBindingXValues];
    if ( self.observedObjectForYValues ) [self unbind:CPScatterPlotBindingYValues];
    self.xValues = nil;
    self.yValues = nil;
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
    CPCartesianPlotSpace *cartesianPlotSpace = (CPCartesianPlotSpace *)self.plotSpace;
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
	
	CGMutablePathRef dataLine = CGPathCreateMutable();
	NSMutableArray *plotPoint = [NSMutableArray array];
	CGPoint viewPoint;
	NSUInteger ii;
	for (ii = 0; ii < [xValues count]; ii++)
	{
		[plotPoint insertObject:[xValues objectAtIndex:ii] atIndex:0];
		[plotPoint insertObject:[yValues objectAtIndex:ii] atIndex:1];
		viewPoint = [plotSpace viewPointForPlotPoint:plotPoint];
		
        if ( ii == 0 )
            CGPathMoveToPoint(dataLine, NULL, viewPoint.x, viewPoint.y);
        else
            CGPathAddLineToPoint(dataLine, NULL, viewPoint.x, viewPoint.y);
            
		[plotPoint removeAllObjects];
	}
    
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, dataLine);
	[dataLineStyle setLineStyleInContext:theContext];
    CGContextStrokePath(theContext);
	
	CGPathRelease(dataLine);
}

@end
