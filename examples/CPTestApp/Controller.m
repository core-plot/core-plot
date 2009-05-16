
#import "Controller.h"
#import <CorePlot/CorePlot.h>

@implementation Controller

+(void)initialize {
    [NSValueTransformer setValueTransformer:[CPDecimalNumberValueTransformer new] forName:@"CPDecimalNumberValueTransformer"];
}

-(void)dealloc 
{
    [graph release];
    [super dealloc];
}

-(void)awakeFromNib {
    [super awakeFromNib];

    // Create graph
    graph = [[CPXYGraph alloc] init];
	graph.frame = NSRectToCGRect(hostView.bounds);
	CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
	graph.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
		
	grayColor = CGColorCreateGenericGray(0.2, 0.3);
	graph.plotArea.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
	
    [hostView setLayer:graph];
	[hostView setWantsLayer:YES];
    
    // Setup plot space
    CPCartesianPlotSpace *plotSpace = (CPCartesianPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];
    plotSpace.yRange = [CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(1.0) length:CPDecimalFromFloat(2.0)];

	CPXYAxisSet* axisSet = [[CPXYAxisSet alloc] init];
	
	[[axisSet xAxis] setMajorTickLocations:[NSArray arrayWithObjects:[NSDecimalNumber decimalNumberWithString:@"1.0"], [NSDecimalNumber decimalNumberWithString:@"2.0"], [NSDecimalNumber decimalNumberWithString:@"3.0"], nil]];
    [[axisSet yAxis] setMajorTickLocations:[NSArray arrayWithObjects:[NSDecimalNumber decimalNumberWithString:@"1.0"], [NSDecimalNumber decimalNumberWithString:@"2.0"], [NSDecimalNumber decimalNumberWithString:@"3.0"], nil]];
	[axisSet.xAxis setPlotSpace:plotSpace];
	[axisSet.yAxis setPlotSpace:plotSpace];
	[axisSet.xAxis setRange:plotSpace.xRange];
	[axisSet.yAxis setRange:plotSpace.yRange];
	[(CPLinearAxis*)axisSet.xAxis setConstantCoordinateValue:[plotSpace.yRange.location decimalValue]];
	[(CPLinearAxis*)axisSet.yAxis setConstantCoordinateValue:[plotSpace.xRange.location decimalValue]];
	[axisSet setBounds:plotSpace.frame];
	[plotSpace addSublayer:axisSet];
	
    // Create one plot that uses bindings
	CPScatterPlot *boundLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    boundLinePlot.identifier = @"Bindings Plot";
	boundLinePlot.dataLineStyle.lineWidth = 2.f;
    [graph addPlot:boundLinePlot];
	[boundLinePlot bind:CPScatterPlotBindingXValues toObject:self withKeyPath:@"arrangedObjects.x" options:nil];
	[boundLinePlot bind:CPScatterPlotBindingYValues toObject:self withKeyPath:@"arrangedObjects.y" options:nil];
    
	// Add plot symbols
	CPPlotSymbol *greenCirclePlotSymbol = [CPPlotSymbol ellipsePlotSymbol];
	CGColorRef greenColor = CPNewCGColorFromNSColor([NSColor greenColor]);
	greenCirclePlotSymbol.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:greenColor]];
    greenCirclePlotSymbol.size = CGSizeMake(10.0, 10.0);
    boundLinePlot.defaultPlotSymbol = greenCirclePlotSymbol;
	CGColorRelease(greenColor);
    
    // Create a second plot that uses the data source method
	CPScatterPlot *dataSourceLinePlot = [[[CPScatterPlot alloc] init] autorelease];
    dataSourceLinePlot.identifier = @"Data Source Plot";
	dataSourceLinePlot.dataLineStyle.lineWidth = 1.f;
    dataSourceLinePlot.dataLineStyle.lineColor = [CPColor redColor];
    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
	
    // Add some initial data
	NSDecimalNumber *x1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber *x2 = [NSDecimalNumber decimalNumberWithString:@"1.7"];
	NSDecimalNumber *x3 = [NSDecimalNumber decimalNumberWithString:@"2.8"];
	NSDecimalNumber *y1 = [NSDecimalNumber decimalNumberWithString:@"1.3"];
	NSDecimalNumber *y2 = [NSDecimalNumber decimalNumberWithString:@"2.3"];
	NSDecimalNumber *y3 = [NSDecimalNumber decimalNumberWithString:@"2"];
    NSMutableArray *contentArray = [NSMutableArray arrayWithObjects:
        [NSMutableDictionary dictionaryWithObjectsAndKeys:x1, @"x", y1, @"y", nil],
        [NSMutableDictionary dictionaryWithObjectsAndKeys:x2, @"x", y2, @"y", nil],
        [NSMutableDictionary dictionaryWithObjectsAndKeys:x3, @"x", y3, @"y", nil],
        nil];
	self.content = contentArray;
}

-(id)newObject 
{
	NSDecimalNumber *x1 = [NSDecimalNumber decimalNumberWithString:@"1.0"];
	NSDecimalNumber *y1 = [NSDecimalNumber decimalNumberWithString:@"1.0"];
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:x1, @"x", y1, @"y", nil];
}

#pragma mark -
#pragma mark Actions

-(IBAction)reloadDataSourcePlot:(id)sender {
    CPPlot *plot = [graph plotWithIdentifier:@"Data Source Plot"];
    [plot reloadData];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecords {
    return [self.arrangedObjects count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [[self.arrangedObjects objectAtIndex:index] valueForKey:(fieldEnum == CPScatterPlotFieldX ? @"x" : @"y")];
    if ( fieldEnum == CPScatterPlotFieldY ) num = [num decimalNumberByAdding:[NSDecimalNumber one]];
    return num;
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

@end
