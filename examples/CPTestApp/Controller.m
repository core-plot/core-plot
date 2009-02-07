
#import "Controller.h"
#import <CorePlot/CorePlot.h>

@implementation Controller

-(void)awakeFromNib {
    [super awakeFromNib];
    
    // Create graph
    CPXYGraph *graph = [[CPXYGraph alloc] initWithXScaleType:CPScaleTypeLinear yScaleType:CPScaleTypeLinear];
	graph.frame = NSRectToCGRect(hostView.frame);
    [hostView.layer addSublayer:graph];
    [graph release];
    
    // Setup plot space
    CPCartesianPlotSpace *plotSpace = (CPCartesianPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = CPMakePlotRange(1.0, 2.0);
    plotSpace.yRange = CPMakePlotRange(1.0, 2.0);
    
    // Create and bind plot
	CPScatterPlot *linePlot = [[[CPScatterPlot alloc] init] autorelease];
    linePlot.identifier = @"Test Plot";
	linePlot.dataLineStyle.lineWidth = 2.f;
    [graph addPlot:linePlot];
	[linePlot bind:@"xValues" toObject:self withKeyPath:@"arrangedObjects.x" options:nil];
	[linePlot bind:@"yValues" toObject:self withKeyPath:@"arrangedObjects.y" options:nil];
    
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


@end
