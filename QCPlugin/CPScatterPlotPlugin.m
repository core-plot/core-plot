//
//  CPScatterPlotPlugIn.m
//  CorePlotQCPlugIn
//
//  Created by Caleb Cannon on 8/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CPScatterPlotPlugIn.h"

@implementation CPScatterPlotPlugIn

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

+ (NSDictionary*) attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			@"Core Plot Scatter Plot", QCPlugInAttributeNameKey, 
			@"Scatter plot", QCPlugInAttributeDescriptionKey, 
			nil];
}

- (void) addPlotWithIndex:(NSUInteger)index
{
	// Create input ports for the new plot
	
	[self addInputPortWithType:QCPortTypeStructure
						forKey:[NSString stringWithFormat:@"plotXNumbers%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"X Values %i", index+1], QCPortAttributeNameKey,
								QCPortTypeStructure, QCPortAttributeTypeKey,
								nil]];
	
	[self addInputPortWithType:QCPortTypeStructure
						forKey:[NSString stringWithFormat:@"plotYNumbers%i", index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Y Values %i", index+1], QCPortAttributeNameKey,
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
	
	// NOTE: For some reason QC is crashing when adding more than one popup menu item.  So I haven't even bothered to implement
	// the data symbols.  I don't know what the problem is >:/
	/*
	[self addInputPortWithType:QCPortTypeIndex
						forKey:[NSString stringWithFormat:@"plotDataSymbols%i",  index]
				withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
								[NSString stringWithFormat:@"Data Symbols %i", index+1], QCPortAttributeNameKey,
								QCPortTypeIndex, QCPortAttributeTypeKey,
								[NSArray arrayWithObjects:@"Empty", @"Circle", @"Square", @"Triangle", nil], QCPortAttributeMenuItemsKey,
								[NSNumber numberWithInt:0], QCPortAttributeDefaultValueKey,
								[NSNumber numberWithInt:0], QCPortAttributeMinimumValueKey,
								[NSNumber numberWithInt:3], QCPortAttributeMaximumValueKey,
								nil]];
	*/
	
	// Add the new plot to the graph
	CPScatterPlot *scatterPlot = [[[CPScatterPlot alloc] init] autorelease];
	scatterPlot.identifier = [NSString stringWithFormat:@"Data Source Plot %i", index+1];
	scatterPlot.dataLineStyle.lineWidth = 3.f;
	scatterPlot.dataLineStyle.lineColor = [CPColor colorWithCGColor:[self defaultColorForPlot:index alpha:1.0]];
	scatterPlot.areaFill = [CPFill fillWithColor:[CPColor colorWithCGColor:[self defaultColorForPlot:index alpha:0.25]]];
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
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotFillImage%i", i-1]];
		[self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineWidth%i", i-1]];
		
		[graph removePlot:[[graph allPlots] lastObject]];		
	}
}

- (BOOL) configurePlots
{
	// Adjust the plots configuration using the QC input ports

	for (CPScatterPlot* plot in [graph allPlots])
	{		
		int index = [[graph allPlots] indexOfObject:plot];
		plot.dataLineStyle.lineColor = [CPColor colorWithCGColor:[self dataLineColor:index]];
		plot.dataLineStyle.lineWidth = [self dataLineWidth:index];
		if ([self areaFillImage:index])
		{
			CGImageRef imageRef = [self areaFillImage:index];
			plot.areaFill = [CPFill fillWithImage:[CPImage imageWithCGImage:[self areaFillImage:index]]];
			CGImageRelease(imageRef);
		}
		else
			plot.areaFill = [CPFill fillWithColor:[CPColor colorWithCGColor:[self areaFillColor:index]]];
		[plot reloadData];
	}
	return YES;
}

#pragma mark -
#pragma markData source methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot 
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

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index 
{
	NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
	NSString *xKey = [NSString stringWithFormat:@"plotXNumbers%i", plotIndex];
	NSString *yKey = [NSString stringWithFormat:@"plotYNumbers%i", plotIndex];
	
	if (![self valueForInputKey:xKey] || ![self valueForInputKey:yKey])
		return nil;
	
	else if ([[self valueForInputKey:xKey] count] != [[self valueForInputKey:yKey] count])
		return nil;
	
	NSString *key = (fieldEnum == CPScatterPlotFieldX) ? xKey : yKey;
	
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
