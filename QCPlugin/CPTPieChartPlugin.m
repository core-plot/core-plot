#import "CPTPieChartPlugin.h"

@implementation CPTPieChartPlugIn

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
@dynamic inputAxisLineWidth, inputAxisColor;
@dynamic inputPlotAreaColor, inputBorderColor, inputBorderWidth;
@dynamic inputLabelColor;

/*
 Pie chart special accessors
 */
@dynamic inputPieRadius, inputSliceLabelOffset, inputStartAngle, inputSliceDirection;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"Core Plot Pie Chart", QCPTlugInAttributeNameKey, 
			@"Pie chart", QCPTlugInAttributeDescriptionKey, 
			nil];
}

- (double) inputXMax { return 1.0; }
- (double) inputXMin { return -1.0; }
- (double) inputYMax { return 1.0; }
- (double) inputYMin { return -1.0; }

// Pie charts only support one layer so we override the createViewController method (to hide the number of charts button)

- (QCPTlugInViewController*) createViewController
{
	return nil;
}

+ (NSArray*) sortedPropertyPortKeys
{
	NSArray *pieChartPropertyPortKeys = [NSArray arrayWithObjects:@"inputPieRadius", @"inputSliceLabelOffset", @"inputStartAngle", @"inputSliceDirection", @"inputBorderColor", @"inputBorderWidth", nil];

	return [[super sortedPropertyPortKeys] arrayByAddingObjectsFromArray:pieChartPropertyPortKeys];
}			

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	// A few additional ports for the pie chart type ...
	if ([key isEqualToString:@"inputPieRadius"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Pie Radius", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:0.75], QCPTortAttributeDefaultValueKey,
				nil];
	
	else if ([key isEqualToString:@"inputSliceLabelOffset"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Label Offset", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:20.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	else if ([key isEqualToString:@"inputStartAngle"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Start Angle", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	else if ([key isEqualToString:@"inputSliceDirection"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Slice Direction", QCPTortAttributeNameKey,
				[NSNumber numberWithInt:1], QCPTortAttributeMaximumValueKey,
				[NSArray arrayWithObjects:@"Clockwise", @"Counter-Clockwise", nil], QCPTortAttributeMenuItemsKey,
				[NSNumber numberWithInt:0], QCPTortAttributeDefaultValueKey,
				nil];
	
	else if ([key isEqualToString:@"inputBorderWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Border Width", QCPTortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPTortAttributeMinimumValueKey,
				[NSNumber numberWithFloat:1.0], QCPTortAttributeDefaultValueKey,
				nil];
	
	else if ([key isEqualToString:@"inputBorderColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Border Color", QCPTortAttributeNameKey,
				[(id)CGColorCreateGenericGray(0.0, 1.0) autorelease], QCPTortAttributeDefaultValueKey,
				nil];
	
	else if ([key isEqualToString:@"inputLabelColor"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Label Color", QCPTortAttributeNameKey,
				[(id)CGColorCreateGenericGray(1.0, 1.0) autorelease], QCPTortAttributeDefaultValueKey,
				nil];	

	else
		return [super attributesForPropertyPortWithKey:key];
}

- (void) addPlotWithIndex:(NSUInteger)index
{
	if (index == 0)
	{
		[self addInputPortWithType:QCPTortTypeStructure
							forKey:[NSString stringWithFormat:@"plotNumbers%i", index]
					withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"Data Values", index+1], QCPTortAttributeNameKey,
									QCPTortTypeStructure, QCPTortAttributeTypeKey,
									nil]];

		[self addInputPortWithType:QCPTortTypeStructure
							forKey:[NSString stringWithFormat:@"plotLabels%i", index]
					withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"Data Labels", index+1], QCPTortAttributeNameKey,
									QCPTortTypeStructure, QCPTortAttributeTypeKey,
									nil]];
		
		// TODO: add support for used defined fill colors.  As of now we use a single color
		// multiplied against the 'default' pie chart colors
		[self addInputPortWithType:QCPTortTypeColor
							forKey:[NSString stringWithFormat:@"plotFillColor%i",  index]
					withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"Primary Fill Color", index+1], QCPTortAttributeNameKey,
									QCPTortTypeColor, QCPTortAttributeTypeKey,
									[(id)CGColorCreateGenericGray(1.0, 1.0) autorelease], QCPTortAttributeDefaultValueKey,
									nil]];
		
		// Add the new plot to the graph
		CPTPieChart *pieChart = [[[CPTPieChart alloc] init] autorelease];
		pieChart.identifier = [NSString stringWithFormat:@"Pie Chart %i", index+1];
		pieChart.dataSource = self;
		
		[graph addPlot:pieChart];
	}
}

#pragma mark -
#pragma markGraph configuration

- (void) createGraph
{ 
	if (!graph)
	{
		// Create graph from theme
		CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
		graph = (CPTXYGraph *)[theme newGraph];
		graph.axisSet = nil;
		
	}		
}

- (BOOL) configureAxis
{
	// We use no axis for the pie chart
	graph.axisSet = nil;
	graph.plotAreaFrame.plotArea.borderLineStyle = nil;
	return YES;
}


- (BOOL) configurePlots
{

	// Configure the pie chart
	for (CPTPieChart* pieChart in [graph allPlots])
	{
		pieChart.plotArea.borderLineStyle = nil;
		
		pieChart.pieRadius = self.inputPieRadius*MIN(self.inputPixelsWide, self.inputPixelsHigh)/2.0;
		pieChart.sliceLabelOffset = self.inputSliceLabelOffset;
		pieChart.startAngle = self.inputStartAngle*M_PI/180.0;	// QC typically works in degrees
		pieChart.centerAnchor = CGPointMake(0.5, 0.5);
		pieChart.sliceDirection = (self.inputSliceDirection == 0) ? CPTPieDirectionClockwise : CPTPieDirectionCounterClockwise;

		if (self.inputBorderWidth > 0.0)
		{
			CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
			borderLineStyle.lineWidth = self.inputBorderWidth;
			borderLineStyle.lineColor = [CPTColor colorWithCGColor:self.inputBorderColor];
			borderLineStyle.lineCap = kCGLineCapSquare;
			borderLineStyle.lineJoin = kCGLineJoinBevel;
			pieChart.borderLineStyle = borderLineStyle;
		}
		else {
			pieChart.borderLineStyle = nil;
		}

		[pieChart reloadData];
	}
	
	return YES;
}

#pragma mark -
#pragma markData source methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot 
{	
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *key = [NSString stringWithFormat:@"plotNumbers%i", plotIndex];
	
	if (![self valueForInputKey:key])
		return 0;
	
	return [[self valueForInputKey:key] count];
}

- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index	 
{
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *key = [NSString stringWithFormat:@"plotNumbers%i", plotIndex];
	
	if (![self valueForInputKey:key])
		return nil;
	
	NSDictionary *dict = [self valueForInputKey:key];	
	return [NSDecimalNumber decimalNumberWithString:[[dict valueForKey:[NSString stringWithFormat:@"%i", index]] stringValue]];
}

- (CPTFill *) sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index	
{
	CGColorRef plotFillColor = [[CPTPieChart defaultPieSliceColorForIndex:index] cgColor];
	CGColorRef inputFillColor = [self areaFillColor:0];
	
	const CGFloat *plotColorComponents = CGColorGetComponents(plotFillColor);
	const CGFloat *inputColorComponents = CGColorGetComponents(inputFillColor);
	
	
	CGColorRef fillColor = CGColorCreateGenericRGB(plotColorComponents[0]*inputColorComponents[0],
												   plotColorComponents[1]*inputColorComponents[1],
												   plotColorComponents[2]*inputColorComponents[2],
												   plotColorComponents[3]*inputColorComponents[3]);	
	
	CPTColor *fillCPTColor = [CPTColor colorWithCGColor:fillColor];

	CGColorRelease(fillColor);
	
	return [[(CPTFill *)[CPTFill alloc] initWithColor:fillCPTColor] autorelease];
}

- (CPTTextLayer *) sliceLabelForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:pieChart];
	NSString *key = [NSString stringWithFormat:@"plotLabels%i", plotIndex];
	
	if (![self valueForInputKey:key])
		return nil;
	
	NSDictionary *dict = [self valueForInputKey:key];
	
	NSString *label = [dict valueForKey:[NSString stringWithFormat:@"%i", index]];
	
	CPTTextLayer *layer = [[[CPTTextLayer alloc] initWithText:label] autorelease];
	[layer sizeToFit];

	CPTMutableTextStyle *style = [CPTMutableTextStyle textStyle];
	style.color = [CPTColor colorWithCGColor:self.inputLabelColor];
	layer.textStyle = style;
	
	return layer;	
}

@end
