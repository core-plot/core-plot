#import "CPTScatterPlotPlugIn.h"

@implementation CPTScatterPlotPlugIn

/*
 NOTE: It seems that QC plugins don't inherit dynamic input ports which is
 why all of the accessor declarations are duplicated here
*/

/* 
 Accessor for the output image
*/
@dynamic outputImage;

/*
 Dynamic accessors for the static PlugIn inputs
*/
@dynamic inputPixelsWide, inputPixelsHigh;
@dynamic inputPlotAreaColor;
@dynamic inputAxisColor, inputAxisLineWidth, inputAxisMinorTickWidth, inputAxisMajorTickWidth, inputAxisMajorTickLength, inputAxisMinorTickLength;
@dynamic inputMajorGridLineWidth, inputMinorGridLineWidth;
@dynamic inputXMin, inputXMax, inputYMin, inputYMax;
@dynamic inputXMajorIntervals, inputYMajorIntervals, inputXMinorIntervals, inputYMinorIntervals;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"Core Plot Scatter Plot", QCPTlugInAttributeNameKey, 
			@"Scatter plot", QCPTlugInAttributeDescriptionKey, 
			nil];
}

- (void) addPlotWithIndex:(NSUInteger)index
{
	// Create input ports for the new plot
	
	[self addInputPortWithType:QCPTortTypeStructure
						forKey:[NSString stringWithFormat:@"plotXNumbers%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"X Values %i", index+1], QCPTortAttributeNameKey,
								QCPTortTypeStructure, QCPTortAttributeTypeKey,
								nil]];
	
	[self addInputPortWithType:QCPTortTypeStructure
						forKey:[NSString stringWithFormat:@"plotYNumbers%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Y Values %i", index+1], QCPTortAttributeNameKey,
								QCPTortTypeStructure, QCPTortAttributeTypeKey,
								nil]];
	
	[self addInputPortWithType:QCPTortTypeColor
						forKey:[NSString stringWithFormat:@"plotDataLineColor%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Plot Line Color %i", index+1], QCPTortAttributeNameKey,
								QCPTortTypeColor, QCPTortAttributeTypeKey,
								[self defaultColorForPlot:index alpha:1.0], QCPTortAttributeDefaultValueKey,
								nil]];
	
	[self addInputPortWithType:QCPTortTypeColor
						forKey:[NSString stringWithFormat:@"plotFillColor%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Plot Fill Color %i", index+1], QCPTortAttributeNameKey,
								QCPTortTypeColor, QCPTortAttributeTypeKey,
								[self defaultColorForPlot:index alpha:0.25], QCPTortAttributeDefaultValueKey,
								nil]];
		
	[self addInputPortWithType:QCPTortTypeNumber
						forKey:[NSString stringWithFormat:@"plotDataLineWidth%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Plot Line Width %i", index+1], QCPTortAttributeNameKey,
								QCPTortTypeNumber, QCPTortAttributeTypeKey,
								[NSNumber numberWithInt:1.0], QCPTortAttributeDefaultValueKey,
								[NSNumber numberWithFloat:0.0], QCPTortAttributeMinimumValueKey,
								nil]];
	
	[self addInputPortWithType:QCPTortTypeIndex
						forKey:[NSString stringWithFormat:@"plotDataSymbols%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Data Symbols %i", index+1], QCPTortAttributeNameKey,
								QCPTortTypeIndex, QCPTortAttributeTypeKey,
								[NSArray arrayWithObjects:@"Empty", @"Circle", @"Triangle", @"Square", @"Plus", @"Star", @"Diamond", @"Pentagon", @"Hexagon", @"Dash", @"Snow", nil], QCPTortAttributeMenuItemsKey,								
								[NSNumber numberWithInt:0], QCPTortAttributeDefaultValueKey,
								[NSNumber numberWithInt:0], QCPTortAttributeMinimumValueKey,
								[NSNumber numberWithInt:10], QCPTortAttributeMaximumValueKey,
								nil]];	
	
	[self addInputPortWithType:QCPTortTypeColor
						forKey:[NSString stringWithFormat:@"plotDataSymbolColor%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Data Symbol Color %i", index+1], QCPTortAttributeNameKey,
								QCPTortTypeColor, QCPTortAttributeTypeKey,
								[self defaultColorForPlot:index alpha:0.25], QCPTortAttributeDefaultValueKey,
								nil]];
	
	// Add the new plot to the graph
	CPTScatterPlot *scatterPlot = [[[CPTScatterPlot alloc] init] autorelease];
	scatterPlot.identifier = [NSString stringWithFormat:@"Data Source Plot %i", index+1];
    
    // Line Style
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 3.f;
    lineStyle.lineColor = [CPTColor colorWithCGColor:[self defaultColorForPlot:index alpha:1.0]];
    scatterPlot.dataLineStyle = lineStyle;
	scatterPlot.areaFill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[self defaultColorForPlot:index alpha:0.25]]];
	scatterPlot.dataSource = self;
	[graph addPlot:scatterPlot];			
}

- (void) removePlots:(NSUInteger)count
{
	// Clean up a deleted plot
	
	for (int i = numberOfPlots; i > numberOfPlots-count; i--)
	{
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotXNumbers%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotYNumbers%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineColor%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotFillColor%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineWidth%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataSymbols%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataSymbolColor%i", i-1]];
		
		[graph removePlot:[[graph allPlots] lastObject]];		
	}
}

- (CPTPlotSymbol *) plotSymbol:(NSUInteger)index
{
	NSString *key = [NSString stringWithFormat:@"plotDataSymbols%i", index];
	NSUInteger value = [[self valueForInputKey:key] unsignedIntValue];

	switch (value) {
		case 1:
			return [CPTPlotSymbol ellipsePlotSymbol];
		case 2:
			return [CPTPlotSymbol trianglePlotSymbol];
		case 3:
			return [CPTPlotSymbol rectanglePlotSymbol];
		case 4:
			return [CPTPlotSymbol plusPlotSymbol];
		case 5:
			return [CPTPlotSymbol starPlotSymbol];
		case 6:
			return [CPTPlotSymbol diamondPlotSymbol];
		case 7:
			return [CPTPlotSymbol pentagonPlotSymbol];
		case 8:
			return [CPTPlotSymbol hexagonPlotSymbol];
		case 9:
			return [CPTPlotSymbol dashPlotSymbol];
		case 10:
			return [CPTPlotSymbol snowPlotSymbol];
		default:
			return nil;
	}
}

- (CGColorRef) dataSymbolColor:(NSUInteger)index
{
	NSString *key = [NSString stringWithFormat:@"plotDataSymbolColor%i", index];
	return (CGColorRef)[self valueForInputKey:key];
}

- (BOOL) configurePlots
{
	// Adjust the plots configuration using the QC input ports

	for (CPTScatterPlot* plot in [graph allPlots])
	{		
		int index = [[graph allPlots] indexOfObject:plot];
		
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineColor = [CPTColor colorWithCGColor:[self dataLineColor:index]];
        lineStyle.lineWidth = [self dataLineWidth:index];
		plot.dataLineStyle = lineStyle;
        
        lineStyle.lineColor = [CPTColor colorWithCGColor:[self dataSymbolColor:index]];
		plot.plotSymbol = [self plotSymbol:index];
		plot.plotSymbol.lineStyle = lineStyle;
		plot.plotSymbol.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[self dataSymbolColor:index]]];
		plot.plotSymbol.size = CGSizeMake(10.0, 10.0);		
		plot.areaFill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[self areaFillColor:index]]];
		plot.areaBaseValue = CPTDecimalFromFloat(MAX(self.inputYMin, MIN(self.inputYMax, 0.0)));
		
		[plot reloadData];
	}
	return YES;
}

#pragma mark -
#pragma markData source methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot 
{	
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *xKey = [NSString stringWithFormat:@"plotXNumbers%i", plotIndex];
	NSString *yKey = [NSString stringWithFormat:@"plotYNumbers%i", plotIndex];
	
	if (![self valueForInputKey:xKey] || ![self valueForInputKey:yKey])
		return 0;
	
	else if ([[self valueForInputKey:xKey] count] != [[self valueForInputKey:yKey] count])
		return 0;
	
	return [[self valueForInputKey:xKey] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *xKey = [NSString stringWithFormat:@"plotXNumbers%i", plotIndex];
	NSString *yKey = [NSString stringWithFormat:@"plotYNumbers%i", plotIndex];
	
	if (![self valueForInputKey:xKey] || ![self valueForInputKey:yKey])
		return nil;
	
	else if ([[self valueForInputKey:xKey] count] != [[self valueForInputKey:yKey] count])
		return nil;
	
	NSString *key = (fieldEnum == CPTScatterPlotFieldX) ? xKey : yKey;
	
	NSDictionary *dict = [self valueForInputKey:key];
	
	NSString *dictionaryKey = [NSString stringWithFormat:@"%i", index];
	
	NSNumber *number = [dict valueForKey:dictionaryKey];
	
	if (number == nil)
	{
		NSLog(@"No value for key: %@", dictionaryKey);
		NSLog(@"Dict: %@", dict);
	}
	
	return number;
	
}

@end
