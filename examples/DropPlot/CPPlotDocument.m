#import "CPPlotDocument.h"
#import "NSString+ParseCSV.h"

@implementation CPPlotDocument

//#define USE_NSDECIMAL

+(void)initialize {
    [NSValueTransformer setValueTransformer:[CPDecimalNumberValueTransformer new] forName:@"CPDecimalNumberValueTransformer"];
}

- (id)init
{
    self = [super init];
    if (self) {
    	dataPoints = [[NSMutableArray alloc] init];

    }
    return self;
}

-(void)dealloc
{
	[graph release];
	[dataPoints release];
	[super dealloc];
}

- (NSString *)windowNibName
{
    return @"CPPlotDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    // Create graph from theme
    graph = [[CPXYGraph alloc] initWithFrame:CGRectZero];
	CPTheme *theme = [CPTheme themeNamed:kCPPlainWhiteTheme];
	[graph applyTheme:theme]; 
	graphView.hostedLayer = graph;
	
	graph.paddingTop = 40.0;
	graph.paddingRight = 40.0;
	graph.paddingBottom = 40.0;

    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForXAxis) length:CPDecimalFromFloat(maximumValueForXAxis - minimumValueForXAxis)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForYAxis) length:CPDecimalFromFloat(maximumValueForYAxis - minimumValueForYAxis)];

	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
	CPXYAxis *x = axisSet.xAxis;
	x.majorIntervalLength = CPDecimalFromDouble(majorIntervalLengthForX);
	x.constantCoordinateValue = CPDecimalFromDouble(minimumValueForYAxis);
	x.minorTicksPerInterval = 5;
	
	CPXYAxis *y = axisSet.yAxis;
	y.majorIntervalLength = CPDecimalFromDouble(majorIntervalLengthForY);
	y.minorTicksPerInterval = 5;
	y.constantCoordinateValue = CPDecimalFromDouble(minimumValueForXAxis);
	
		CPLineStyle *borderLineStyle = [CPLineStyle lineStyle];
    borderLineStyle.lineColor = [CPColor colorWithGenericGray:0.2];
    borderLineStyle.lineWidth = 0.0f;
	
//	CPBorderedLayer *borderedLayer = (CPBorderedLayer *)axisSet.overlayLayer;
//	borderedLayer.borderLineStyle = borderLineStyle;
//	borderedLayer.cornerRadius = 0.0f;

    // Create the main plot for the delimited data
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor blackColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];

	// Add plot symbols
//	CPLineStyle *symbolLineStyle = [CPLineStyle lineStyle];
//	symbolLineStyle.lineColor = [CPColor whiteColor];
//	CPPlotSymbol *plotSymbol = [CPPlotSymbol ellipsePlotSymbol];
//	plotSymbol.fill = [CPFill fillWithColor:[CPColor blueColor]];
//	plotSymbol.lineStyle = symbolLineStyle;
//    plotSymbol.size = CGSizeMake(10.0, 10.0);
//    dataSourceLinePlot.plotSymbol = plotSymbol;

	[graph reloadData];
}

#pragma mark -
#pragma mark Data loading methods

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	if ([typeName isEqualToString:@"CSVDocument"]) {
		
		minimumValueForXAxis = MAXFLOAT;
		maximumValueForXAxis = -MAXFLOAT;
		
		minimumValueForYAxis = MAXFLOAT;
		maximumValueForYAxis = -MAXFLOAT;

		NSString *fileContents = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		// Parse CSV
		NSUInteger length = [fileContents length];
		NSUInteger lineStart = 0, lineEnd = 0, contentsEnd = 0;
		NSRange currentRange;
		
		// Read headers from the first line of the file
		[fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
		currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
//		NSArray *columnHeaders = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];
//		NSLog([columnHeaders objectAtIndex:0]);
		
		while (lineEnd < length) {
			[fileContents getParagraphStart:&lineStart end:&lineEnd contentsEnd:&contentsEnd forRange:NSMakeRange(lineEnd, 0)];
			currentRange = NSMakeRange(lineStart, contentsEnd - lineStart);
			NSArray *columnValues = [[fileContents substringWithRange:currentRange] arrayByParsingCSVLine];
			
			double xValue = [[columnValues objectAtIndex:0] doubleValue];
			double yValue = [[columnValues objectAtIndex:1] doubleValue];
			if (xValue < minimumValueForXAxis)
				minimumValueForXAxis = xValue;
			if (xValue > maximumValueForXAxis)
				maximumValueForXAxis = xValue;
			if (yValue < minimumValueForYAxis)
				minimumValueForYAxis = yValue;
			if (yValue > maximumValueForYAxis)
				maximumValueForYAxis = yValue;
			
#ifdef USE_NSDECIMAL			
			[dataPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDecimalNumber decimalNumberWithString:[columnValues objectAtIndex:0]], @"x", [NSDecimalNumber decimalNumberWithString:[columnValues objectAtIndex:1]], @"y", nil]];
#else
			[dataPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:xValue], @"x", [NSNumber numberWithDouble:yValue], @"y", nil]];
#endif
			// Create a dictionary of the items, keyed to the header titles
//			NSDictionary *keyedImportedItems = [[NSDictionary alloc] initWithObjects:columnValues forKeys:columnHeaders];
			// Process this
		}
		
		majorIntervalLengthForX = (maximumValueForXAxis - minimumValueForXAxis) / 10.0;
		majorIntervalLengthForY = (maximumValueForYAxis - minimumValueForYAxis) / 10.0;
		
		[fileContents release];
	}

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

#pragma mark -
#pragma mark PDF / image export

-(IBAction)exportToPDF:(id)sender;
{
	NSSavePanel *pdfSavingDialog = [NSSavePanel savePanel];
	[pdfSavingDialog setRequiredFileType:@"pdf"];
	
	if ( [pdfSavingDialog runModalForDirectory:nil file:nil] == NSOKButton )
	{
		NSData *dataForPDF = [graph dataForPDFRepresentationOfLayer];
		[dataForPDF writeToFile:[pdfSavingDialog filename] atomically:NO];
	}		
}

-(IBAction)exportToPNG:(id)sender;
{
	NSSavePanel *pngSavingDialog = [NSSavePanel savePanel];
	[pngSavingDialog setRequiredFileType:@"png"];
	
	if ( [pngSavingDialog runModalForDirectory:nil file:nil] == NSOKButton )
	{
		NSImage *image = [graph imageOfLayer];
        NSData *tiffData = [image TIFFRepresentation];
        NSBitmapImageRep *tiffRep = [NSBitmapImageRep imageRepWithData:tiffData];
        NSData *pngData = [tiffRep representationUsingType:NSPNGFileType properties:nil];
		[pngData writeToFile:[pngSavingDialog filename] atomically:NO];
	}		
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    return [dataPoints count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
#ifdef USE_NSDECIMAL
    NSDecimalNumber *num = [[dataPoints objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
#else
    NSNumber *num = [[dataPoints objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
#endif
    return num;
}

@end
