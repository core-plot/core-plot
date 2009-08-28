//
//  CPBarPlotPlugIn.m
//  CorePlotQCPlugIn
//
//  Created by Caleb Cannon on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
@dynamic inputBackgroundColor, inputPlotAreaColor, inputBorderColor;
@dynamic inputAxisColor, inputAxisLineWidth, inputAxisMinorTickWidth, inputAxisMajorTickWidth, inputAxisMajorTickLength, inputAxisMinorTickLength;
@dynamic inputMajorGridLineWidth, inputMinorGridLineWidth;
@dynamic inputXMin, inputXMax, inputYMin, inputYMax;
@dynamic inputLeftMargin, inputRightMargin, inputTopMargin, inputBottomMargin;
@dynamic inputXMajorIntervals, inputYMajorIntervals, inputXMinorIntervals, inputYMinorIntervals;

/*
 Bar plot special accessors
 */
@dynamic inputBaseValue, inputBarOffset, inputBarWidth, inputHorizontalBars;

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"Core Plot Bar Chart", QCPlugInAttributeNameKey, 
			@"Bar chart", QCPlugInAttributeDescriptionKey, 
			nil];
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	// A few additional ports for the bar plot chart type ...
	
	if ([key isEqualToString:@"inputBarWidth"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Bar Width", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.5], QCPortAttributeDefaultValueKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeMinimumValueKey,
				nil];
	
	if ([key isEqualToString:@"inputBarOffset"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Bar Offset", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				nil];

	if ([key isEqualToString:@"inputBaseValue"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Base Value", QCPortAttributeNameKey,
				[NSNumber numberWithFloat:0.0], QCPortAttributeDefaultValueKey,
				nil];
	
	if ([key isEqualToString:@"inputHorizontalBars"])
		return [NSDictionary dictionaryWithObjectsAndKeys:
				@"Horizontal Bars", QCPortAttributeNameKey,
				[NSNumber numberWithBool:NO], QCPortAttributeDefaultValueKey,
				nil];
	
	return [super attributesForPropertyPortWithKey:key];
}

- (void) addPlotWithIndex:(NSUInteger)index
{
	// Create input ports for the new plot
	
	[self addInputPortWithType:QCPortTypeStructure
						forKey:[NSString stringWithFormat:@"plotNumbers%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Values %i", index+1], QCPortAttributeNameKey,
								QCPortTypeStructure, QCPortAttributeTypeKey,
								nil]];
		
	[self addInputPortWithType:QCPortTypeColor
						forKey:[NSString stringWithFormat:@"plotDataLineColor%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Plot Line Color %i", index+1], QCPortAttributeNameKey,
								QCPortTypeColor, QCPortAttributeTypeKey,
								[self defaultColorForPlot:index alpha:1.0], QCPortAttributeDefaultValueKey,
								nil]];
	
	[self addInputPortWithType:QCPortTypeColor
						forKey:[NSString stringWithFormat:@"plotFillColor%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Plot Fill Color %i", index+1], QCPortAttributeNameKey,
								QCPortTypeColor, QCPortAttributeTypeKey,
								[self defaultColorForPlot:index alpha:0.25], QCPortAttributeDefaultValueKey,
								nil]];
	
	[self addInputPortWithType:QCPortTypeImage
						forKey:[NSString stringWithFormat:@"plotFillImage%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Plot Fill Image %i", index+1], QCPortAttributeNameKey,
								QCPortTypeImage, QCPortAttributeTypeKey,
								nil]];
	
	[self addInputPortWithType:QCPortTypeNumber
						forKey:[NSString stringWithFormat:@"plotDataLineWidth%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Plot Line Width %i", index+1], QCPortAttributeNameKey,
								QCPortTypeNumber, QCPortAttributeTypeKey,
								[NSNumber numberWithInt:1.0], QCPortAttributeDefaultValueKey,
								[NSNumber numberWithFloat:0.0], QCPortAttributeMinimumValueKey,
								nil]];
	
	// Add the new plot to the graph
	CPBarPlot *barPlot = [CPBarPlot tubularBarPlotWithColor:[CPColor greenColor] horizontalBars:NO];
	barPlot.identifier = [NSString stringWithFormat:@"Bar Plot %i", index+1];
	barPlot.dataSource = self;
	[graph addPlot:barPlot];
}

- (void) removePlots:(NSUInteger)count
{
	// Clean up a deleted plot

	for (int i = numberOfPlots; i > numberOfPlots-count; i--)
	{
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotNumbers%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineColor%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotFillColor%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotFillImage%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineWidth%i", i-1]];
		
		[graph removePlot:[[graph allPlots] lastObject]];
	}
}

- (BOOL) configurePlots
{
	// The pixel width of a single plot unit (1..2) along the x axis of the plot
	double count = (double)[[graph allPlots] count];
	double unitWidth = graph.plotArea.bounds.size.width / (self.inputXMax - self.inputXMin);	
	double barWidth = self.inputBarWidth*unitWidth/count;
	
	// Configure scatter plots for active plot inputs
	for (CPBarPlot* plot in [graph allPlots])
	{
		int index = [[graph allPlots] indexOfObject:plot];
		plot.lineStyle.lineColor = [CPColor colorWithCGColor:[self dataLineColor:index]];
		plot.lineStyle.lineWidth = [self dataLineWidth:index];
		
		plot.baseValue = CPDecimalFromDouble(self.inputBaseValue);
		plot.barWidth = barWidth;
		plot.barOffset = ((index) / count) * unitWidth / barWidth + 0.5 + self.inputBarOffset;
		
		plot.barsAreHorizontal = self.inputHorizontalBars;
		
		if ([self areaFillImage:index])
		{
			CGImageRef imageRef = [self areaFillImage:index];
			plot.fill = [CPFill fillWithImage:[CPImage imageWithCGImage:[self areaFillImage:index]]];
			CGImageRelease(imageRef);
		}
		else
			plot.fill = [CPFill fillWithColor:[CPColor colorWithCGColor:[self areaFillColor:index]]];
			
		[plot reloadData];
	}
	
	return YES;
}

#pragma mark -
#pragma markData source methods

-(CPFill *) barFillForBarPlot:(CPBarPlot *)barPlot recordIndex:(NSNumber *)index
{
	return nil;
}

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot 
{	
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *key = [NSString stringWithFormat:@"plotNumbers%i", plotIndex];
	
	if (![self valueForInputKey:key])
		return 0;
		
	return [[self valueForInputKey:key] count];
}

-(NSArray *)numbersForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *key = [NSString stringWithFormat:@"plotNumbers%i", plotIndex];
	
	if (![self valueForInputKey:key])
		return nil;
	
	NSDictionary *dict = [self valueForInputKey:key];
	NSMutableArray *array = [NSMutableArray array];
		
	for (int i = 0; i < [[dict allKeys] count]; i++)
		[array addObject:[NSDecimalNumber decimalNumberWithString:[[dict valueForKey:[NSString stringWithFormat:@"%i", i]] stringValue]]];
	
	return array;
}

@end
