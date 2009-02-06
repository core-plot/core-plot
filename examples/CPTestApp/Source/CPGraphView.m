
#import <CorePlot/CorePlot.h>
#import "CPGraphView.h"

@implementation CPGraphView

-(id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) setupPlot
{
	CPPlotArea* plotArea = [[CPPlotArea alloc] init];
	CPPlot* linePlot = [[CPPlot alloc] init];
	CPCartesianPlotSpace* cartPlotSpace = [[CPCartesianPlotSpace alloc] init];
//	[cartPlotSpace setScale:CGPointMake(2.f, 1.f)];
//	[cartPlotSpace setOffset:CGPointMake(0.f, 0.f)];
	CPPlotRange x, y;
	x.location = [[[[NSDecimalNumber alloc] initWithInt:1] autorelease] decimalValue];
	x.length = [[[[NSDecimalNumber alloc] initWithInt:2] autorelease] decimalValue];
	y.location = [[[[NSDecimalNumber alloc] initWithInt:1] autorelease] decimalValue];
	y.length = [[[[NSDecimalNumber alloc] initWithInt:2] autorelease] decimalValue];
//	NSArray* xTicks = [[NSArray alloc] initWithObjects:
//					   [[[NSDecimalNumber alloc] initWithInt:1] autorelease],
//					   [[[NSDecimalNumber alloc] initWithFloat:1.5f] autorelease], 
//					   [[[NSDecimalNumber alloc] initWithInt:2] autorelease], 
//					   [[[NSDecimalNumber alloc] initWithFloat:2.5f] autorelease], 
//					   [[[NSDecimalNumber alloc] initWithInt:3] autorelease], nil];
	
	[cartPlotSpace setXRange:x];
	[cartPlotSpace setYRange:y];
//	[cartPlotSpace setXMajorTickLocations:xTicks];
//	[cartPlotSpace setYMajorTickLocations:xTicks];
	[cartPlotSpace setNeedsDisplayOnBoundsChange:YES];
	
	[linePlot setPlotSpace:cartPlotSpace];
	[linePlot setIdentifier:@"Test Plot"];
	[[plotArea valueForKey:@"plotSpaces"] addObject:cartPlotSpace];
	[plotArea addSublayer:cartPlotSpace];
	[graphLayer setPlotArea:plotArea];
	[graphLayer addPlot:linePlot];
//	cartPlotSpace.majorTickLineStyle.lineColor = CGColorGetConstantColor(kCGColorWhite);
	
};

- (void)awakeFromNib{
	graphLayer = [[CPGraph layer] retain];
	[self setLayer:graphLayer];
	[self setWantsLayer:YES];
	//	[plotLayer setDelegate:plotLayer];
	graphLayer.frame = NSRectToCGRect(self.frame);
	[graphLayer setNeedsDisplayInRect:graphLayer.frame];
	[graphLayer setNeedsDisplayOnBoundsChange:YES];
	[self setupPlot];
}

- (void)drawRect:(NSRect)rect {
    // Drawing code here.
}

@end
