#import "CPTPlotDocument.h"
#import "NSString+ParseCSV.h"

@interface CPTPlotDocument()

@property (nonatomic, readwrite, strong, nullable) IBOutlet CPTGraphHostingView *graphView;
@property (nonatomic, readwrite, strong, nonnull) CPTXYGraph *graph;

@property (nonatomic, readwrite, assign) double minimumValueForXAxis;
@property (nonatomic, readwrite, assign) double maximumValueForXAxis;
@property (nonatomic, readwrite, assign) double minimumValueForYAxis;
@property (nonatomic, readwrite, assign) double maximumValueForYAxis;
@property (nonatomic, readwrite, assign) double majorIntervalLengthForX;
@property (nonatomic, readwrite, assign) double majorIntervalLengthForY;
@property (nonatomic, readwrite, strong) NSArray<NSDictionary *> *dataPoints;

@property (nonatomic, readwrite, strong, nullable) CPTPlotSpaceAnnotation *zoomAnnotation;
@property (nonatomic, readwrite, assign) CGPoint dragStart;
@property (nonatomic, readwrite, assign) CGPoint dragEnd;

@end

#pragma mark -

@implementation CPTPlotDocument

@synthesize graphView;
@synthesize graph;

@synthesize minimumValueForXAxis;
@synthesize maximumValueForXAxis;
@synthesize minimumValueForYAxis;
@synthesize maximumValueForYAxis;

@synthesize majorIntervalLengthForX;
@synthesize majorIntervalLengthForY;
@synthesize dataPoints;

@synthesize zoomAnnotation;
@synthesize dragStart;
@synthesize dragEnd;

// #define USE_NSDECIMAL

-(nonnull instancetype)init
{
    self = [super init];
    if ( self ) {
        dataPoints     = [[NSMutableArray alloc] init];
        zoomAnnotation = nil;
        dragStart      = CGPointZero;
        dragEnd        = CGPointZero;
    }
    return self;
}

-(nullable NSString *)windowNibName
{
    return @"CPTPlotDocument";
}

-(void)windowControllerDidLoadNib:(nonnull NSWindowController *__unused)windowController
{
    // Create graph from theme
    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme      = [CPTTheme themeNamed:kCPTDarkGradientTheme];

    [newGraph applyTheme:theme];
    self.graph = newGraph;

    self.graphView.hostedGraph = newGraph;

    newGraph.paddingLeft   = 0.0;
    newGraph.paddingTop    = 0.0;
    newGraph.paddingRight  = 0.0;
    newGraph.paddingBottom = 0.0;

    newGraph.plotAreaFrame.paddingLeft   = 55.0;
    newGraph.plotAreaFrame.paddingTop    = 40.0;
    newGraph.plotAreaFrame.paddingRight  = 40.0;
    newGraph.plotAreaFrame.paddingBottom = 35.0;

    newGraph.plotAreaFrame.plotArea.fill = newGraph.plotAreaFrame.fill;
    newGraph.plotAreaFrame.fill          = nil;

    newGraph.plotAreaFrame.borderLineStyle = nil;
    newGraph.plotAreaFrame.cornerRadius    = 0.0;
    newGraph.plotAreaFrame.masksToBorder   = NO;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(self.minimumValueForXAxis)
                                                    length:@(ceil((self.maximumValueForXAxis - self.minimumValueForXAxis) / self.majorIntervalLengthForX) * self.majorIntervalLengthForX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(self.minimumValueForYAxis)
                                                    length:@(ceil((self.maximumValueForYAxis - self.minimumValueForYAxis) / self.majorIntervalLengthForY) * self.majorIntervalLengthForY)];

    // this allows the plot to respond to mouse events
    plotSpace.delegate = self;
    [plotSpace setAllowsUserInteraction:YES];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;

    CPTXYAxis *x = axisSet.xAxis;

    x.minorTicksPerInterval = 9;
    x.majorIntervalLength   = @(self.majorIntervalLengthForX);
    x.labelOffset           = 5.0;
    x.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];

    CPTXYAxis *y = axisSet.yAxis;

    y.minorTicksPerInterval = 9;
    y.majorIntervalLength   = @(self.majorIntervalLengthForY);
    y.labelOffset           = 5.0;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];

    // Create the main plot for the delimited data
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];

    dataSourceLinePlot.identifier = @"Data Source Plot";

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];

    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [newGraph addPlot:dataSourceLinePlot];
}

#pragma mark -
#pragma mark Data loading methods

-(nullable NSData *)dataOfType:(nonnull NSString *__unused)typeName error:(NSError *__autoreleasing __nullable *)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError ) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

-(BOOL)readFromData:(nonnull NSData *)data ofType:(NSString *)typeName error:(NSError *__autoreleasing __nullable *)outError
{
    if ( [typeName isEqualToString:@"CSVDocument"] ) {
        double minX = (double)INFINITY;
        double maxX = -(double)INFINITY;

        double minY = (double)INFINITY;
        double maxY = -(double)INFINITY;

        NSMutableArray<NSDictionary *> *newData = [[NSMutableArray alloc] init];

        NSString *fileContents = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

        // Parse CSV
        NSUInteger length = fileContents.length;
        NSUInteger lineStart = 0, lineEnd = 0, contentsEnd = 0;
        NSRange currentRange;

        // Read headers from the first line of the file
        [fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
        // currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
        // CPTStringArray * columnHeaders = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];
        // NSLog([columnHeaders objectAtIndex:0]);

        while ( lineEnd < length ) {
            [fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
            currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
            CPTStringArray *columnValues = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];

            double xValue = columnValues[0].doubleValue;
            double yValue = columnValues[1].doubleValue;
            if ( xValue < minX ) {
                minX = xValue;
            }
            if ( xValue > maxX ) {
                maxX = xValue;
            }
            if ( yValue < minY ) {
                minY = yValue;
            }
            if ( yValue > maxY ) {
                maxY = yValue;
            }

#ifdef USE_NSDECIMAL
            [newData addObject:@{ @"x": [NSDecimalNumber decimalNumberWithString:columnValues[0]],
                                  @"y": [NSDecimalNumber decimalNumberWithString:columnValues[1]] }
            ];
#else
            [newData addObject:@{ @"x": @(xValue),
                                  @"y": @(yValue) }
            ];
#endif
        }

        self.dataPoints = newData;

        double intervalX = (maxX - minX) / 5.0;
        if ( intervalX > 0.0 ) {
            intervalX = pow(10.0, ceil(log10(intervalX)));
        }
        self.majorIntervalLengthForX = intervalX;

        double intervalY = (maxY - minY) / 10.0;
        if ( intervalY > 0.0 ) {
            intervalY = pow(10.0, ceil(log10(intervalY)));
        }
        self.majorIntervalLengthForY = intervalY;

        minX = floor(minX / intervalX) * intervalX;
        minY = floor(minY / intervalY) * intervalY;

        self.minimumValueForXAxis = minX;
        self.maximumValueForXAxis = maxX;
        self.minimumValueForYAxis = minY;
        self.maximumValueForYAxis = maxY;
    }

    if ( outError ) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}

#pragma mark -
#pragma mark Zoom Methods

-(IBAction)zoomIn
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
    CPTPlotArea *plotArea     = self.graph.plotAreaFrame.plotArea;

    // convert the dragStart and dragEnd values to plot coordinates
    CGPoint dragStartInPlotArea = [self.graph convertPoint:self.dragStart toLayer:plotArea];
    CGPoint dragEndInPlotArea   = [self.graph convertPoint:self.dragEnd toLayer:plotArea];

    double start[2], end[2];

    // obtain the datapoints for the drag start and end
    [plotSpace doublePrecisionPlotPoint:start numberOfCoordinates:2 forPlotAreaViewPoint:dragStartInPlotArea];
    [plotSpace doublePrecisionPlotPoint:end numberOfCoordinates:2 forPlotAreaViewPoint:dragEndInPlotArea];

    // recalculate the min and max values
    self.minimumValueForXAxis = MIN(start[CPTCoordinateX], end[CPTCoordinateX]);
    self.maximumValueForXAxis = MAX(start[CPTCoordinateX], end[CPTCoordinateX]);
    self.minimumValueForYAxis = MIN(start[CPTCoordinateY], end[CPTCoordinateY]);
    self.maximumValueForYAxis = MAX(start[CPTCoordinateY], end[CPTCoordinateY]);

    // now adjust the plot range and axes
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(self.minimumValueForXAxis)
                                                    length:@(self.maximumValueForXAxis - self.minimumValueForXAxis)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(self.minimumValueForYAxis)
                                                    length:@(self.maximumValueForYAxis - self.minimumValueForYAxis)];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;

    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
}

-(IBAction)zoomOut
{
    double minX = (double)INFINITY;
    double maxX = -(double)INFINITY;

    double minY = (double)INFINITY;
    double maxY = -(double)INFINITY;

    // get the ful range min and max values
    for ( NSDictionary<NSString *, NSNumber *> *xyValues in self.dataPoints ) {
        double xVal = xyValues[@"x"].doubleValue;

        minX = fmin(xVal, minX);
        maxX = fmax(xVal, maxX);

        double yVal = xyValues[@"y"].doubleValue;

        minY = fmin(yVal, minY);
        maxY = fmax(yVal, maxY);
    }

    double intervalX = self.majorIntervalLengthForX;
    double intervalY = self.majorIntervalLengthForY;

    minX = floor(minX / intervalX) * intervalX;
    minY = floor(minY / intervalY) * intervalY;

    self.minimumValueForXAxis = minX;
    self.maximumValueForXAxis = maxX;
    self.minimumValueForYAxis = minY;
    self.maximumValueForYAxis = maxY;

    // now adjust the plot range and axes
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(minX)
                                                    length:@(ceil((maxX - minX) / intervalX) * intervalX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(minY)
                                                    length:@(ceil((maxY - minY) / intervalY) * intervalY)];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;

    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
}

#pragma mark -
#pragma mark PDF / image export

-(IBAction)exportToPDF:(nullable id __unused)sender
{
    NSSavePanel *pdfSavingDialog = [NSSavePanel savePanel];

    pdfSavingDialog.allowedFileTypes = @[@"pdf"];

    if ( [pdfSavingDialog runModal] == NSModalResponseOK ) {
        NSData *dataForPDF = [self.graph dataForPDFRepresentationOfLayer];

        NSURL *url = pdfSavingDialog.URL;
        if ( url ) {
            [dataForPDF writeToURL:url atomically:NO];
        }
    }
}

-(IBAction)exportToPNG:(nullable id __unused)sender
{
    NSSavePanel *pngSavingDialog = [NSSavePanel savePanel];

    pngSavingDialog.allowedFileTypes = @[@"png"];

    if ( [pngSavingDialog runModal] == NSModalResponseOK ) {
        NSImage *image            = [self.graph imageOfLayer];
        NSData *tiffData          = image.TIFFRepresentation;
        NSBitmapImageRep *tiffRep = [NSBitmapImageRep imageRepWithData:tiffData];
        NSData *pngData           = [tiffRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];

        NSURL *url = pngSavingDialog.URL;
        if ( url ) {
            [pngData writeToURL:url atomically:NO];
        }
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *__unused)plot
{
    return self.dataPoints.count;
}

-(nullable id)numberForPlot:(nonnull CPTPlot *__unused)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");

    return self.dataPoints[index][key];
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(BOOL)plotSpace:(nonnull CPTPlotSpace *__unused)space shouldHandlePointingDeviceDraggedEvent:(nonnull CPTNativeEvent *__unused)event atPoint:(CGPoint)interactionPoint
{
    CPTPlotSpaceAnnotation *annotation = self.zoomAnnotation;

    if ( annotation ) {
        CPTPlotArea *plotArea = self.graph.plotAreaFrame.plotArea;
        CGRect plotBounds     = plotArea.bounds;

// convert the dragStart and dragEnd values to plot coordinates
        CGPoint dragStartInPlotArea = [self.graph convertPoint:self.dragStart toLayer:plotArea];
        CGPoint dragEndInPlotArea   = [self.graph convertPoint:interactionPoint toLayer:plotArea];

// create the dragrect from dragStart to the current location
        CGFloat endX      = MAX(MIN(dragEndInPlotArea.x, CGRectGetMaxX(plotBounds)), CGRectGetMinX(plotBounds));
        CGFloat endY      = MAX(MIN(dragEndInPlotArea.y, CGRectGetMaxY(plotBounds)), CGRectGetMinY(plotBounds));
        CGRect borderRect = CGRectMake(dragStartInPlotArea.x, dragStartInPlotArea.y,
                                       (endX - dragStartInPlotArea.x),
                                       (endY - dragStartInPlotArea.y));

        annotation.contentAnchorPoint = CGPointMake(dragEndInPlotArea.x >= dragStartInPlotArea.x ? 0.0 : 1.0,
                                                    dragEndInPlotArea.y >= dragStartInPlotArea.y ? 0.0 : 1.0);
        annotation.contentLayer.frame = borderRect;
    }

    return NO;
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *__unused)space shouldHandlePointingDeviceDownEvent:(nonnull CPTNativeEvent *__unused)event atPoint:(CGPoint)interactionPoint
{
    if ( !self.zoomAnnotation ) {
        self.dragStart = interactionPoint;

        CPTPlotArea *plotArea       = self.graph.plotAreaFrame.plotArea;
        CGPoint dragStartInPlotArea = [self.graph convertPoint:self.dragStart toLayer:plotArea];

        if ( CGRectContainsPoint(plotArea.bounds, dragStartInPlotArea)) {
// create the zoom rectangle
// first a bordered layer to draw the zoomrect
            CPTBorderedLayer *zoomRectangleLayer = [[CPTBorderedLayer alloc] initWithFrame:CGRectNull];

            CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
            lineStyle.lineColor                = [CPTColor darkGrayColor];
            lineStyle.lineWidth                = 1.0;
            zoomRectangleLayer.borderLineStyle = lineStyle;

            CPTColor *transparentFillColor = [[CPTColor blueColor] colorWithAlphaComponent:0.2];
            zoomRectangleLayer.fill = [CPTFill fillWithColor:transparentFillColor];

            double start[2];
            [self.graph.defaultPlotSpace doublePrecisionPlotPoint:start numberOfCoordinates:2 forPlotAreaViewPoint:dragStartInPlotArea];
            CPTNumberArray *anchorPoint = @[@(start[CPTCoordinateX]),
                                            @(start[CPTCoordinateY])];

// now create the annotation
            CPTPlotSpace *defaultSpace = self.graph.defaultPlotSpace;
            if ( defaultSpace ) {
                CPTPlotSpaceAnnotation *annotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:defaultSpace anchorPlotPoint:anchorPoint];
                annotation.contentLayer = zoomRectangleLayer;
                self.zoomAnnotation     = annotation;

                [self.graph.plotAreaFrame.plotArea addAnnotation:annotation];
            }
        }
    }

    return NO;
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *__unused)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    CPTPlotSpaceAnnotation *annotation = self.zoomAnnotation;

    if ( annotation ) {
        self.dragEnd = interactionPoint;

// double-click to completely zoom out
        if ((event.type != NSEventTypeScrollWheel) && (event.clickCount == 2)) {
            CPTPlotArea *plotArea     = self.graph.plotAreaFrame.plotArea;
            CGPoint dragEndInPlotArea = [self.graph convertPoint:interactionPoint toLayer:plotArea];

            if ( CGRectContainsPoint(plotArea.bounds, dragEndInPlotArea)) {
                [self zoomOut];
            }
        }
        else if ( !CGPointEqualToPoint(self.dragStart, self.dragEnd)) {
// no accidental drag, so zoom in
            [self zoomIn];
        }

// and we're done with the drag
        [self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.zoomAnnotation = nil;

        self.dragStart = CGPointZero;
        self.dragEnd   = CGPointZero;
    }

    return NO;
}

-(BOOL)plotSpace:(nonnull CPTPlotSpace *__unused)space shouldHandlePointingDeviceCancelledEvent:(nonnull CPTNativeEvent *__unused)event atPoint:(CGPoint __unused)interactionPoint
{
    CPTPlotSpaceAnnotation *annotation = self.zoomAnnotation;

    if ( annotation ) {
        [self.graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.zoomAnnotation = nil;

        self.dragStart = CGPointZero;
        self.dragEnd   = CGPointZero;
    }

    return NO;
}

@end
