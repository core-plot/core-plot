#import "CPTPlotDocument.h"
#import "NSString+ParseCSV.h"

@implementation CPTPlotDocument

//#define USE_NSDECIMAL

-(id)init
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

-(void)dealloc
{
    [graph release];
    [dataPoints release];
    [zoomAnnotation release];
    [super dealloc];
}

-(NSString *)windowNibName
{
    return @"CPTPlotDocument";
}

-(void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    // Create graph from theme
    graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme *theme = [CPTTheme themeNamed:kCPTDarkGradientTheme];
    [graph applyTheme:theme];
    graphView.hostedGraph = graph;

    graph.paddingLeft   = 0.0;
    graph.paddingTop    = 0.0;
    graph.paddingRight  = 0.0;
    graph.paddingBottom = 0.0;

    graph.plotAreaFrame.paddingLeft   = 55.0;
    graph.plotAreaFrame.paddingTop    = 40.0;
    graph.plotAreaFrame.paddingRight  = 40.0;
    graph.plotAreaFrame.paddingBottom = 35.0;

    graph.plotAreaFrame.plotArea.fill = graph.plotAreaFrame.fill;
    graph.plotAreaFrame.fill          = nil;

    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.cornerRadius    = 0.0;
    graph.plotAreaFrame.masksToBorder   = NO;

    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];

    // this allows the plot to respond to mouse events
    [plotSpace setDelegate:self];
    [plotSpace setAllowsUserInteraction:YES];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;

    CPTXYAxis *x = axisSet.xAxis;
    x.minorTicksPerInterval = 9;
    x.majorIntervalLength   = CPTDecimalFromDouble(majorIntervalLengthForX);
    x.labelOffset           = 5.0;
    x.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];

    CPTXYAxis *y = axisSet.yAxis;
    y.minorTicksPerInterval = 9;
    y.majorIntervalLength   = CPTDecimalFromDouble(majorIntervalLengthForY);
    y.labelOffset           = 5.0;
    y.axisConstraints       = [CPTConstraints constraintWithLowerOffset:0.0];

    // Create the main plot for the delimited data
    CPTScatterPlot *dataSourceLinePlot = [[[CPTScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";

    CPTMutableLineStyle *lineStyle = [[dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth              = 1.0;
    lineStyle.lineColor              = [CPTColor whiteColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
}

#pragma mark -
#pragma mark Data loading methods

-(NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

-(BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    if ( [typeName isEqualToString:@"CSVDocument"] ) {
        minimumValueForXAxis = MAXFLOAT;
        maximumValueForXAxis = -MAXFLOAT;

        minimumValueForYAxis = MAXFLOAT;
        maximumValueForYAxis = -MAXFLOAT;

        NSString *fileContents = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        // Parse CSV
        NSUInteger length    = [fileContents length];
        NSUInteger lineStart = 0, lineEnd = 0, contentsEnd = 0;
        NSRange currentRange;

        // Read headers from the first line of the file
        [fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
//		currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
//		NSArray *columnHeaders = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];
//		NSLog([columnHeaders objectAtIndex:0]);

        while ( lineEnd < length ) {
            [fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
            currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
            NSArray *columnValues = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];

            double xValue = [columnValues[0] doubleValue];
            double yValue = [columnValues[1] doubleValue];
            if ( xValue < minimumValueForXAxis ) {
                minimumValueForXAxis = xValue;
            }
            if ( xValue > maximumValueForXAxis ) {
                maximumValueForXAxis = xValue;
            }
            if ( yValue < minimumValueForYAxis ) {
                minimumValueForYAxis = yValue;
            }
            if ( yValue > maximumValueForYAxis ) {
                maximumValueForYAxis = yValue;
            }

#ifdef USE_NSDECIMAL
            [dataPoints addObject:@{ @"x": [NSDecimalNumber decimalNumberWithString:columnValues[0]], @"y": [NSDecimalNumber decimalNumberWithString:columnValues[1]] }
            ];
#else
            [dataPoints addObject:@{ @"x": @(xValue), @"y": @(yValue) }
            ];
#endif
            // Create a dictionary of the items, keyed to the header titles
//			NSDictionary *keyedImportedItems = [[NSDictionary alloc] initWithObjects:columnValues forKeys:columnHeaders];
            // Process this
        }

        majorIntervalLengthForX = (maximumValueForXAxis - minimumValueForXAxis) / 5.0;
        if ( majorIntervalLengthForX > 0.0 ) {
            majorIntervalLengthForX = pow( 10.0, ceil( log10(majorIntervalLengthForX) ) );
        }

        majorIntervalLengthForY = (maximumValueForYAxis - minimumValueForYAxis) / 10.0;
        if ( majorIntervalLengthForY > 0.0 ) {
            majorIntervalLengthForY = pow( 10.0, ceil( log10(majorIntervalLengthForY) ) );
        }

        minimumValueForXAxis = floor(minimumValueForXAxis / majorIntervalLengthForX) * majorIntervalLengthForX;
        minimumValueForYAxis = floor(minimumValueForYAxis / majorIntervalLengthForY) * majorIntervalLengthForY;

        [fileContents release];
    }

    if ( outError != NULL ) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}

#pragma mark -
#pragma mark Zoom Methods

-(IBAction)zoomIn
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    CPTPlotArea *plotArea     = graph.plotAreaFrame.plotArea;

    // convert the dragStart and dragEnd values to plot coordinates
    CGPoint dragStartInPlotArea = [graph convertPoint:dragStart toLayer:plotArea];
    CGPoint dragEndInPlotArea   = [graph convertPoint:dragEnd toLayer:plotArea];

    double start[2], end[2];

    // obtain the datapoints for the drag start and end
    [plotSpace doublePrecisionPlotPoint:start numberOfCoordinates:2 forPlotAreaViewPoint:dragStartInPlotArea];
    [plotSpace doublePrecisionPlotPoint:end numberOfCoordinates:2 forPlotAreaViewPoint:dragEndInPlotArea];

    // recalculate the min and max values
    minimumValueForXAxis = MIN(start[CPTCoordinateX], end[CPTCoordinateX]);
    maximumValueForXAxis = MAX(start[CPTCoordinateX], end[CPTCoordinateX]);
    minimumValueForYAxis = MIN(start[CPTCoordinateY], end[CPTCoordinateY]);
    maximumValueForYAxis = MAX(start[CPTCoordinateY], end[CPTCoordinateY]);

    // now adjust the plot range and axes
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
                                                    length:CPTDecimalFromDouble(maximumValueForXAxis - minimumValueForXAxis)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
                                                    length:CPTDecimalFromDouble(maximumValueForYAxis - minimumValueForYAxis)];

    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
}

-(IBAction)zoomOut
{
    double xval, yval;

    minimumValueForXAxis = MAXFLOAT;
    maximumValueForXAxis = -MAXFLOAT;

    minimumValueForYAxis = MAXFLOAT;
    maximumValueForYAxis = -MAXFLOAT;

    // get the ful range min and max values
    for ( NSDictionary *xyValues in dataPoints ) {
        xval = [xyValues[@"x"] doubleValue];

        minimumValueForXAxis = fmin(xval, minimumValueForXAxis);
        maximumValueForXAxis = fmax(xval, maximumValueForXAxis);

        yval = [xyValues[@"y"] doubleValue];

        minimumValueForYAxis = fmin(yval, minimumValueForYAxis);
        maximumValueForYAxis = fmax(yval, maximumValueForYAxis);
    }

    minimumValueForXAxis = floor(minimumValueForXAxis / majorIntervalLengthForX) * majorIntervalLengthForX;
    minimumValueForYAxis = floor(minimumValueForYAxis / majorIntervalLengthForY) * majorIntervalLengthForY;

    // now adjust the plot range and axes
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;

    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForXAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForXAxis - minimumValueForXAxis) / majorIntervalLengthForX ) * majorIntervalLengthForX)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minimumValueForYAxis)
                                                    length:CPTDecimalFromDouble(ceil( (maximumValueForYAxis - minimumValueForYAxis) / majorIntervalLengthForY ) * majorIntervalLengthForY)];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
}

#pragma mark -
#pragma mark PDF / image export

-(IBAction)exportToPDF:(id)sender;
{
    NSSavePanel *pdfSavingDialog = [NSSavePanel savePanel];
    [pdfSavingDialog setAllowedFileTypes:@[@"pdf"]];

    if ( [pdfSavingDialog runModal] == NSOKButton ) {
        NSData *dataForPDF = [graph dataForPDFRepresentationOfLayer];
        [dataForPDF writeToURL:[pdfSavingDialog URL] atomically:NO];
    }
}

-(IBAction)exportToPNG:(id)sender;
{
    NSSavePanel *pngSavingDialog = [NSSavePanel savePanel];
    [pngSavingDialog setAllowedFileTypes:@[@"png"]];

    if ( [pngSavingDialog runModal] == NSOKButton ) {
        NSImage *image            = [graph imageOfLayer];
        NSData *tiffData          = [image TIFFRepresentation];
        NSBitmapImageRep *tiffRep = [NSBitmapImageRep imageRepWithData:tiffData];
        NSData *pngData           = [tiffRep representationUsingType:NSPNGFileType properties:nil];
        [pngData writeToURL:[pngSavingDialog URL] atomically:NO];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [dataPoints count];
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber *num = dataPoints[index][key];

    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    if ( zoomAnnotation ) {
        CPTPlotArea *plotArea = graph.plotAreaFrame.plotArea;
        CGRect plotBounds     = plotArea.bounds;

        // convert the dragStart and dragEnd values to plot coordinates
        CGPoint dragStartInPlotArea = [graph convertPoint:dragStart toLayer:plotArea];
        CGPoint dragEndInPlotArea   = [graph convertPoint:interactionPoint toLayer:plotArea];

        // create the dragrect from dragStart to the current location
        CGFloat endX      = MAX( MIN( dragEndInPlotArea.x, CGRectGetMaxX(plotBounds) ), CGRectGetMinX(plotBounds) );
        CGFloat endY      = MAX( MIN( dragEndInPlotArea.y, CGRectGetMaxY(plotBounds) ), CGRectGetMinY(plotBounds) );
        CGRect borderRect = CGRectMake( dragStartInPlotArea.x, dragStartInPlotArea.y,
                                        (endX - dragStartInPlotArea.x),
                                        (endY - dragStartInPlotArea.y) );

        zoomAnnotation.contentAnchorPoint = CGPointMake(dragEndInPlotArea.x >= dragStartInPlotArea.x ? 0.0 : 1.0,
                                                        dragEndInPlotArea.y >= dragStartInPlotArea.y ? 0.0 : 1.0);
        zoomAnnotation.contentLayer.frame = borderRect;
    }

    return NO;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    if ( !zoomAnnotation ) {
        dragStart = interactionPoint;

        CPTPlotArea *plotArea       = graph.plotAreaFrame.plotArea;
        CGPoint dragStartInPlotArea = [graph convertPoint:dragStart toLayer:plotArea];

        if ( CGRectContainsPoint(plotArea.bounds, dragStartInPlotArea) ) {
            // create the zoom rectangle
            // first a bordered layer to draw the zoomrect
            CPTBorderedLayer *zoomRectangleLayer = [[[CPTBorderedLayer alloc] initWithFrame:CGRectNull] autorelease];

            CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
            lineStyle.lineColor                = [CPTColor darkGrayColor];
            lineStyle.lineWidth                = 1.0;
            zoomRectangleLayer.borderLineStyle = lineStyle;

            CPTColor *transparentFillColor = [[CPTColor blueColor] colorWithAlphaComponent:0.2];
            zoomRectangleLayer.fill = [CPTFill fillWithColor:transparentFillColor];

            double start[2];
            [graph.defaultPlotSpace doublePrecisionPlotPoint:start numberOfCoordinates:2 forPlotAreaViewPoint:dragStartInPlotArea];
            NSArray *anchorPoint = @[@(start[CPTCoordinateX]),
                                     @(start[CPTCoordinateY])];

// now create the annotation
            zoomAnnotation              = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:graph.defaultPlotSpace anchorPlotPoint:anchorPoint];
            zoomAnnotation.contentLayer = zoomRectangleLayer;

            [graph.plotAreaFrame.plotArea addAnnotation:zoomAnnotation];
        }
    }

    return NO;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    if ( zoomAnnotation ) {
        dragEnd = interactionPoint;

// double-click to completely zoom out
        if ( [event clickCount] == 2 ) {
            CPTPlotArea *plotArea     = graph.plotAreaFrame.plotArea;
            CGPoint dragEndInPlotArea = [graph convertPoint:interactionPoint toLayer:plotArea];

            if ( CGRectContainsPoint(plotArea.bounds, dragEndInPlotArea) ) {
                [self zoomOut];
            }
        }
        else if ( !CGPointEqualToPoint(dragStart, dragEnd) ) {
// no accidental drag, so zoom in
            [self zoomIn];
        }

// and we're done with the drag
        [graph.plotAreaFrame.plotArea removeAnnotation:zoomAnnotation];
        [zoomAnnotation release];
        zoomAnnotation = nil;

        dragStart = CGPointZero;
        dragEnd   = CGPointZero;
    }

    return NO;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(id)event atPoint:(CGPoint)interactionPoint
{
    if ( zoomAnnotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:zoomAnnotation];
        [zoomAnnotation release];
        zoomAnnotation = nil;

        dragStart = CGPointZero;
        dragEnd   = CGPointZero;
    }

    return NO;
}

@end
