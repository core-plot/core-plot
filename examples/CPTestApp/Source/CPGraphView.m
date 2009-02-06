
#import <CorePlot/CorePlot.h>
#import "CPGraphView.h"

@implementation CPGraphView

@synthesize graphLayer;
@synthesize xData, yData;

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		
        // Initialization code here.
    }
    return self;
}

- (void) setupPlot
{
	CPScatterPlot* linePlot = [[CPScatterPlot alloc] init];
	[linePlot bind:@"xValues" toObject:xData withKeyPath:@"arrangedObjects" options:nil];
	[linePlot bind:@"yValues" toObject:yData withKeyPath:@"arrangedObjects" options:nil];
	CPCartesianPlotSpace* cartPlotSpace = [[CPCartesianPlotSpace alloc] init];
	CPPlotRange x, y;
	x.location = [[[[NSDecimalNumber alloc] initWithInt:1] autorelease] decimalValue];
	x.length = [[[[NSDecimalNumber alloc] initWithInt:2] autorelease] decimalValue];
	y.location = [[[[NSDecimalNumber alloc] initWithInt:1] autorelease] decimalValue];
	y.length = [[[[NSDecimalNumber alloc] initWithInt:2] autorelease] decimalValue];
	[cartPlotSpace setXRange:x];
	[cartPlotSpace setYRange:y];
	[cartPlotSpace setNeedsDisplayOnBoundsChange:YES];
	[linePlot setPlotSpace:cartPlotSpace];
	[linePlot setIdentifier:@"Test Plot"];
	[graphLayer addPlotSpace:cartPlotSpace];
	[graphLayer addPlot:linePlot];

	linePlot.dataLineStyle.lineWidth = 2.f;
}

- (void) setupData
{
	NSDecimalNumber* x1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber* x2 = [NSDecimalNumber decimalNumberWithString:@"1.7"];
	NSDecimalNumber* x3 = [NSDecimalNumber decimalNumberWithString:@"2.8"];
	NSDecimalNumber* y1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber* y2 = [NSDecimalNumber decimalNumberWithString:@"2.3"];
	NSDecimalNumber* y3 = [NSDecimalNumber decimalNumberWithString:@"2"];

	NSArray* x = [NSArray arrayWithObjects:x1,x2,x3,nil];
	NSArray* y = [NSArray arrayWithObjects:y1,y2,y3,nil];
	
	[xData setContent:x];
	[yData setContent:y];
}

- (void)awakeFromNib{
	[self setGraphLayer:[CPGraph layer]];
	[self setLayer:graphLayer];
	[self setWantsLayer:YES];
	//	[plotLayer setDelegate:plotLayer];
	graphLayer.frame = NSRectToCGRect(self.frame);
	[graphLayer setNeedsDisplayInRect:graphLayer.frame];
	[graphLayer setNeedsDisplayOnBoundsChange:YES];
	[self setupData];
	[self setupPlot];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

@end
