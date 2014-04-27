#import "CPScatterPlotPlugIn.h"

@implementation CPScatterPlotPlugIn

/*
 * NOTE: It seems that QC plugins don't inherit dynamic input ports which is
 * why all of the accessor declarations are duplicated here
 */

/*
 * Accessor for the output image
 */
@dynamic outputImage;

/*
 * Dynamic accessors for the static PlugIn inputs
 */
@dynamic inputPixelsWide, inputPixelsHigh;
@dynamic inputPlotAreaColor;
@dynamic inputAxisColor, inputAxisLineWidth, inputAxisMinorTickWidth, inputAxisMajorTickWidth, inputAxisMajorTickLength, inputAxisMinorTickLength;
@dynamic inputMajorGridLineWidth, inputMinorGridLineWidth;
@dynamic inputXMin, inputXMax, inputYMin, inputYMax;
@dynamic inputXMajorIntervals, inputYMajorIntervals, inputXMinorIntervals, inputYMinorIntervals;

+(NSDictionary *)attributes
{
    return @{
               QCPlugInAttributeNameKey: @"Core Plot Scatter Plot",
               QCPlugInAttributeDescriptionKey: @"Scatter plot"
    };
}

-(void)addPlotWithIndex:(NSUInteger)index
{
    // Create input ports for the new plot

    [self addInputPortWithType:QCPortTypeStructure
                        forKey:[NSString stringWithFormat:@"plotXNumbers%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"X Values %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeStructure }
    ];

    [self addInputPortWithType:QCPortTypeStructure
                        forKey:[NSString stringWithFormat:@"plotYNumbers%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Y Values %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeStructure }
    ];

    CGColorRef lineColor = [self newDefaultColorForPlot:index alpha:1.0];
    [self addInputPortWithType:QCPortTypeColor
                        forKey:[NSString stringWithFormat:@"plotDataLineColor%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Plot Line Color %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeColor,
                                  QCPortAttributeDefaultValueKey: (id)lineColor }
    ];
    CGColorRelease(lineColor);

    CGColorRef fillColor = [self newDefaultColorForPlot:index alpha:0.25];
    [self addInputPortWithType:QCPortTypeColor
                        forKey:[NSString stringWithFormat:@"plotFillColor%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Plot Fill Color %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeColor,
                                  QCPortAttributeDefaultValueKey: (id)fillColor }
    ];
    CGColorRelease(fillColor);

    [self addInputPortWithType:QCPortTypeNumber
                        forKey:[NSString stringWithFormat:@"plotDataLineWidth%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Plot Line Width %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeNumber,
                                  QCPortAttributeDefaultValueKey: @1.0,
                                  QCPortAttributeMinimumValueKey: @0.0 }
    ];

    [self addInputPortWithType:QCPortTypeIndex
                        forKey:[NSString stringWithFormat:@"plotDataSymbols%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Data Symbols %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeIndex,
                                  QCPortAttributeMenuItemsKey: @[@"Empty", @"Circle", @"Triangle", @"Square", @"Plus", @"Star", @"Diamond", @"Pentagon", @"Hexagon", @"Dash", @"Snow"],
                                  QCPortAttributeDefaultValueKey: @0,
                                  QCPortAttributeMinimumValueKey: @0,
                                  QCPortAttributeMaximumValueKey: @10 }
    ];

    CGColorRef symbolColor = [self newDefaultColorForPlot:index alpha:0.25];
    [self addInputPortWithType:QCPortTypeColor
                        forKey:[NSString stringWithFormat:@"plotDataSymbolColor%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Data Symbol Color %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeColor,
                                  QCPortAttributeDefaultValueKey: (id)symbolColor }
    ];
    CGColorRelease(symbolColor);

    // Add the new plot to the graph
    CPTScatterPlot *scatterPlot = [[[CPTScatterPlot alloc] init] autorelease];
    scatterPlot.identifier = [NSString stringWithFormat:@"Data Source Plot %lu", (unsigned long)(index + 1)];

    // Line Style
    lineColor = [self newDefaultColorForPlot:index alpha:1.0];
    fillColor = [self newDefaultColorForPlot:index alpha:0.25];
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth       = 3.0;
    lineStyle.lineColor       = [CPTColor colorWithCGColor:lineColor];
    scatterPlot.dataLineStyle = lineStyle;
    scatterPlot.areaFill      = [CPTFill fillWithColor:[CPTColor colorWithCGColor:fillColor]];
    scatterPlot.dataSource    = self;
    [graph addPlot:scatterPlot];

    CGColorRelease(lineColor);
    CGColorRelease(fillColor);
}

-(void)removePlots:(NSUInteger)count
{
    // Clean up a deleted plot

    for ( int i = numberOfPlots; i > numberOfPlots - count; i-- ) {
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotXNumbers%i", i - 1]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotYNumbers%i", i - 1]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineColor%i", i - 1]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotFillColor%i", i - 1]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineWidth%i", i - 1]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotDataSymbols%i", i - 1]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotDataSymbolColor%i", i - 1]];

        [graph removePlot:[[graph allPlots] lastObject]];
    }
}

-(CPTPlotSymbol *)plotSymbol:(NSUInteger)index
{
    NSString *key    = [NSString stringWithFormat:@"plotDataSymbols%lu", (unsigned long)index];
    NSUInteger value = [[self valueForInputKey:key] unsignedIntValue];

    switch ( value ) {
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

-(CGColorRef)dataSymbolColor:(NSUInteger)index
{
    NSString *key = [NSString stringWithFormat:@"plotDataSymbolColor%lu", (unsigned long)index];

    return (CGColorRef)[self valueForInputKey : key];
}

-(BOOL)configurePlots
{
    // Adjust the plots configuration using the QC input ports

    for ( CPTScatterPlot *plot in [graph allPlots] ) {
        int index = [[graph allPlots] indexOfObject:plot];

        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineColor = [CPTColor colorWithCGColor:(CGColorRef)[self dataLineColor : index]];
        lineStyle.lineWidth = [self dataLineWidth:index];
        plot.dataLineStyle  = lineStyle;

        lineStyle.lineColor       = [CPTColor colorWithCGColor:[self dataSymbolColor:index]];
        plot.plotSymbol           = [self plotSymbol:index];
        plot.plotSymbol.lineStyle = lineStyle;
        plot.plotSymbol.fill      = [CPTFill fillWithColor:[CPTColor colorWithCGColor:[self dataSymbolColor:index]]];
        plot.plotSymbol.size      = CGSizeMake(10.0, 10.0);
        plot.areaFill             = [CPTFill fillWithColor:[CPTColor colorWithCGColor:(CGColorRef)[self areaFillColor : index]]];
        plot.areaBaseValue        = CPTDecimalFromFloat( MAX( self.inputYMin, MIN(self.inputYMax, 0.0) ) );

        [plot reloadData];
    }
    return YES;
}

#pragma mark -
#pragma mark Data source methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
    NSString *xKey       = [NSString stringWithFormat:@"plotXNumbers%lu", (unsigned long)plotIndex];
    NSString *yKey       = [NSString stringWithFormat:@"plotYNumbers%lu", (unsigned long)plotIndex];

    if ( ![self valueForInputKey:xKey] || ![self valueForInputKey:yKey] ) {
        return 0;
    }
    else if ( [[self valueForInputKey:xKey] count] != [[self valueForInputKey:yKey] count] ) {
        return 0;
    }

    return [[self valueForInputKey:xKey] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
    NSString *xKey       = [NSString stringWithFormat:@"plotXNumbers%lu", (unsigned long)plotIndex];
    NSString *yKey       = [NSString stringWithFormat:@"plotYNumbers%lu", (unsigned long)plotIndex];

    if ( ![self valueForInputKey:xKey] || ![self valueForInputKey:yKey] ) {
        return nil;
    }
    else if ( [[self valueForInputKey:xKey] count] != [[self valueForInputKey:yKey] count] ) {
        return nil;
    }

    NSString *key = (fieldEnum == CPTScatterPlotFieldX) ? xKey : yKey;

    NSDictionary *dict = [self valueForInputKey:key];

    NSString *dictionaryKey = [NSString stringWithFormat:@"%lu", (unsigned long)index];

    NSNumber *number = dict[dictionaryKey];

    if ( number == nil ) {
        NSLog(@"No value for key: %@", dictionaryKey);
        NSLog(@"Dict: %@", dict);
    }

    return number;
}

@end
