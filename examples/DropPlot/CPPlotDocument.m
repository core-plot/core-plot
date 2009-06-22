#import "CPPlotDocument.h"
#import "NSString+ParseCSV.h"

@implementation CPPlotDocument

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
	CPTheme *theme = [CPTheme themeNamed:kCPDarkGradientTheme];
	graph = [theme newGraph];
	graphView.hostedLayer = graph;
    
    // Setup plot space
    CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForXAxis) length:CPDecimalFromFloat(maximumValueForXAxis)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(minimumValueForYAxis) length:CPDecimalFromFloat(maximumValueForYAxis)];
	
    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    
    CPXYAxis *x = axisSet.xAxis;
    x.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", majorIntervalLengthForX]];
//    x.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
    x.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"2"];
    x.minorTicksPerInterval = 2;
//	NSArray *exclusionRanges = [NSArray arrayWithObjects:
//								[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
//								[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
//								[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(2.99) length:CPDecimalFromFloat(0.02)],
//								nil];
//	x.labelExclusionRanges = exclusionRanges;
	
    CPXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", majorIntervalLengthForY]];
//    y.majorIntervalLength = [NSDecimalNumber decimalNumberWithString:@"0.5"];
    y.minorTicksPerInterval = 5;
    y.constantCoordinateValue = [NSDecimalNumber decimalNumberWithString:@"2"];
//	exclusionRanges = [NSArray arrayWithObjects:
//					   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.99) length:CPDecimalFromFloat(0.02)], 
//					   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0.99) length:CPDecimalFromFloat(0.02)],
//					   [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(3.99) length:CPDecimalFromFloat(0.02)],
//					   nil];
//	y.labelExclusionRanges = exclusionRanges;
	
	NSLog(@"X range: %f, Y range: %f", [plotSpace.xRange.length doubleValue], [plotSpace.yRange.length doubleValue]);
	
//	// Add plot symbols
//	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
//	CGColorRef greenColor = CPNewCGColorFromNSColor([NSColor greenColor]);
//	greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:greenColor]];
//    greenCirclePlotSymbol.size = CGSizeMake(10.0, 10.0);
//    boundLinePlot.defaultPlotSymbol = greenCirclePlotSymbol;
//	CGColorRelease(greenColor);
    
    // Create a second plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
	
	[graph reloadData];
		
//    // Add some initial data
//	NSDecimalNumber *x1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
//	NSDecimalNumber *x2 = [NSDecimalNumber decimalNumberWithString:@"1.7"];
//	NSDecimalNumber *x3 = [NSDecimalNumber decimalNumberWithString:@"2.8"];
//	NSDecimalNumber *y1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
//	NSDecimalNumber *y2 = [NSDecimalNumber decimalNumberWithString:@"2.3"];
//	NSDecimalNumber *y3 = [NSDecimalNumber decimalNumberWithString:@"2"];
//    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:
//									[NSMutableDictionary dictionaryWithObjectsAndKeys:x1, @"x", y1, @"y", nil],
//									[NSMutableDictionary dictionaryWithObjectsAndKeys:x2, @"x", y2, @"y", nil],
//									[NSMutableDictionary dictionaryWithObjectsAndKeys:x3, @"x", y3, @"y", nil],
//									nil];
//	self.content = contentArray;
}

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
			
			
			[dataPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDecimalNumber decimalNumberWithString:[columnValues objectAtIndex:0]], @"x", [NSDecimalNumber decimalNumberWithString:[columnValues objectAtIndex:0]], @"y", nil]];
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
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return [dataPoints count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [[dataPoints objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if ( fieldEnum == CPScatterPlotFieldY ) num = [num decimalNumberByAdding:[NSDecimalNumber one]];
    return num;
}

@end
