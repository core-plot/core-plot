#import "CPTBarPlotPlugIn.h"

@implementation CPTBarPlotPlugIn

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

/*
 * Bar plot special accessors
 */
@dynamic inputBaseValue, inputBarOffset, inputBarWidth, inputHorizontalBars;

+(NSDictionary<NSString *, NSString *> *)attributes
{
    return @{
               QCPlugInAttributeNameKey: @"Core Plot Bar Chart",
               QCPlugInAttributeDescriptionKey: @"Bar chart"
    };
}

+(CPTDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    // A few additional ports for the bar plot chart type ...

    if ( [key isEqualToString:@"inputBarWidth"] ) {
        return @{
                   QCPortAttributeNameKey: @"Bar Width",
                   QCPortAttributeDefaultValueKey: @1.0,
                   QCPortAttributeMinimumValueKey: @0.0
        };
    }

    if ( [key isEqualToString:@"inputBarOffset"] ) {
        return @{
                   QCPortAttributeNameKey: @"Bar Offset",
                   QCPortAttributeDefaultValueKey: @0.5
        };
    }

    if ( [key isEqualToString:@"inputBaseValue"] ) {
        return @{
                   QCPortAttributeNameKey: @"Base Value",
                   QCPortAttributeDefaultValueKey: @0.0
        };
    }

    if ( [key isEqualToString:@"inputHorizontalBars"] ) {
        return @{
                   QCPortAttributeNameKey: @"Horizontal Bars",
                   QCPortAttributeDefaultValueKey: @NO
        };
    }

    if ( [key isEqualToString:@"inputXMin"] ) {
        return @{
                   QCPortAttributeNameKey: @"X Range Min",
                   QCPortAttributeDefaultValueKey: @0.0
        };
    }

    if ( [key isEqualToString:@"inputXMax"] ) {
        return @{
                   QCPortAttributeNameKey: @"X Range Max",
                   QCPortAttributeDefaultValueKey: @5.0
        };
    }

    if ( [key isEqualToString:@"inputYMin"] ) {
        return @{
                   QCPortAttributeNameKey: @"Y Range Min",
                   QCPortAttributeDefaultValueKey: @0.0
        };
    }

    if ( [key isEqualToString:@"inputYMax"] ) {
        return @{
                   QCPortAttributeNameKey: @"Y Range Max",
                   QCPortAttributeDefaultValueKey: @5.0
        };
    }

    return [super attributesForPropertyPortWithKey:key];
}

-(void)addPlotWithIndex:(NSUInteger)index
{
    // Create input ports for the new plot

    [self addInputPortWithType:QCPortTypeStructure
                        forKey:[NSString stringWithFormat:@"plotNumbers%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Values %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeStructure }
    ];

    CGColorRef lineColor = [self newDefaultColorForPlot:index alpha:1.0];
    [self addInputPortWithType:QCPortTypeColor
                        forKey:[NSString stringWithFormat:@"plotDataLineColor%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Plot Line Color %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeColor,
                                  QCPortAttributeDefaultValueKey: CFBridgingRelease(lineColor) }
    ];

    CGColorRef fillColor = [self newDefaultColorForPlot:index alpha:0.25];
    [self addInputPortWithType:QCPortTypeColor
                        forKey:[NSString stringWithFormat:@"plotFillColor%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Plot Fill Color %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeColor,
                                  QCPortAttributeDefaultValueKey: CFBridgingRelease(fillColor) }
    ];

    [self addInputPortWithType:QCPortTypeNumber
                        forKey:[NSString stringWithFormat:@"plotDataLineWidth%lu", (unsigned long)index]
                withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Plot Line Width %lu", (unsigned long)(index + 1)],
                                  QCPortAttributeTypeKey: QCPortTypeNumber,
                                  QCPortAttributeDefaultValueKey: @1.0,
                                  QCPortAttributeMinimumValueKey: @0.0 }
    ];

    // Add the new plot to the graph
    CPTBarPlot *barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor greenColor] horizontalBars:NO];
    barPlot.identifier = [NSString stringWithFormat:@"Bar Plot %lu", (unsigned long)(index + 1)];
    barPlot.dataSource = self;
    [self.graph addPlot:barPlot];
}

-(void)removePlots:(NSUInteger)count
{
    // Clean up a deleted plot
    CPTGraph *theGraph = self.graph;

    NSUInteger plotCount = self.numberOfPlots;

    for ( NSUInteger i = plotCount; i > plotCount - count; i-- ) {
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotNumbers%lu", (unsigned long)(i - 1)]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineColor%lu", (unsigned long)(i - 1)]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotFillColor%lu", (unsigned long)(i - 1)]];
        [self removeInputPortForKey:[NSString stringWithFormat:@"plotDataLineWidth%lu", (unsigned long)(i - 1)]];

        [theGraph removePlot:[theGraph allPlots].lastObject];
    }
}

-(BOOL)configurePlots
{
    CPTGraph *theGraph = self.graph;

    // The pixel width of a single plot unit (1..2) along the x axis of the plot
    double count     = (double)[theGraph allPlots].count;
    double unitWidth = theGraph.plotAreaFrame.bounds.size.width / (self.inputXMax - self.inputXMin);
    double barWidth  = self.inputBarWidth * unitWidth / count;

    // Configure scatter plots for active plot inputs
    for ( CPTBarPlot *plot in [theGraph allPlots] ) {
        NSUInteger index               = [[theGraph allPlots] indexOfObject:plot];
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        lineStyle.lineColor    = [CPTColor colorWithCGColor:[self dataLineColor:index]];
        lineStyle.lineWidth    = [self dataLineWidth:index];
        plot.lineStyle         = lineStyle;
        plot.baseValue         = @(self.inputBaseValue);
        plot.barWidth          = @(barWidth);
        plot.barOffset         = @(self.inputBarOffset);
        plot.barsAreHorizontal = self.inputHorizontalBars;
        plot.fill              = [CPTFill fillWithColor:[CPTColor colorWithCGColor:(CGColorRef)[self areaFillColor:index]]];

        [plot reloadData];
    }

    return YES;
}

#pragma mark -
#pragma mark Data source methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger plotIndex = [[self.graph allPlots] indexOfObject:plot];
    NSString *key        = [NSString stringWithFormat:@"plotNumbers%lu", (unsigned long)plotIndex];

    return [[self valueForInputKey:key] count];
}

-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    NSUInteger plotIndex = [[self.graph allPlots] indexOfObject:plot];
    NSString *key        = [NSString stringWithFormat:@"plotNumbers%lu", (unsigned long)plotIndex];

    CPTDictionary *dict = [self valueForInputKey:key];

    if ( !dict ) {
        return nil;
    }

    NSUInteger keyCount          = dict.allKeys.count;
    CPTMutableNumberArray *array = [NSMutableArray array];

    if ( fieldEnum == CPTBarPlotFieldBarLocation ) {
        // Calculate horizontal position of bar - nth bar index + barWidth*plotIndex + 0.5
        float xpos;
        float plotCount = [self.graph allPlots].count;

        for ( NSUInteger i = 0; i < keyCount; i++ ) {
            xpos = (float)i + (float)plotIndex / (plotCount);
            [array addObject:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%f", (double)xpos]]];
        }
    }
    else {
        for ( NSUInteger i = 0; i < keyCount; i++ ) {
            [array addObject:[NSDecimalNumber decimalNumberWithString:[dict[[NSString stringWithFormat:@"%lu", (unsigned long)i]] stringValue]]];
        }
    }

    return array;
}

@end
