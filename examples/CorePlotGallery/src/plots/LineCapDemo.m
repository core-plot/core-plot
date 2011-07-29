//
//  LineCapDemo.m
//  Plot Gallery
//

#import "LineCapDemo.h"

static const CGFloat titleOffset = 25.0;

@implementation LineCapDemo

+ (void)load
{
	[super registerPlotItem:self];
}

- (id)init
{
    if ((self = [super init])) {
        title = @"Line Caps";
    }
    
    return self;
}

- (void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme
{
#if TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif
    
    // Create graph
    CPTGraph* graph = [[[CPTXYGraph alloc] initWithFrame:[layerHostingView bounds]] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];
    
    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];
    
	graph.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
	
	// Plot area
	graph.plotAreaFrame.paddingTop = 25.0;
	graph.plotAreaFrame.paddingBottom = 25.0;
	graph.plotAreaFrame.paddingLeft = 25.0;
	graph.plotAreaFrame.paddingRight = 25.0;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(0) length:CPTDecimalFromUnsignedInteger(100)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(5.5) length:CPTDecimalFromInteger(-6)];
	
    // Line styles
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 3.0;
    
	// Line cap
	CPTLineCap *lineCap = [CPTLineCap lineCap];
	lineCap.size = CGSizeMake(15.0, 15.0);
	lineCap.lineStyle = axisLineStyle;
	lineCap.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
	
    // Axes
	NSMutableArray *axes = [[NSMutableArray alloc] init];
	
	for ( CPTLineCapType lineCapType = CPTLineCapTypeNone; lineCapType < CPTLineCapTypeCustom; ) {
		CPTXYAxis *axis = [[CPTXYAxis alloc] init];
		axis.plotSpace = graph.defaultPlotSpace;
		axis.labelingPolicy = CPTAxisLabelingPolicyNone;
		axis.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(lineCapType / 2);
		axis.axisLineStyle = axisLineStyle;
		
		lineCap.lineCapType = lineCapType++;
		axis.axisLineCapMin = lineCap;
		
		lineCap.lineCapType = lineCapType++;
		axis.axisLineCapMax = lineCap;
		
		[axes addObject:axis];
		[axis release];
	}
	
	// Add axes to the graph
	graph.axisSet.axes = axes;
	[axes release];
}

@end
