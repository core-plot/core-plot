
#import "Controller.h"
#import <CorePlot/CorePlot.h>

@implementation Controller

-(void)dealloc 
{
    [graph release];
    [super dealloc];
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    // Setup transform
    [NSValueTransformer setValueTransformer:[CPDecimalNumberValueTransformer new] forName:@"CPDecimalNumberValueTransformer"];
    
    // Create graph
    graph = [[CPXYGraph alloc] init];
	graph.frame = NSRectToCGRect(hostView.bounds);
    [hostView setLayer:graph];
	[hostView setWantsLayer:YES];
    
    // Setup plot space
    CPCartesianPlotSpace *plotSpace = (CPCartesianPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
    
    // Create one plot that uses bindings
	CPScatterPlot *boundLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    boundLinePlot.identifier = @"Bindings Plot";
	boundLinePlot.dataLineStyle.lineWidth = 2.f;
    [graph addPlot:boundLinePlot];
	[boundLinePlot bind:CPScatterPlotBindingXValues toObject:self withKeyPath:@"arrangedObjects.x" options:nil];
	[boundLinePlot bind:CPScatterPlotBindingYValues toObject:self withKeyPath:@"arrangedObjects.y" options:nil];
    
	// Add plot symbols
	boundLinePlot.defaultPlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	CGColorRef greenColor = CPNewCGColorFromNSColor([NSColor greenColor]);
	boundLinePlot.defaultPlotSymbol.fillColor = greenColor;
	CGColorRelease(greenColor);
    
    // Create a second plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    CGColorRef redColor = CPNewCGColorFromNSColor([NSColor redColor]);
    dataSourceLinePlot.dataLineStyle.lineColor = redColor;
    CGColorRelease(redColor);
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
	
    // Add some initial data
	NSDecimalNumber *x1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber *x2 = [NSDecimalNumber decimalNumberWithString:@"1.7"];
	NSDecimalNumber *x3 = [NSDecimalNumber decimalNumberWithString:@"2.8"];
	NSDecimalNumber *y1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber *y2 = [NSDecimalNumber decimalNumberWithString:@"2.3"];
	NSDecimalNumber *y3 = [NSDecimalNumber decimalNumberWithString:@"2"];
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:
        [NSMutableDictionary dictionaryWithObjectsAndKeys:x1, @"x", y1, @"y", nil],
        [NSMutableDictionary dictionaryWithObjectsAndKeys:x2, @"x", y2, @"y", nil],
        [NSMutableDictionary dictionaryWithObjectsAndKeys:x3, @"x", y3, @"y", nil],
        nil];
	self.content = contentArray;
}

-(id)newObject 
{
	NSDecimalNumber *x1 = [NSDecimalNumber decimalNumberWithString:@"1.0"];
	NSDecimalNumber *y1 = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:x1, @"x", y1, @"y", nil];
}

#pragma mark -
#pragma mark Actions

-(IBAction)reloadDataSourcePlot:(id)sender {
    CPPlot *plot = [graph plotWithIdentifier:@"Data Source Plot"];
    [plot reloadData];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return [self.arrangedObjects count];
}

-(NSDecimalNumber *)decimalNumberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [[self.arrangedObjects objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if ( fieldEnum == CPScatterPlotFieldY ) num = [num decimalNumberByAdding:[NSDecimalNumber one]];
    return num;
}

@end
