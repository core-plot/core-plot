//
//  SimplePieChart.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/2/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "SimplePieChart.h"

@implementation SimplePieChart

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Simple Pie Chart";
        self.section = kPieCharts;
    }

    return self;
}

-(void)dealloc
{
    [plotData release];
    [super dealloc];
}

-(void)generateData
{
    if ( plotData == nil ) {
        plotData = [[NSMutableArray alloc] initWithObjects:
                    @20.0,
                    @30.0,
                    @60.0,
                    nil];
    }
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = layerHostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(layerHostingView.bounds);
#endif

    CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:bounds] autorelease];
    [self addGraph:graph toHostingView:layerHostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];

    graph.plotAreaFrame.masksToBorder = NO;
    graph.axisSet                     = nil;

    // Overlay gradient for pie chart
    CPTGradient *overlayGradient = [[[CPTGradient alloc] init] autorelease];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.0];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.3] atPosition:0.9];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.7] atPosition:1.0];

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN(0.7 * (layerHostingView.frame.size.height - 2 * graph.paddingLeft) / 2.0,
                             0.7 * (layerHostingView.frame.size.width - 2 * graph.paddingTop) / 2.0);
    piePlot.identifier     = self.title;
    piePlot.startAngle     = M_PI_4;
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    piePlot.overlayFill    = [CPTFill fillWithGradient:overlayGradient];

    piePlot.labelRotationRelativeToRadius = YES;
    piePlot.labelRotation                 = -M_PI_2;
    piePlot.labelOffset                   = -50.0;

    piePlot.delegate = self;
    [graph addPlot:piePlot];
    [piePlot release];

    // Add legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    theLegend.numberOfColumns = 1;
    theLegend.fill            = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];

    theLegend.entryFill            = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    theLegend.entryBorderLineStyle = [CPTLineStyle lineStyle];
    theLegend.entryCornerRadius    = CPTFloat(3.0);
    theLegend.entryPaddingLeft     = CPTFloat(3.0);
    theLegend.entryPaddingTop      = CPTFloat(3.0);
    theLegend.entryPaddingRight    = CPTFloat(3.0);
    theLegend.entryPaddingBottom   = CPTFloat(3.0);

    theLegend.cornerRadius = 5.0;
    theLegend.delegate     = self;

    graph.legend = theLegend;

    graph.legendAnchor       = CPTRectAnchorRight;
    graph.legendDisplacement = CGPointMake(-graph.paddingRight - 10.0, 0.0);
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        whiteText = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
    });

    CPTTextLayer *newLayer = [[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%1.0f", [plotData[index] floatValue]]
                                                           style:whiteText] autorelease];
    return newLayer;
}

#pragma mark -
#pragma mark CPTPieChartDelegate Methods

-(void)plot:(CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Data label for '%@' was selected at index %d.", plot.identifier, (int)index);
}

-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Slice was selected at index %d. Value = %f", (int)index, [plotData[index] floatValue]);

    NSMutableArray *newData = [[NSMutableArray alloc] init];
    NSUInteger dataCount    = ceil(10.0 * rand() / (double)RAND_MAX) + 1;
    for ( NSUInteger i = 1; i < dataCount; i++ ) {
        [newData addObject:@(100.0 * rand() / (double)RAND_MAX)];
    }
    NSLog(@"newData: %@", newData);

    [plotData release];
    plotData = newData;

    [plot reloadData];
}

#pragma mark -
#pragma mark CPTLegendDelegate Methods

-(void)legend:(CPTLegend *)legend legendEntryForPlot:(CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)idx;
{
    NSLog(@"Legend entry for '%@' was selected at index %lu.", plot.identifier, (unsigned long)idx);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [plotData count];
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        num = plotData[index];
    }
    else {
        return @(index);
    }

    return num;
}

-(NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    UIColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].uiColor;
#else
    NSColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].nsColor;
#endif

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Pie Slice %lu", (unsigned long)index]];
    if ( &NSForegroundColorAttributeName != NULL ) {
        [title addAttribute:NSForegroundColorAttributeName
                      value:sliceColor
                      range:NSMakeRange(4, 5)];
    }

    return [title autorelease];
}

@end
