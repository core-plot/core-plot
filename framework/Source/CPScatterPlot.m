
#import "CPScatterPlot.h"
#import "CPLineStyle.h"
#import "CPPlotSpace.h"

static NSString *CPXValuesBindingContext = @"CPXValuesBindingContext";
static NSString *CPYValuesBindingContext = @"CPYValuesBindingContext";


@interface CPScatterPlot ()

@property (nonatomic, readwrite, retain) id observedObjectForXValues;
@property (nonatomic, readwrite, retain) id observedObjectForYValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForXValues;
@property (nonatomic, readwrite, copy) NSString *keyPathForYValues;

@end


@implementation CPScatterPlot

@synthesize numericType;
@synthesize observedObjectForXValues;
@synthesize observedObjectForYValues;
@synthesize keyPathForXValues;
@synthesize keyPathForYValues;
@synthesize hasErrorBars;
@synthesize dataLineStyle;

#pragma mark init/dealloc

+(void)initialize
{
    [self exposeBinding:@"xValues"];	
    [self exposeBinding:@"yValues"];	
}

-(id)init
{
    if (self = [super init]) {
        self.numericType = CPNumericTypeFloat;
		self.dataLineStyle = [CPLineStyle defaultLineStyle];
    }
    return self;
}



-(void)dealloc
{
    self.keyPathForXValues = nil;
    self.keyPathForYValues = nil;
    self.observedObjectForXValues = nil;
    self.observedObjectForYValues = nil;
    [super dealloc];
}


-(void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    if ([binding isEqualToString:@"xValues"]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPXValuesBindingContext];
        self.observedObjectForXValues = observable;
        self.keyPathForXValues = keyPath;
    }
    else if ([binding isEqualToString:@"yValues"]) {
        [observable addObserver:self forKeyPath:keyPath options:0 context:CPYValuesBindingContext];
        self.observedObjectForYValues = observable;
        self.keyPathForYValues = keyPath;
    }
    else {
        [super bind:binding toObject:observable withKeyPath:keyPath options:options];
    }
    [self setNeedsDisplay];
}


-(void)unbind:(NSString *)bindingName
{
    if ([bindingName isEqualToString:@"xValues"]) {
		[observedObjectForXValues removeObserver:self forKeyPath:keyPathForXValues];
        self.observedObjectForXValues = nil;
        self.keyPathForXValues = nil;
    }	
    else if ([bindingName isEqualToString:@"yValues"]) {
		[observedObjectForYValues removeObserver:self forKeyPath:keyPathForYValues];
        self.observedObjectForYValues = nil;
        self.keyPathForYValues = nil;
    }	
	[super unbind:bindingName];
	[self setNeedsDisplay];
}

#pragma mark Drawing

- (void)drawInContext:(CGContextRef)theContext
{
	NSUInteger ii;
	NSArray* xData = [self.observedObjectForXValues valueForKey:self.keyPathForXValues];
	NSArray* yData = [self.observedObjectForYValues valueForKey:self.keyPathForYValues];
	CGMutablePathRef dataLine = CGPathCreateMutable();
	CGPathMoveToPoint(dataLine, NULL, 0.f, 0.f);
	// Temporary storage for the viewPointForPlotPoint call
	NSMutableArray* plotPoint = [NSMutableArray array];
	CGPoint viewPoint;

	// No error check your # of y points yet
	for (ii = 0; ii < [xData count]; ii++)
	{
		[plotPoint insertObject:[xData objectAtIndex:ii] atIndex:0];
		[plotPoint insertObject:[yData objectAtIndex:ii] atIndex:1];
		viewPoint = [plotSpace viewPointForPlotPoint:plotPoint];
		
		CGPathAddLineToPoint(dataLine, NULL, viewPoint.x, viewPoint.y);
		[plotPoint removeAllObjects];
	}
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, dataLine);
	[dataLineStyle CPApplyLineStyleToContext:theContext];
    CGContextStrokePath(theContext);
	
	CGPathRelease(dataLine);
		
}

@end
