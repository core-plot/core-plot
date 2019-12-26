//
// SimplePieChart.m
// CorePlotGallery
//

#import "SimplePieChart.h"

@interface SimplePieChart()

@property (nonatomic, readwrite, strong, nonnull) CPTNumberArray *plotData;
@property (nonatomic, readwrite) NSUInteger offsetIndex;
@property (nonatomic, readwrite) CGFloat sliceOffset;

@end

@implementation SimplePieChart

@synthesize plotData;
@synthesize offsetIndex;
@synthesize sliceOffset;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        self.title   = @"Simple Pie Chart";
        self.section = kPieCharts;

        self.offsetIndex = NSNotFound;
    }

    return self;
}

-(void)generateData
{
    if ( self.plotData.count == 0 ) {
        self.plotData = @[@20.0, @30.0, @60.0];
    }
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
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
    piePlot.pieRadius  = MIN(CPTFloat(0.7) * (hostingView.frame.size.height - CPTFloat(2.0) * graph.paddingLeft) / CPTFloat(2.0),
                             CPTFloat(0.7) * (hostingView.frame.size.width - CPTFloat(2.0) * graph.paddingTop) / CPTFloat(2.0));
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

-(nullable CPTLayer *)dataLabelForPlot:(nonnull CPTPlot *)plot recordIndex:(NSUInteger)index
{
    static CPTMutableTextStyle *whiteText = nil;
    static dispatch_once_t onceToken      = 0;

    dispatch_once(&onceToken, ^{
        whiteText          = [[CPTMutableTextStyle alloc] init];
        whiteText.color    = [CPTColor whiteColor];
        whiteText.fontSize = self.titleSize * CPTFloat(0.5);
    });

    CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%1.0f", self.plotData[index].doubleValue]
                                                          style:whiteText];
    return newLayer;
}

#pragma mark -
#pragma mark CPTPieChartDelegate Methods

-(void)Plot:(nonnull CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Data label for '%@' was selected at index %d.", plot.identifier, (int)index);
}

-(void)pieChart:(nonnull CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Slice was selected at index %d. Value = %f", (int)index, self.plotData[index].doubleValue);

    self.offsetIndex = NSNotFound;

    CPTMutableNumberArray *newData = [[NSMutableArray alloc] init];
    NSUInteger dataCount           = (NSUInteger)lrint(ceil(10.0 * arc4random() / (double)UINT32_MAX)) + 1;
    for ( NSUInteger i = 1; i < dataCount; i++ ) {
        [newData addObject:@(100.0 * arc4random() / (double)UINT32_MAX)];
    }
    NSLog(@"newData: %@", newData);

    self.plotData = newData;

    [plot reloadData];
}

#pragma mark -
#pragma mark CPTLegendDelegate Methods

-(void)legend:(nonnull CPTLegend *)legend legendEntryForPlot:(nonnull CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)idx
{
    NSLog(@"Legend entry for '%@' was selected at index %lu.", plot.identifier, (unsigned long)idx);

    [CPTAnimation animate:self
                 property:@"sliceOffset"
                     from:(idx == self.offsetIndex ? CPTNAN : CPTFloat(0.0))
                       to:(idx == self.offsetIndex ? CPTFloat(0.0) : CPTFloat(35.0))
                 duration:0.5
           animationCurve:CPTAnimationCurveCubicOut
                 delegate:nil];

    self.offsetIndex = idx;
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    return self.plotData.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
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

-(NSAttributedString *)attributedLegendTitleForPieChart:(nonnull CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CPTNativeColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].nativeColor;
    CPTNativeFont *labelFont   = [CPTNativeFont fontWithName:@"Helvetica"
                                                        size:self.titleSize * CPTFloat(0.5)];

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Pie Slice %lu", (unsigned long)index]];

    [title addAttribute:NSForegroundColorAttributeName
                  value:sliceColor
                  range:NSMakeRange(4, 5)];

    [title addAttribute:NSFontAttributeName
                  value:labelFont
                  range:NSMakeRange(0, title.length)];

    return title;
}

-(CGFloat)radialOffsetForPieChart:(nonnull CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    return index == self.offsetIndex ? self.sliceOffset : 0.0;
}

#pragma mark -
#pragma mark Accessors

-(void)setSliceOffset:(CGFloat)newOffset
{
    if ( newOffset != sliceOffset ) {
        sliceOffset = newOffset;

        [self.graphs[0] reloadData];

        if ( newOffset == CPTFloat(0.0)) {
            self.offsetIndex = NSNotFound;
        }
    }
}

@end
