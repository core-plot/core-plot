//
//  SimplePieChart.m
//  CorePlotGallery
//

#import "SimplePieChart.h"

@interface SimplePieChart()

@property (nonatomic, readwrite, strong) NSArray *plotData;

@end

@implementation SimplePieChart

@synthesize plotData;

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

-(void)generateData
{
    if ( self.plotData == nil ) {
        self.plotData = @[@20.0, @30.0, @60.0];
    }
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.masksToBorder = NO;
    graph.axisSet                     = nil;

    // Overlay gradient for pie chart
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:CPTFloat(0.0)] atPosition:CPTFloat(0.0)];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:CPTFloat(0.3)] atPosition:CPTFloat(0.9)];
    overlayGradient              = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:CPTFloat(0.7)] atPosition:CPTFloat(1.0)];

    // Add pie chart
    CPTPieChart *piePlot = [[CPTPieChart alloc] init];
    piePlot.dataSource = self;
    piePlot.pieRadius  = MIN( CPTFloat(0.7) * (hostingView.frame.size.height - CPTFloat(2.0) * graph.paddingLeft) / CPTFloat(2.0),
                              CPTFloat(0.7) * (hostingView.frame.size.width - CPTFloat(2.0) * graph.paddingTop) / CPTFloat(2.0) );
    piePlot.identifier     = self.title;
    piePlot.startAngle     = CPTFloat(M_PI_4);
    piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    piePlot.overlayFill    = [CPTFill fillWithGradient:overlayGradient];

    piePlot.labelRotationRelativeToRadius = YES;
    piePlot.labelRotation                 = CPTFloat(-M_PI_2);
    piePlot.labelOffset                   = -50.0;

    piePlot.delegate = self;
    [graph addPlot:piePlot];

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
    graph.legendDisplacement = CGPointMake(-graph.paddingRight - CPTFloat(10.0), 0.0);
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
    static dispatch_once_t onceToken      = 0;

    dispatch_once(&onceToken, ^{
        whiteText = [[CPTMutableTextStyle alloc] init];
        whiteText.color = [CPTColor whiteColor];
        whiteText.fontSize = self.titleSize * CPTFloat(0.5);
    });

    CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%1.0f", [self.plotData[index] floatValue]]
                                                          style:whiteText];
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
    NSLog(@"Slice was selected at index %d. Value = %f", (int)index, [self.plotData[index] floatValue]);

    NSMutableArray *newData = [[NSMutableArray alloc] init];
    NSUInteger dataCount    = (NSUInteger)lrint( ceil(10.0 * arc4random() / (double)UINT32_MAX) ) + 1;
    for ( NSUInteger i = 1; i < dataCount; i++ ) {
        [newData addObject:@(100.0 * arc4random() / (double)UINT32_MAX)];
    }
    NSLog(@"newData: %@", newData);

    self.plotData = newData;

    [plot reloadData];
}

#pragma mark -
#pragma mark CPTLegendDelegate Methods

-(void)legend:(CPTLegend *)legend legendEntryForPlot:(CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)idx
{
    NSLog(@"Legend entry for '%@' was selected at index %lu.", plot.identifier, (unsigned long)idx);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return self.plotData.count;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    if ( fieldEnum == CPTPieChartFieldSliceWidth ) {
        num = self.plotData[index];
    }
    else {
        num = @(index);
    }

    return num;
}

-(NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    UIColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].uiColor;
    UIFont *labelFont   = [UIFont fontWithName:@"Helvetica" size:self.titleSize * CPTFloat(0.5)];
#else
    NSColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].nsColor;
    NSFont *labelFont   = [NSFont fontWithName:@"Helvetica" size:self.titleSize * CPTFloat(0.5)];
#endif

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Pie Slice %lu", (unsigned long)index]];
    if ( &NSForegroundColorAttributeName != NULL ) {
        [title addAttribute:NSForegroundColorAttributeName
                      value:sliceColor
                      range:NSMakeRange(4, 5)];
    }

    if ( &NSFontAttributeName != NULL ) {
        [title addAttribute:NSFontAttributeName
                      value:labelFont
                      range:NSMakeRange(0, title.length)];
    }

    return title;
}

@end
