#import "CPBarPlotPlugIn.h"

@implementation CPBarPlotPlugIn

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

/*
 Bar plot special accessors
 */
@dynamic inputBaseValue, inputBarOffset, inputBarWidth, inputHorizontalBars;

+(NSDictionary *)attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"Core Plot Bar Chart", QCPlugInAttributeNameKey,
			@"Bar chart", QCPlugInAttributeDescriptionKey,
			nil];
}

+(NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	// A few additional ports for the bar plot chart type ...

	if ( [key isEqualToString:@"inputBarWidth"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Bar Width", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:1.0], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeMinimumValueKey,
				nil];
	}

	if ( [key isEqualToString:@"inputBarOffset"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Bar Offset", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.5], QCPortAttributeDefaultValueKey,
				nil];
	}

	if ( [key isEqualToString:@"inputBaseValue"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Base Value", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				nil];
	}

	if ( [key isEqualToString:@"inputHorizontalBars"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Horizontal Bars", QCPortAttributeNameKey,
				[NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
				nil];
	}

	if ( [key isEqualToString:@"inputXMin"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Range Min", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				nil];
	}

	if ( [key isEqualToString:@"inputXMax"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"X Range Max", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:5.0], QCPortAttributeDefaultValueKey,
				nil];
	}

	if ( [key isEqualToString:@"inputYMin"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Range Min", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				nil];
	}

	if ( [key isEqualToString:@"inputYMax"] ) {
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Y Range Max", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:5.0], QCPortAttributeDefaultValueKey,
				nil];
	}

	return [super attributesForPropertyPortWithKey:key];
}

-(void)addPlotWithIndex:(NSUInteger)index
{
	// Create input ports for the new plot

	[self addInputPortWithType:QCPortTypeStructure
						forKey:[NSString stringWithFormat:@"plotNumbers%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
					 [NSString stringWithFormat:@"Values %i", index + 1], QCPortAttributeNameKey,
					 QCPortTypeStructure, QCPortAttributeTypeKey,
					 nil]];

	CGColorRef lineColor = [self newDefaultColorForPlot:index alpha:1.0];
	[self addInputPortWithType:QCPortTypeColor
						forKey:[NSString stringWithFormat:@"plotDataLineColor%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
					 [NSString stringWithFormat:@"Plot Line Color %i", index + 1], QCPortAttributeNameKey,
					 QCPortTypeColor, QCPortAttributeTypeKey,
					 lineColor, QCPortAttributeDefaultValueKey,
					 nil]];
	CGColorRelease( lineColor );

	CGColorRef fillColor = [self newDefaultColorForPlot:index alpha:0.25];
	[self addInputPortWithType:QCPortTypeColor
						forKey:[NSString stringWithFormat:@"plotFillColor%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
					 [NSString stringWithFormat:@"Plot Fill Color %i", index + 1], QCPortAttributeNameKey,
					 QCPortTypeColor, QCPortAttributeTypeKey,
					 fillColor, QCPortAttributeDefaultValueKey,
					 nil]];
	CGColorRelease( fillColor );

	[self addInputPortWithType:QCPortTypeNumber
						forKey:[NSString stringWithFormat:@"plotDataLineWidth%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
					 [NSString stringWithFormat:@"Plot Line Width %i", index + 1], QCPortAttributeNameKey,
					 QCPortTypeNumber, QCPortAttributeTypeKey,
					 [NSNumber numberWithInt:1.0], QCPortAttributeDefaultValueKey,
					 [NSNumber numberWithFloat:0.0], QCPortAttributeMinimumValueKey,
					 nil]];

	// Add the new plot to the graph
	CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
	barPlot.identifier = [NSString stringWithFormat:@"Bar Plot %i", index + 1];
	barPlot.dataSource = self;
	[graph addPlot:barPlot];
}

-(void)removePlots:(NSUInteger)count
{
	// Clean up a deleted plot

	for ( int i = numberOfPlots; i > numberOfPlots - count; i-- ) {
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotNumbers%i", i - 1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineColor%i", i - 1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotFillColor%i", i - 1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineWidth%i", i - 1]];

		[graph removePlot:[[graph allPlots] lastObject]];
	}
}

-(BOOL)configurePlots
{
	// The pixel width of a single plot unit (1..2) along the x axis of the plot
	double count	 = (double)[[graph allPlots] count];
	double unitWidth = graph.plotAreaFrame.bounds.size.width / (self.inputXMax - self.inputXMin);
	double barWidth	 = self.inputBarWidth * unitWidth / count;

	// Configure scatter plots for active plot inputs
	for ( CPTBarPlot *plot in [graph allPlots] ) {
		int index					   = [[graph allPlots] indexOfObject:plot];
		CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
		lineStyle.lineColor	   = [CPTColor colorWithCGColor:(CGColorRef)[self dataLineColor:index]];
		lineStyle.lineWidth	   = [self dataLineWidth:index];
		plot.lineStyle		   = lineStyle;
		plot.baseValue		   = CPTDecimalFromDouble( self.inputBaseValue );
		plot.barWidth		   = CPTDecimalFromDouble( barWidth );
		plot.barOffset		   = CPTDecimalFromDouble( self.inputBarOffset );
		plot.barsAreHorizontal = self.inputHorizontalBars;
		plot.fill			   = [CPTFill fillWithColor:[CPTColor colorWithCGColor:(CGColorRef)[self areaFillColor:index]]];

		[plot reloadData];
	}

	return YES;
}

#pragma mark -
#pragma markData source methods

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSNumber *)index
{
	return nil;
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *key		 = [NSString stringWithFormat:@"plotNumbers%i", plotIndex];

	if ( ![self valueForInputKey:key] ) {
		return 0;
	}

	return [[self valueForInputKey:key] count];
}

-(NSArray *)numbersForPlot:(CPTBarPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *key		 = [NSString stringWithFormat:@"plotNumbers%i", plotIndex];

	if ( ![self valueForInputKey:key] ) {
		return nil;
	}

	NSDictionary *dict	  = [self valueForInputKey:key];
	NSMutableArray *array = [NSMutableArray array];

	if ( fieldEnum == CPTBarPlotFieldBarLocation ) {
		// Calculate horizontal position of bar - nth bar index + barWidth*plotIndex + 0.5
		float xpos;
		float plotCount = [[graph allPlots] count];

		for ( int i = 0; i < [[dict allKeys] count]; i++ ) {
			xpos = (float)i + (float)plotIndex / (plotCount);
			[array addObject:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", xpos]]];
		}
	}
	else {
		for ( int i = 0; i < [[dict allKeys] count]; i++ ) {
			[array addObject:[NSDecimalNumber decimalNumberWithString:[[dict valueForKey:[NSString stringWithFormat:@"%i", i]] stringValue]]];
		}
	}

	return array;
}

@end
