
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

    // Axes
	CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    
    CPLineStyle *majorLineStyle = [CPLineStyle lineStyle];
    majorLineStyle.lineCap = kCGLineCapRound;
    majorLineStyle.lineColor = [CPColor blueColor];
    majorLineStyle.lineWidth = 2.0f;
    
    CPLineStyle *minorLineStyle = [CPLineStyle lineStyle];
    minorLineStyle.lineColor = [CPColor redColor];
    minorLineStyle.lineWidth = 2.0f;

    axisSet.xAxis.majorIntervalLength = (NSDecimalNumber *)[NSDecimalNumber numberWithFloat:0.1];
    axisSet.xAxis.constantCoordinateValue = CPDecimalFromInt(1);
    axisSet.xAxis.minorTicksPerInterval = 2;
    axisSet.xAxis.majorTickLineStyle = majorLineStyle;
    axisSet.xAxis.minorTickLineStyle = minorLineStyle;
    axisSet.xAxis.axisLineStyle = majorLineStyle;
    axisSet.xAxis.minorTickLength = 7.0f;

    axisSet.yAxis.majorIntervalLength = (NSDecimalNumber *)[NSDecimalNumber numberWithFloat:0.5];
    axisSet.yAxis.minorTicksPerInterval = 5;
    axisSet.yAxis.constantCoordinateValue = CPDecimalFromInt(1);
    axisSet.yAxis.majorTickLineStyle = majorLineStyle;
    axisSet.yAxis.minorTickLineStyle = minorLineStyle;
    axisSet.yAxis.axisLineStyle = majorLineStyle;
    axisSet.yAxis.minorTickLength = 7.0f;

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

#pragma mark -
#pragma mark Layer exploding for illustration

#define ZDISTANCEBETWEENLAYERS 20.0f
-(IBAction)explodeLayers:(id)sender;
{
	CATransform3D perspectiveRotation = CATransform3DMakeRotation(-40.0 * M_PI / 180.0, 0.0, 1.0, 0.0);
	
	perspectiveRotation = CATransform3DRotate(perspectiveRotation, -55.0 * M_PI / 180.0, perspectiveRotation.m11, perspectiveRotation.m21, perspectiveRotation.m31);
	
	perspectiveRotation = CATransform3DScale(perspectiveRotation, 0.7, 0.7, 0.7);
	hostView.layer.masksToBounds = NO;
	
	overlayRotationView = [[RotationView alloc] initWithFrame:hostView.frame];
	overlayRotationView.rotationDelegate = self;
	overlayRotationView.rotationTransform = perspectiveRotation;
	[[hostView superview] addSubview:overlayRotationView positioned:NSWindowAbove relativeTo:hostView];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:1.0f] forKey:kCATransactionAnimationDuration];		

	[Controller recursivelySplitSublayersInZForLayer:graph depthLevel:0];
	graph.transform = perspectiveRotation;

	[CATransaction commit];
}

+(void)recursivelySplitSublayersInZForLayer:(CALayer *)layer depthLevel:(unsigned int)depthLevel;
{
	layer.zPosition = ZDISTANCEBETWEENLAYERS * (CGFloat)depthLevel;
	depthLevel++;
	for (CALayer *currentLayer in layer.sublayers) {
		[Controller recursivelySplitSublayersInZForLayer:currentLayer depthLevel:depthLevel];
	}
}

-(IBAction)reassembleLayers:(id)sender;
{
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:1.0f] forKey:kCATransactionAnimationDuration];		
	
	[Controller recursivelyAssembleSublayersInZForLayer:graph];
	graph.transform = CATransform3DIdentity;

	[CATransaction commit];
	
	[overlayRotationView removeFromSuperview];
	[overlayRotationView release];
	overlayRotationView = nil;
}

+(void)recursivelyAssembleSublayersInZForLayer:(CALayer *)layer;
{
	layer.zPosition = 0.0;
	for (CALayer *currentLayer in layer.sublayers) {
		[Controller recursivelyAssembleSublayersInZForLayer:currentLayer];
	}
}

#pragma mark -
#pragma mark CPRotationDelegate delegate method

- (void)rotateObjectUsingTransform:(CATransform3D)rotationTransform;
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];	

	graph.transform = rotationTransform;
	
	[CATransaction commit];
}

@end
