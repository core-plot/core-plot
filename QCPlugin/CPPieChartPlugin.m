#import "CPPieChartPlugin.h"

@implementation CPPieChartPlugIn

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
@dynamic inputAxisLineWidth, inputAxisColor;
@dynamic inputPlotAreaColor, inputBorderColor, inputBorderWidth;
@dynamic inputLabelColor;

/*
 * Pie chart special accessors
 */
@dynamic inputPieRadius, inputSliceLabelOffset, inputStartAngle, inputSliceDirection;

+(NSDictionary *)attributes
{
    return @{
               QCPlugInAttributeNameKey: @"Core Plot Pie Chart",
               QCPlugInAttributeDescriptionKey: @"Pie chart"
    };
}

-(double)inputXMax
{
    return 1.0;
}

-(double)inputXMin
{
    return -1.0;
}

-(double)inputYMax
{
    return 1.0;
}

-(double)inputYMin
{
    return -1.0;
}

// Pie charts only support one layer so we override the createViewController method (to hide the number of charts button)

-(QCPlugInViewController *)createViewController
{
    return nil;
}

+(NSArray *)sortedPropertyPortKeys
{
    NSArray *pieChartPropertyPortKeys = @[@"inputPieRadius", @"inputSliceLabelOffset", @"inputStartAngle", @"inputSliceDirection", @"inputBorderColor", @"inputBorderWidth"];

    return [[super sortedPropertyPortKeys] arrayByAddingObjectsFromArray:pieChartPropertyPortKeys];
}

+(NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    // A few additional ports for the pie chart type ...
    if ( [key isEqualToString:@"inputPieRadius"] ) {
        return @{
                   QCPortAttributeNameKey: @"Pie Radius",
                   QCPortAttributeMinimumValueKey: @0.0,
                   QCPortAttributeDefaultValueKey: @0.75
        };
    }
    else if ( [key isEqualToString:@"inputSliceLabelOffset"] ) {
        return @{
                   QCPortAttributeNameKey: @"Label Offset",
                   QCPortAttributeDefaultValueKey: @20.0
        };
    }
    else if ( [key isEqualToString:@"inputStartAngle"] ) {
        return @{
                   QCPortAttributeNameKey: @"Start Angle",
                   QCPortAttributeDefaultValueKey: @0.0
        };
    }
    else if ( [key isEqualToString:@"inputSliceDirection"] ) {
        return @{
                   QCPortAttributeNameKey: @"Slice Direction",
                   QCPortAttributeMaximumValueKey: @1,
                   QCPortAttributeMenuItemsKey: @[@"Clockwise", @"Counter-Clockwise"],
                   QCPortAttributeDefaultValueKey: @0
        };
    }
    else if ( [key isEqualToString:@"inputBorderWidth"] ) {
        return @{
                   QCPortAttributeNameKey: @"Border Width",
                   QCPortAttributeMinimumValueKey: @0.0,
                   QCPortAttributeDefaultValueKey: @1.0
        };
    }
    else if ( [key isEqualToString:@"inputBorderColor"] ) {
        CGColorRef grayColor = CGColorCreateGenericGray(0.0, 1.0);
        NSDictionary *result = @{
            QCPortAttributeNameKey: @"Border Color",
            QCPortAttributeDefaultValueKey: (id)grayColor
        };
        CGColorRelease(grayColor);
        return result;
    }
    else if ( [key isEqualToString:@"inputLabelColor"] ) {
        CGColorRef grayColor = CGColorCreateGenericGray(1.0, 1.0);
        NSDictionary *result = @{
            QCPortAttributeNameKey: @"Label Color",
            QCPortAttributeDefaultValueKey: (id)grayColor
        };
        CGColorRelease(grayColor);
        return result;
    }
    else {
        return [super attributesForPropertyPortWithKey:key];
    }
}

-(void)addPlotWithIndex:(NSUInteger)index
{
    if ( index == 0 ) {
        [self addInputPortWithType:QCPortTypeStructure
                            forKey:[NSString stringWithFormat:@"plotNumbers%lu", (unsigned long)index]
                    withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Data Values %u", (unsigned)(index + 1)],
                                      QCPortAttributeTypeKey: QCPortTypeStructure }
        ];

        [self addInputPortWithType:QCPortTypeStructure
                            forKey:[NSString stringWithFormat:@"plotLabels%lu", (unsigned long)index]
                    withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Data Labels %lu", (unsigned long)(index + 1)],
                                      QCPortAttributeTypeKey: QCPortTypeStructure }
        ];

        // TODO: add support for used defined fill colors.  As of now we use a single color
        // multiplied against the 'default' pie chart colors
        CGColorRef grayColor = CGColorCreateGenericGray(1.0, 1.0);
        [self addInputPortWithType:QCPortTypeColor
                            forKey:[NSString stringWithFormat:@"plotFillColor%lu", (unsigned long)index]
                    withAttributes:@{ QCPortAttributeNameKey: [NSString stringWithFormat:@"Primary Fill Color %lu", (unsigned long)(index + 1)],
                                      QCPortAttributeTypeKey: QCPortTypeColor,
                                      QCPortAttributeDefaultValueKey: (id)grayColor }
        ];
        CGColorRelease(grayColor);

        // Add the new plot to the graph
        CPTPieChart *pieChart = [[[CPTPieChart alloc] init] autorelease];
        pieChart.identifier = [NSString stringWithFormat:@"Pie Chart %lu", (unsigned long)(index + 1)];
        pieChart.dataSource = self;

        [graph addPlot:pieChart];
    }
}

#pragma mark -
#pragma mark Graph configuration

-(void)createGraph
{
    if ( !graph ) {
        // Create graph from theme
        CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
        graph         = (CPTXYGraph *)[theme newGraph];
        graph.axisSet = nil;
    }
}

-(BOOL)configureAxis
{
    // We use no axis for the pie chart
    graph.axisSet                                = nil;
    graph.plotAreaFrame.plotArea.borderLineStyle = nil;
    return YES;
}

-(BOOL)configurePlots
{
    // Configure the pie chart
    for ( CPTPieChart *pieChart in [graph allPlots] ) {
        pieChart.plotArea.borderLineStyle = nil;

        pieChart.pieRadius      = self.inputPieRadius * MIN(self.inputPixelsWide, self.inputPixelsHigh) / 2.0;
        pieChart.labelOffset    = self.inputSliceLabelOffset;
        pieChart.startAngle     = self.inputStartAngle * M_PI / 180.0; // QC typically works in degrees
        pieChart.centerAnchor   = CGPointMake(0.5, 0.5);
        pieChart.sliceDirection = (self.inputSliceDirection == 0) ? CPTPieDirectionClockwise : CPTPieDirectionCounterClockwise;

        if ( self.inputBorderWidth > 0.0 ) {
            CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
            borderLineStyle.lineWidth = self.inputBorderWidth;
            borderLineStyle.lineColor = [CPTColor colorWithCGColor:self.inputBorderColor];
            borderLineStyle.lineCap   = kCGLineCapSquare;
            borderLineStyle.lineJoin  = kCGLineJoinBevel;
            pieChart.borderLineStyle  = borderLineStyle;
        }
        else {
            pieChart.borderLineStyle = nil;
        }

        [pieChart reloadData];
    }

    return YES;
}

#pragma mark -
#pragma mark Data source methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
    NSString *key        = [NSString stringWithFormat:@"plotNumbers%lu", (unsigned long)plotIndex];

    if ( ![self valueForInputKey:key] ) {
        return 0;
    }

    return [[self valueForInputKey:key] count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSUInteger plotIndex = [[graph allPlots] indexOfObject:plot];
    NSString *key        = [NSString stringWithFormat:@"plotNumbers%lu", (unsigned long)plotIndex];

    if ( ![self valueForInputKey:key] ) {
        return nil;
    }

    NSDictionary *dict = [self valueForInputKey:key];
    return [NSDecimalNumber decimalNumberWithString:[[dict valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)index]] stringValue]];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CGColorRef plotFillColor  = [[CPTPieChart defaultPieSliceColorForIndex:index] cgColor];
    CGColorRef inputFillColor = (CGColorRef)[self areaFillColor : 0];

    const CGFloat *plotColorComponents  = CGColorGetComponents(plotFillColor);
    const CGFloat *inputColorComponents = CGColorGetComponents(inputFillColor);

    CGColorRef fillColor = CGColorCreateGenericRGB(plotColorComponents[0] * inputColorComponents[0],
                                                   plotColorComponents[1] * inputColorComponents[1],
                                                   plotColorComponents[2] * inputColorComponents[2],
                                                   plotColorComponents[3] * inputColorComponents[3]);

    CPTColor *fillCPColor = [CPTColor colorWithCGColor:fillColor];

    CGColorRelease(fillColor);

    return [[[CPTFill alloc] initWithColor:fillCPColor] autorelease];
}

-(CPTTextLayer *)sliceLabelForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    NSUInteger plotIndex = [[graph allPlots] indexOfObject:pieChart];
    NSString *key        = [NSString stringWithFormat:@"plotLabels%lu", (unsigned long)plotIndex];

    if ( ![self valueForInputKey:key] ) {
        return nil;
    }

    NSDictionary *dict = [self valueForInputKey:key];

    NSString *label = [dict valueForKey:[NSString stringWithFormat:@"%lu", (unsigned long)index]];

    CPTTextLayer *layer = [[[CPTTextLayer alloc] initWithText:label] autorelease];
    [layer sizeToFit];

    CPTMutableTextStyle *style = [CPTMutableTextStyle textStyle];
    style.color     = [CPTColor colorWithCGColor:self.inputLabelColor];
    layer.textStyle = style;

    return layer;
}

@end
