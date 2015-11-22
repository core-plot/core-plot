#import "Controller.h"

static const CGFloat kZDistanceBetweenLayers = 20.0;

static NSString *const bindingsPlot   = @"Bindings Plot";
static NSString *const dataSourcePlot = @"Data Source Plot";
static NSString *const barPlot1       = @"Bar Plot 1";
static NSString *const barPlot2       = @"Bar Plot 2";

@interface Controller()

@property (nonatomic, readwrite, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, readwrite, weak) IBOutlet NSWindow *plotSymbolWindow;
@property (nonatomic, readwrite, weak) IBOutlet NSWindow *axisDemoWindow;
@property (nonatomic, readwrite, weak) IBOutlet NSWindow *selectionDemoWindow;

@property (nonatomic, readwrite, strong) CPTXYGraph *graph;
@property (nonatomic, readwrite, strong) RotationView *overlayRotationView;
@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;

-(void)setupGraph;
-(void)setupAxes;
-(void)setupScatterPlots;
-(void)positionFloatingAxis;
-(void)setupBarPlots;

@end

#pragma mark -

@implementation Controller

@synthesize hostView;
@synthesize plotSymbolWindow;
@synthesize axisDemoWindow;
@synthesize selectionDemoWindow;

@synthesize graph;
@synthesize overlayRotationView;
@synthesize symbolTextAnnotation;

@synthesize xShift;
@synthesize yShift;
@synthesize labelRotation;

+(void)initialize
{
    [NSValueTransformer setValueTransformer:[CPTDecimalNumberValueTransformer new] forName:@"CPTDecimalNumberValueTransformer"];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.xShift = 0.0;
    self.yShift = 0.0;

    [self setupGraph];
    [self setupAxes];
    [self setupScatterPlots];
    [self positionFloatingAxis];
    [self setupBarPlots];
}

-(id)newObject
{
    NSNumber *x1 = @(1.0 + ( (NSMutableArray *)self.content ).count * 0.05);
    NSNumber *y1 = @(1.2 * arc4random() / (double)UINT32_MAX + 1.2);

    return @{
               @"x": x1,
               @"y": y1
    };
}

#pragma mark -
#pragma mark Graph Setup Methods

-(void)setupGraph
{
    // Create graph and apply a dark theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(self.hostView.bounds)];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];

    [newGraph applyTheme:theme];
    self.hostView.hostedGraph = newGraph;
    self.graph                = newGraph;

    // Graph title
    NSString *lineOne = @"This is the Graph Title";
    NSString *lineTwo = @"This is the Second Line of the Title";

    NSMutableAttributedString *graphTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", lineOne, lineTwo]];
    [graphTitle addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:NSMakeRange(0, lineOne.length)];
    [graphTitle addAttribute:NSForegroundColorAttributeName value:[NSColor darkGrayColor] range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = CPTTextAlignmentCenter;
    [graphTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, graphTitle.length)];
    NSFont *titleFont = [NSFont fontWithName:@"Helvetica-Bold" size:18.0];
    [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(0, lineOne.length)];
    titleFont = [NSFont fontWithName:@"Helvetica" size:14.0];
    [graphTitle addAttribute:NSFontAttributeName value:titleFont range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
    newGraph.attributedTitle = graphTitle;

    newGraph.titleDisplacement        = CGPointMake(0.0, 50.0);
    newGraph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;

    // Graph padding
    newGraph.paddingLeft   = 60.0;
    newGraph.paddingTop    = 60.0;
    newGraph.paddingRight  = 60.0;
    newGraph.paddingBottom = 60.0;

    // Plot area delegate
    newGraph.plotAreaFrame.plotArea.delegate = self;
}

-(void)setupAxes
{
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.75];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.1];

    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

    // Axes
    // Label x axis with a fixed interval policy
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @0.5;
    x.orthogonalPosition    = @2.0;
    x.minorTicksPerInterval = 2;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    CPTPlotRangeArray *exclusionRanges = @[[CPTPlotRange plotRangeWithLocation:@1.99 length:@0.02],
                                           [CPTPlotRange plotRangeWithLocation:@0.99 length:@0.02],
                                           [CPTPlotRange plotRangeWithLocation:@2.99 length:@0.02]];
    x.labelExclusionRanges = exclusionRanges;

    NSMutableAttributedString *xTitle = [[NSMutableAttributedString alloc] initWithString:@"X Axis\nLine 2"];
    [xTitle addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, 6)];
    [xTitle addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:NSMakeRange(7, 6)];
    NSMutableParagraphStyle *xParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    xParagraphStyle.alignment = CPTTextAlignmentCenter;
    [xTitle addAttribute:NSParagraphStyleAttributeName value:xParagraphStyle range:NSMakeRange(0, xTitle.length)];
    x.attributedTitle = xTitle;

    x.titleOffset   = 30.0;
    x.titleLocation = @3.0;

    // Label y with an automatic label policy.
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.orthogonalPosition          = @2.0;
    y.minorTicksPerInterval       = 2;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.labelOffset                 = 10.0;
    exclusionRanges               = @[[CPTPlotRange plotRangeWithLocation:@1.99 length:@0.02],
                                      [CPTPlotRange plotRangeWithLocation:@0.99 length:@0.02],
                                      [CPTPlotRange plotRangeWithLocation:@3.99 length:@0.02]];
    y.labelExclusionRanges = exclusionRanges;

    NSMutableAttributedString *yTitle = [[NSMutableAttributedString alloc] initWithString:@"Y Axis\nLine 2"];
    [yTitle addAttribute:NSForegroundColorAttributeName value:[NSColor whiteColor] range:NSMakeRange(0, 6)];
    [yTitle addAttribute:NSForegroundColorAttributeName value:[NSColor grayColor] range:NSMakeRange(7, 6)];
    NSMutableParagraphStyle *yParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    yParagraphStyle.alignment = CPTTextAlignmentCenter;
    [yTitle addAttribute:NSParagraphStyleAttributeName value:yParagraphStyle range:NSMakeRange(0, yTitle.length)];
    y.attributedTitle = yTitle;

    y.titleOffset   = 30.0;
    y.titleLocation = @2.7;

    // Rotate the labels by 45 degrees, just to show it can be done.
    self.labelRotation = M_PI_4;

    // Add an extra y axis (red)
    // We add constraints to this axis below
    CPTXYAxis *y2 = [[CPTXYAxis alloc] initWithFrame:CGRectZero];
    y2.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y2.orthogonalPosition          = @3.0;
    y2.minorTicksPerInterval       = 0;
    y2.preferredNumberOfMajorTicks = 4;
    y2.majorGridLineStyle          = majorGridLineStyle;
    y2.minorGridLineStyle          = minorGridLineStyle;
    y2.labelOffset                 = 10.0;
    y2.coordinate                  = CPTCoordinateY;
    y2.plotSpace                   = self.graph.defaultPlotSpace;
    y2.axisLineStyle               = redLineStyle;
    y2.majorTickLineStyle          = redLineStyle;
    y2.minorTickLineStyle          = nil;
    y2.labelTextStyle              = nil;
    y2.visibleRange                = [CPTPlotRange plotRangeWithLocation:@2.0 length:@3.0];
    y2.title                       = @"Y2 title";
    y2.titleLocation               = @3.0;
    // Set axes
    self.graph.axisSet.axes = @[x, y, y2];
}

-(void)setupScatterPlots
{
    static BOOL hasData = NO;

    // Create one plot that uses bindings
    CPTScatterPlot *boundLinePlot = [[CPTScatterPlot alloc] init];

    boundLinePlot.identifier = bindingsPlot;

    CPTMutableLineStyle *lineStyle = [boundLinePlot.dataLineStyle mutableCopy];
    lineStyle.miterLimit        = 1.0;
    lineStyle.lineWidth         = 3.0;
    lineStyle.lineColor         = [CPTColor blueColor];
    boundLinePlot.dataLineStyle = lineStyle;

    [self.graph addPlot:boundLinePlot];
    [boundLinePlot bind:CPTScatterPlotBindingXValues toObject:self withKeyPath:@"arrangedObjects.x" options:nil];
    [boundLinePlot bind:CPTScatterPlotBindingYValues toObject:self withKeyPath:@"arrangedObjects.y" options:nil];

    // Put an area gradient under the plot above
    CPTImage *fillImage = [CPTImage imageNamed:@"BlueTexture"];
    fillImage.tiled = YES;
    CPTFill *areaImageFill = [CPTFill fillWithImage:fillImage];
    boundLinePlot.areaFill      = areaImageFill;
    boundLinePlot.areaBaseValue = @1.0;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;

    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    boundLinePlot.delegate                        = self;
    boundLinePlot.plotSymbolMarginForHitDetection = 5.0;

    // Create a second plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier     = dataSourcePlot;
    dataSourceLinePlot.cachePrecision = CPTPlotCachePrecisionDouble;

    lineStyle                        = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;

    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color              = [CPTColor whiteColor];
    dataSourceLinePlot.labelTextStyle = whiteTextStyle;

    dataSourceLinePlot.labelOffset   = 5.0;
    dataSourceLinePlot.labelRotation = M_PI_4;
    [self.graph addPlot:dataSourceLinePlot];

    // Make the data source line use stepped interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationStepped;

    // Put an area gradient under the plot above
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:0.3 green:1.0 blue:0.3 alpha:0.8];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    dataSourceLinePlot.areaFill      = areaGradientFill;
    dataSourceLinePlot.areaBaseValue = @1.75;

    if ( !hasData ) {
        // Add some initial data
        NSMutableArray<NSDictionary *> *contentArray = [NSMutableArray arrayWithCapacity:100];
        for ( NSUInteger i = 0; i < 60; i++ ) {
            NSNumber *x = @(1.0 + i * 0.05);
            NSNumber *y = @(1.2 * arc4random() / (double)UINT32_MAX + 1.2);
            [contentArray addObject:@{ @"x": x,
                                       @"y": y }
            ];
        }

        self.content = contentArray;
        hasData      = YES;
    }

    // Auto scale the plot space to fit the plot data
    // Extend the y range by 10% for neatness
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    plotSpace.allowsMomentum = YES;

    [plotSpace scaleToFitPlots:@[boundLinePlot, dataSourceLinePlot]];
    CPTPlotRange *xRange        = plotSpace.xRange;
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:@1.1];
    plotSpace.yRange = yRange;

    // Restrict y range to a global range
    plotSpace.globalXRange = [CPTPlotRange plotRangeWithLocation:@(-1.0) length:@5.0];
    plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:@0.0 length:@6.0];

    // set the x and y shift to match the new ranges
    CGFloat length = xRange.lengthDouble;
    self.xShift = length - 3.0;
    length      = yRange.lengthDouble;
    self.yShift = length - 2.0;
}

-(void)positionFloatingAxis
{
    // Position y2 axis relative to the plot area, ie, not moving when dragging
    CPTXYAxis *y2 = (self.graph.axisSet.axes)[2];

    y2.axisConstraints = [CPTConstraints constraintWithUpperOffset:150.0];
}

-(void)setupBarPlots
{
    // Add plot space for horizontal bar charts
    CPTXYPlotSpace *barPlotSpace = [[CPTXYPlotSpace alloc] init];

    barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-20.0) length:@200.0];
    barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-7.0) length:@15.0];
    [self.graph addPlotSpace:barPlotSpace];

    // First bar plot
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color = [CPTColor whiteColor];
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor darkGrayColor] horizontalBars:YES];
    barPlot.baseValue      = @20.0;
    barPlot.dataSource     = self;
    barPlot.barOffset      = @(-0.25);
    barPlot.identifier     = barPlot1;
    barPlot.plotRange      = [CPTPlotRange plotRangeWithLocation:@0.0 length:@7.0];
    barPlot.labelTextStyle = whiteTextStyle;
    [self.graph addPlot:barPlot toPlotSpace:barPlotSpace];

    // Second bar plot
    barPlot              = [CPTBarPlot tubularBarPlotWithColor:[CPTColor blueColor] horizontalBars:YES];
    barPlot.dataSource   = self;
    barPlot.baseValue    = @20.0;
    barPlot.barOffset    = @0.25;
    barPlot.cornerRadius = 2.0;
    barPlot.identifier   = barPlot2;
    barPlot.plotRange    = [CPTPlotRange plotRangeWithLocation:@0.0 length:@7.0];
    barPlot.delegate     = self;
    [self.graph addPlot:barPlot toPlotSpace:barPlotSpace];
}

#pragma mark -
#pragma mark Actions

-(IBAction)reloadDataSourcePlot:(id)sender
{
    CPTPlot *plot = [self.graph plotWithIdentifier:dataSourcePlot];

    [plot reloadData];
}

-(IBAction)removeData:(id)sender
{
    NSUInteger index = self.selectionIndex;

    if ( index != NSNotFound ) {
        [self removeObjectAtArrangedObjectIndex:index];

        CPTPlot *plot = [self.graph plotWithIdentifier:dataSourcePlot];
        [plot deleteDataInIndexRange:NSMakeRange(index, 1)];
    }
}

-(IBAction)insertData:(id)sender
{
    NSUInteger index = self.selectionIndex;

    if ( index != NSNotFound ) {
        id newData = [self newObject];
        [self insertObject:newData atArrangedObjectIndex:index];

        CPTPlot *plot = [self.graph plotWithIdentifier:dataSourcePlot];
        [plot insertDataAtIndex:index numberOfRecords:1];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        return 8;
    }
    else {
        return [self.arrangedObjects count];
    }
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;

    if ( [plot isKindOfClass:[CPTBarPlot class]] ) {
        num = @( (index + 1) * (index + 1) );
        if ( [plot.identifier isEqual:barPlot2] ) {
            num = @(num.integerValue - 10);
        }
    }
    else {
        NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
        num = (self.arrangedObjects)[index][key];
        if ( fieldEnum == CPTScatterPlotFieldY ) {
            num = @(num.doubleValue + 1.0);
        }
    }
    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    if ( [(NSString *)plot.identifier isEqualToString : barPlot2] ) {
        return (id)[NSNull null]; // Don't show any label
    }
    else if ( [(NSString *)plot.identifier isEqualToString : barPlot1] && (index < 4) ) {
        return (id)[NSNull null];
    }
    else if ( index % 4 ) {
        return (id)[NSNull null];
    }
    else {
        return nil; // Use default label style
    }
}

#pragma mark -
#pragma mark CPTScatterPlot delegate method

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor whiteColor];
    hitAnnotationTextStyle.fontSize = 16.0f;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates
    NSDictionary<NSString *, NSNumber *> *dataPoint = (self.arrangedObjects)[index];

    NSNumber *x = dataPoint[@"x"];
    NSNumber *y = dataPoint[@"y"];

    CPTNumberArray *anchorPoint = @[x, y];

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 2;
    NSString *yString = [formatter stringFromNumber:y];

    // Now add the annotation to the plot area
    CPTPlotSpace *defaultSpace = self.graph.defaultPlotSpace;
    if ( defaultSpace ) {
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
        annotation              = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:defaultSpace anchorPlotPoint:anchorPoint];
        annotation.contentLayer = textLayer;
        annotation.displacement = CGPointMake(0.0, 20.0);
        [self.graph.plotAreaFrame.plotArea addAnnotation:annotation];
        self.symbolTextAnnotation = annotation;
    }
}

#pragma mark -
#pragma mark CPTBarPlot delegate method

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"barWasSelectedAtRecordIndex %u", (unsigned)index);

    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
    if ( annotation ) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor redColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica-Bold";

    // Determine point of symbol in plot coordinates

    NSNumber *x                 = @0;
    NSNumber *y                 = [self numberForPlot:plot field:0 recordIndex:index];
    CPTNumberArray *anchorPoint = @[x, @(index)];

    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 2;
    NSString *yString = [formatter stringFromNumber:y];

    // Now add the annotation to the plot area
    CPTPlotSpace *defaultSpace = self.graph.defaultPlotSpace;
    if ( defaultSpace ) {
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
        annotation              = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:defaultSpace anchorPlotPoint:anchorPoint];
        annotation.contentLayer = textLayer;
        annotation.displacement = CGPointMake(0.0, 0.0);
        [self.graph.plotAreaFrame.plotArea addAnnotation:annotation];
        self.symbolTextAnnotation = annotation;
    }

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"barWidth"];
    animation.duration            = 0.25;
    animation.toValue             = @0.0;
    animation.repeatCount         = 1;
    animation.autoreverses        = YES;
    animation.removedOnCompletion = YES;
    [plot addAnimation:animation forKey:@"barWidth"];
}

#pragma mark -
#pragma mark Plot area delegate method

-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea
{
    // Remove the annotation
    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }
}

#pragma mark -
#pragma mark PDF / image export

-(IBAction)exportToPDF:(id)sender
{
    NSSavePanel *pdfSavingDialog = [NSSavePanel savePanel];

    pdfSavingDialog.allowedFileTypes = @[@"pdf"];

    if ( [pdfSavingDialog runModal] == NSOKButton ) {
        NSData *dataForPDF = [self.graph dataForPDFRepresentationOfLayer];

        NSURL *url = pdfSavingDialog.URL;
        if ( url ) {
            [dataForPDF writeToURL:url atomically:NO];
        }
    }
}

-(IBAction)exportToPNG:(id)sender
{
    NSSavePanel *pngSavingDialog = [NSSavePanel savePanel];

    pngSavingDialog.allowedFileTypes = @[@"png"];

    if ( [pngSavingDialog runModal] == NSOKButton ) {
        NSImage *image            = [self.graph imageOfLayer];
        NSData *tiffData          = image.TIFFRepresentation;
        NSBitmapImageRep *tiffRep = [NSBitmapImageRep imageRepWithData:tiffData];
        NSData *pngData           = [tiffRep representationUsingType:NSPNGFileType properties:@{}];

        NSURL *url = pngSavingDialog.URL;
        if ( url ) {
            [pngData writeToURL:url atomically:NO];
        }
    }
}

#pragma mark -
#pragma mark Printing

-(IBAction)printDocument:(id)sender
{
    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];

    NSRect printRect = NSZeroRect;

    printRect.size.width  = (printInfo.paperSize.width - printInfo.leftMargin - printInfo.rightMargin) * printInfo.scalingFactor;
    printRect.size.height = (printInfo.paperSize.height - printInfo.topMargin - printInfo.bottomMargin) * printInfo.scalingFactor;

    self.hostView.printRect = printRect;

    NSWindow *window = self.hostView.window;
    if ( window ) {
        NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:self.hostView printInfo:printInfo];
        [printOperation runOperationModalForWindow:window
                                          delegate:self
                                    didRunSelector:@selector(printOperationDidRun:success:contextInfo:)
                                       contextInfo:NULL];
    }
}

-(void)printOperationDidRun:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)contextInfo
{
    // print delegate
}

#pragma mark -
#pragma mark Layer exploding for illustration

-(IBAction)explodeLayers:(id)sender
{
    CATransform3D perspectiveRotation = CATransform3DMakeRotation(-40.0 * M_PI / 180.0, 0.0, 1.0, 0.0);

    perspectiveRotation = CATransform3DRotate(perspectiveRotation, -55.0 * M_PI / 180.0, perspectiveRotation.m11, perspectiveRotation.m21, perspectiveRotation.m31);

    perspectiveRotation = CATransform3DScale(perspectiveRotation, 0.7, 0.7, 0.7);

    self.graph.masksToBounds            = NO;
    self.graph.superlayer.masksToBounds = NO;

    RotationView *overlayView = [[RotationView alloc] initWithFrame:self.hostView.frame];
    overlayView.rotationDelegate  = self;
    overlayView.rotationTransform = perspectiveRotation;
    overlayView.autoresizingMask  = self.hostView.autoresizingMask;
    [self.hostView.superview addSubview:overlayView positioned:NSWindowAbove relativeTo:self.hostView];
    self.overlayRotationView = overlayView;

    [CATransaction begin];
    [CATransaction setValue:@1.0 forKey:kCATransactionAnimationDuration];

    [Controller recursivelySplitSublayersInZForLayer:self.graph depthLevel:0];
    self.graph.superlayer.sublayerTransform = perspectiveRotation;

    [CATransaction commit];
}

+(void)recursivelySplitSublayersInZForLayer:(CALayer *)layer depthLevel:(NSUInteger)depthLevel
{
    layer.zPosition   = kZDistanceBetweenLayers * (CGFloat)depthLevel;
    layer.borderColor = [CPTColor blueColor].cgColor;
    layer.borderWidth = 2.0;

    depthLevel++;
    for ( CALayer *currentLayer in layer.sublayers ) {
        [Controller recursivelySplitSublayersInZForLayer:currentLayer depthLevel:depthLevel];
    }
}

-(IBAction)reassembleLayers:(id)sender
{
    [CATransaction begin];
    [CATransaction setValue:@1.0f forKey:kCATransactionAnimationDuration];

    [Controller recursivelyAssembleSublayersInZForLayer:self.graph];
    self.graph.superlayer.sublayerTransform = CATransform3DIdentity;

    [CATransaction commit];

    [self.overlayRotationView removeFromSuperview];
    self.overlayRotationView = nil;
}

+(void)recursivelyAssembleSublayersInZForLayer:(CALayer *)layer
{
    layer.zPosition   = 0.0;
    layer.borderColor = [CPTColor clearColor].cgColor;
    layer.borderWidth = 0.0;
    for ( CALayer *currentLayer in layer.sublayers ) {
        [Controller recursivelyAssembleSublayersInZForLayer:currentLayer];
    }
}

#pragma mark -
#pragma mark Demo windows

-(IBAction)plotSymbolDemo:(id)sender
{
    if ( !self.plotSymbolWindow ) {
        [NSBundle loadNibNamed:@"PlotSymbolDemo" owner:self];
    }

    NSWindow *window = self.plotSymbolWindow;
    [window makeKeyAndOrderFront:sender];
}

-(IBAction)axisDemo:(id)sender
{
    if ( !self.axisDemoWindow ) {
        [NSBundle loadNibNamed:@"AxisDemo" owner:self];
    }

    NSWindow *window = self.axisDemoWindow;
    [window makeKeyAndOrderFront:sender];
}

-(IBAction)selectionDemo:(id)sender
{
    if ( !self.selectionDemoWindow ) {
        [NSBundle loadNibNamed:@"SelectionDemo" owner:self];
    }

    NSWindow *window = self.selectionDemoWindow;
    [window makeKeyAndOrderFront:sender];
}

#pragma mark -
#pragma mark CPTRotationDelegate delegate method

-(void)rotateObjectUsingTransform:(CATransform3D)rotationTransform
{
    [CATransaction begin];
    [CATransaction setValue:@(YES) forKey:kCATransactionDisableActions];

    self.graph.superlayer.sublayerTransform = rotationTransform;

    [CATransaction commit];
}

#pragma mark -
#pragma mark Accessors

-(void)setXShift:(CGFloat)newShift
{
    xShift = newShift;
    CPTXYPlotSpace *space         = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    CPTMutablePlotRange *newRange = [space.xRange mutableCopy];
    newRange.lengthDouble = 3.0 + newShift;
    space.xRange          = newRange;
}

-(void)setYShift:(CGFloat)newShift
{
    yShift = newShift;
    CPTXYPlotSpace *space         = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    CPTMutablePlotRange *newRange = [space.yRange mutableCopy];
    newRange.lengthDouble = 2.0 + newShift;
    space.yRange          = newRange;
}

-(void)setLabelRotation:(CGFloat)newRotation
{
    labelRotation = newRotation;

    ( (CPTXYAxisSet *)self.graph.axisSet ).yAxis.labelRotation   = newRotation;
    [self.graph plotWithIdentifier:dataSourcePlot].labelRotation = newRotation;
}

@end
