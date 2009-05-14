
#import "CPLinearAxis.h"
#import "CPPlotSpace.h"
#import "CPPlotRange.h"

@implementation CPLinearAxis

@synthesize independentRangeIndex;
@synthesize independentValue;

#pragma mark -
#pragma mark Init/Dealloc

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.independentValue = [NSDecimalNumber decimalNumberWithString:@"0.0"];
		self.independentRangeIndex = 0;
	}
	return self;
}

- (void) dealloc
{
	self.independentValue = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing


-(void)drawInContext:(CGContextRef)theContext {
	
	// Temporary storage for the viewPointForPlotPoint call
	NSMutableArray *plotPoint = [[NSMutableArray alloc] initWithCapacity:2];
	CGPoint viewPoint1, viewPoint2;
	NSInteger dependentRangeIndex;
	NSDecimal rangeLocation = range.location.decimalValue;
	NSDecimal rangeLength = range.length.decimalValue;
	
	if (independentRangeIndex == 0) 
	{	
		dependentRangeIndex = 1;
		[plotPoint insertObject:independentValue atIndex:independentRangeIndex];
		[plotPoint insertObject:[NSDecimalNumber decimalNumberWithDecimal:rangeLocation] atIndex:dependentRangeIndex];
	} else {
		dependentRangeIndex = 0;
		[plotPoint insertObject:[NSDecimalNumber decimalNumberWithDecimal:rangeLocation] atIndex:dependentRangeIndex];
		[plotPoint insertObject:independentValue atIndex:independentRangeIndex];
	}	
	
	NSDecimal secondValue;
	NSDecimalAdd(&secondValue, &rangeLocation, &rangeLength, NSRoundPlain);
	viewPoint1 = [[self plotSpace] viewPointForPlotPoint:plotPoint];
	[plotPoint replaceObjectAtIndex:dependentRangeIndex withObject:[NSDecimalNumber decimalNumberWithDecimal:secondValue]];
	viewPoint2 = [[self plotSpace] viewPointForPlotPoint:plotPoint];
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, nil, viewPoint1.x, viewPoint1.y);
	CGPathAddLineToPoint(path, nil, viewPoint2.x, viewPoint2.y);
	
	[plotPoint removeAllObjects];
/*	
	//	NSMutableArray *plotPoint = [NSMutableArray array];
	CGPoint viewPoint;
	
	
	// One path to hold the tickLines
	CGMutablePathRef tickLine = CGPathCreateMutable();
    
	// Make the tick line path
	for (NSDecimalNumber *tick in majorTickLocations)
	{
		[plotPoint insertObject:tick atIndex:0];
		[plotPoint insertObject:[NSDecimalNumber decimalNumberWithString:@"0.0"] atIndex:1];
		viewPoint = [[self plotSpace] viewPointForPlotPoint:plotPoint];
		CGPathMoveToPoint(tickLine, NULL, viewPoint.x, -1.f * majorTickLength);
		CGPathAddLineToPoint(tickLine, NULL, viewPoint.x, 0);
		[plotPoint removeAllObjects];
		
	}
*/	
	CGContextBeginPath(theContext);
	CGContextAddPath(theContext, path);
//	CGContextAddPath(theContext, tickLine);
	CGContextStrokePath(theContext);
	
	CGPathRelease(path);
//	CGPathRelease(tickLine);
	[plotPoint release];
	//	NSLog(@"Drawing Axis: %f", [plotSpace bounds].size.width);
}

@end
