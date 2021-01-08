//
//  PolarPlot.m
//  CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//

#import "PolarPlot.h"

#import "PiNumberFormatter.h"

@interface PolarPlot()

@property (nonatomic, readwrite, strong, nullable) CPTPolarPlotSpaceAnnotation *symbolTextAnnotation;
@property (nonatomic, readwrite, strong, nonnull) NSArray<NSArray<NSDictionary *>*> *plotDatum;
@property (nonatomic, readwrite, assign) CPTPolarPlotCurvedInterpolationOption curvedOption;

@end

@implementation PolarPlot


@synthesize symbolTextAnnotation;
@synthesize plotDatum;
@synthesize curvedOption;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Polar Plot";
        self.section = kPolarPlots;

        self.curvedOption = CPTPolarPlotCurvedInterpolationNormal;
    }

    return self;
}

-(void)killGraph
{
    if ( self.graphs.count ) {
        CPTGraph *graph = (self.graphs)[0];

        CPTPolarPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
        if ( annotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
            self.symbolTextAnnotation = nil;
        }
    }

    [super killGraph];
}

-(void)generateData
{
    if ( self.plotDatum.count == 0 ) {
        
        NSMutableArray<NSDictionary *> *contentArray1 = [NSMutableArray array];
        for ( NSUInteger i = 0; i < 49; i++ ) {
            NSNumber *theta = @((double)i / 24.0 * M_PI);
            NSNumber *radius = @(1.2 * arc4random() / (double)UINT32_MAX + 0.5);
            [contentArray1 addObject:@{ @"theta": theta, @"radius": radius }
            ];
        }
        
        NSMutableArray<NSDictionary *> *contentArray2 = [NSMutableArray array];
        double t = 0.0;
        for ( NSUInteger i = 0; i < 49; i++ ) {
            NSNumber *theta = @( M_PI_4 - sin(t) );
            NSNumber *radius = @( 0.5 + 1.5 * cos(3.0 * t) );
            [contentArray2 addObject:@{ @"theta": theta, @"radius": radius }
            ];
            t += M_PI / 24.0;
        }
        
        self.plotDatum = [NSArray arrayWithObjects:contentArray1, contentArray2, nil];
    }
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTPolarGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme_Polar]];

    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;

    // Setup polar plot space
    CPTPolarPlotSpace *plotSpace = (CPTPolarPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;
    plotSpace.majorScaleType = CPTScaleTypeLinear;
    plotSpace.minorScaleType = CPTScaleTypeLinear;
    plotSpace.radialAngleOption = CPTPolarRadialAngleModeDegrees;
    
    // Create a plot that uses the data source method
    CPTPolarPlot *dataSourcePolarPlot1 = [[CPTPolarPlot alloc] init];
    dataSourcePolarPlot1.identifier = @"Polar Source Plot";

    CPTMutableLineStyle *lineStyle1 = [dataSourcePolarPlot1.dataLineStyle mutableCopy];
    lineStyle1.lineWidth                = 3.0;
    lineStyle1.lineColor                = [CPTColor greenColor];
    dataSourcePolarPlot1.dataLineStyle   = lineStyle1;
    dataSourcePolarPlot1.curvedInterpolationOption = self.curvedOption;

    dataSourcePolarPlot1.dataSource = self;
    [graph addPlot:dataSourcePolarPlot1];
    
    CPTPolarPlot *dataSourcePolarPlot2 = [[CPTPolarPlot alloc] init];
    dataSourcePolarPlot2.identifier = @"Polar Parametric Plot";
        
    CPTMutableLineStyle *lineStyle2 = [dataSourcePolarPlot2.dataLineStyle mutableCopy];
    lineStyle2.lineWidth    = 3.0;
    lineStyle2.lineColor    = [CPTColor redColor];
    dataSourcePolarPlot2.dataLineStyle = lineStyle2;

    dataSourcePolarPlot2.dataSource = self;
    [graph addPlot:dataSourcePolarPlot2];

    CPTMutablePlotRange *majorRange = [CPTMutablePlotRange plotRangeWithLocation:@-2.125 length:@4.25];
    NSDecimalNumber *ratio = [NSDecimalNumber decimalNumberWithDecimal: CPTDecimalDivide(graph.plotAreaFrame.plotArea.heightDecimal, graph.plotAreaFrame.plotArea.widthDecimal)];
    CPTMutablePlotRange *minorRange = [majorRange mutableCopy];
    [minorRange expandRangeByFactor:ratio];
    
    plotSpace.majorRange = majorRange;
    plotSpace.minorRange = minorRange;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1.5;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.5)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor  colorWithGenericGray:CPTFloat(0.5)] colorWithAlphaComponent:CPTFloat(0.4)];

    CPTMutableLineStyle *radialMajorLineStyle = [CPTMutableLineStyle lineStyle];
    radialMajorLineStyle.lineWidth = 1.5;
    radialMajorLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    
    CPTMutableLineStyle *radialMinorLineStyle = [CPTMutableLineStyle lineStyle];
    radialMinorLineStyle.lineWidth = 0.25;
    radialMinorLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.4];

    // Axes
    // Label major axis with a fixed interval policy
    CPTPolarAxisSet *axisSet = (CPTPolarAxisSet *)graph.axisSet;
    
    CPTPolarAxis *majorAxis          = axisSet.majorAxis;
    majorAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    majorAxis.majorIntervalLength = @1;
    majorAxis.minorTicksPerInterval = 8;
    majorAxis.majorGridLineStyle    = majorGridLineStyle;
    majorAxis.minorGridLineStyle    = minorGridLineStyle;

    majorAxis.title         = @"Radius";
    majorAxis.titleOffset   = 30.0;
    majorAxis.titleLocation = @1.25;

    // Label minor with an automatic label policy.
    CPTPolarAxis *minorAxis = axisSet.minorAxis;
    minorAxis.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    minorAxis.majorIntervalLength = @1;
    minorAxis.minorTicksPerInterval       = 8;
    minorAxis.majorGridLineStyle          = majorGridLineStyle;
    minorAxis.minorGridLineStyle          = minorGridLineStyle;
    minorAxis.labelOffset                 = 10.0;

    minorAxis.title         = @"Radius";
    minorAxis.titleOffset   = 30.0;
    minorAxis.titleLocation = @1.25;
    
    // RADIAL AXIS ie polar  in degrees
    CPTPolarAxis *radialaxis = axisSet.radialAxis;
    if( plotSpace.radialAngleOption == CPTPolarRadialAngleModeRadians) {
        PiNumberFormatter *piFormatter = [[PiNumberFormatter alloc] init];
        piFormatter.multiplier = @16;
        radialaxis.labelFormatter = piFormatter;
        radialaxis.majorIntervalLength = [NSNumber numberWithDouble: M_PI / 8.0];
    }
    else {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.maximumFractionDigits = 1;
        radialaxis.labelFormatter = formatter;
        radialaxis.majorIntervalLength = @22.5;
    }
    radialaxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    radialaxis.minorTicksPerInterval = 2;
    
    radialaxis.majorGridLineStyle = radialMajorLineStyle;
    radialaxis.minorGridLineStyle = radialMinorLineStyle;
    
    radialaxis.labelAlignment = CPTAlignmentCenter;
    radialaxis.labelOffset = -10.0;
    radialaxis.radialLabelLocation = [NSNumber numberWithDouble: plotSpace.majorRange.midPointDouble + plotSpace.majorRange.lengthDouble * 0.5];
    CPTMutableTextStyle *radialAxisTextStyle = [CPTMutableTextStyle textStyle];
    radialAxisTextStyle.fontName = @"Helvetica";
    radialAxisTextStyle.fontSize = 14.0;
    radialAxisTextStyle.color = [[CPTColor colorWithGenericGray:CPTFloat(0.5)] colorWithAlphaComponent:CPTFloat(0.5)];
    radialaxis.labelTextStyle = radialAxisTextStyle;
    radialaxis.minorTickLabelTextStyle = nil;
    radialaxis.minorTickLength = 0.0;
    
    radialaxis.delegate = self;

    // Set axes
    graph.axisSet.axes = @[majorAxis, minorAxis, radialaxis];


    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor blackColor];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[CPTColor blueColor]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(10.0, 10.0);
    dataSourcePolarPlot1.plotSymbol = plotSymbol;

    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourcePolarPlot1.delegate                        = self;
    dataSourcePolarPlot1.plotSymbolMarginForHitDetection = 5.0;
    dataSourcePolarPlot2.delegate                        = self;
    dataSourcePolarPlot2.plotSymbolMarginForHitDetection = 5.0;

    // Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.textStyle       = majorAxis.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.legend.borderLineStyle = majorAxis.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake(0.0, 12.0);
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot
{
    if ([(NSString*)plot.identifier isEqualToString:@"Polar Source Plot"]) {
        return self.plotDatum[0].count;
    }
    else {
        return self.plotDatum[1].count;
    }
}

-(nullable id)numberForPlot:(nonnull CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num;
    NSString *key = (fieldEnum == CPTPolarPlotFieldRadialAngle ? @"theta" : @"radius");
    if ([(NSString*)plot.identifier isEqualToString:@"Polar Source Plot"]) {
        num = self.plotDatum[0][index][key];
    }
    else {
        num = self.plotDatum[1][index][key];
    }
    if( [key isEqualToString: @"theta"] && ((CPTPolarPlotSpace*)plot.plotSpace).radialAngleOption == CPTPolarRadialAngleModeDegrees) {
        num = [NSNumber numberWithDouble:[num doubleValue] / M_PI * 180.0];
    }

    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(nullable CPTPlotRange *)plotSpace:(nonnull CPTPlotSpace *)space willChangePlotRangeTo:(nonnull CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    // Impose a limit on how far user can scroll in x
    if ( coordinate == CPTCoordinateX || coordinate == CPTCoordinateY ) {
        CPTMutablePlotRange *maxRange            = [CPTMutablePlotRange plotRangeWithLocation:@(-2.125) length:@4.25];
        if( coordinate == CPTCoordinateY ) {
            NSDecimalNumber *ratio = [NSDecimalNumber decimalNumberWithDecimal: CPTDecimalDivide(self.graphs[0].plotAreaFrame.plotArea.heightDecimal, self.graphs[0].plotAreaFrame.plotArea.widthDecimal)];
            [maxRange expandRangeByFactor:ratio];
        }
        CPTMutablePlotRange *changedRange = [newRange mutableCopy];
        [changedRange shiftEndToFitInRange:maxRange];
        [changedRange shiftLocationToFitInRange:maxRange];
        newRange = changedRange;
    }

    return newRange;
}

#pragma mark -
#pragma mark CPTPolarPlot delegate methods

-(void)polarPlot:(nonnull CPTPolarPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    CPTPolarGraph *graph = (self.graphs)[0];

    CPTPolarPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        annotation = nil;
    }

    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor orangeColor];
    hitAnnotationTextStyle.fontSize = 16.0;
    hitAnnotationTextStyle.fontName = @"Helvetica";
    
    // Determine point of symbol in plot coordinates
    NSNumber *theta;
    NSNumber *radius;
    NSDictionary<NSString *, NSNumber *> *dataPoint;
    if ([(NSString*)plot.identifier isEqualToString:@"Polar Source Plot"]) {
        dataPoint = self.plotDatum[0][index];
        theta = dataPoint[@"theta"];
        radius = dataPoint[@"radius"];
    }
    else {
        dataPoint = self.plotDatum[1][index];
        theta = dataPoint[@"theta"];
        radius = dataPoint[@"radius"];
        double _theta = [theta doubleValue];
        double _radius = [radius doubleValue];
        if ( _theta < 0 ) {
            theta = [NSNumber numberWithDouble: 2.0 * M_PI + _theta];
        }
        if ( _radius < 0 ) {
            radius = [NSNumber numberWithDouble: fabs(_radius)];
            theta = [NSNumber numberWithDouble: M_PI + _theta];
        }
    }

    // Now add the annotation to the plot area
    CPTPolarPlotSpace *defaultSpace = (CPTPolarPlotSpace*)graph.defaultPlotSpace;
    
    if (defaultSpace.radialAngleOption == CPTPolarRadialAngleModeDegrees) {
        theta = [NSNumber numberWithDouble:[theta doubleValue] / M_PI * 180.0];
    }
    
    CPTNumberArray *anchorPoint = @[theta, radius];
    // Add annotation
    NSString *annotationString;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.maximumFractionDigits = 2;
    if( defaultSpace.radialAngleOption == CPTPolarRadialAngleModeRadians ) {
        PiNumberFormatter *piFormatter = [[PiNumberFormatter alloc] init];
        piFormatter.multiplier = @32;
        annotationString = [NSString stringWithFormat:@"%@rads, %@", [piFormatter stringFromNumber:theta], [formatter stringFromNumber:radius]];
    }
    else {
        annotationString = [NSString stringWithFormat:@"%@°, %@", [formatter stringFromNumber:theta], [formatter stringFromNumber:radius]];
    }
    
    if ( defaultSpace ) {
        CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:annotationString style:hitAnnotationTextStyle];
        annotation                = [[CPTPolarPlotSpaceAnnotation alloc] initWithPlotSpace:defaultSpace anchorPlotPoint:anchorPoint];
        annotation.contentLayer   = textLayer;
        annotation.displacement   = CGPointMake(0.0, 20.0);
        self.symbolTextAnnotation = annotation;
        [graph.plotAreaFrame.plotArea addAnnotation:annotation];
    }
}

-(void)polarPlotDataLineWasSelected:(nonnull CPTPolarPlot *)plot
{
    NSLog(@"polarPlotDataLineWasSelected: %@", plot);
}

-(void)polarPlotDataLineTouchDown:(nonnull CPTPolarPlot *)plot
{
    NSLog(@"polarPlotDataLineTouchDown: %@", plot);
}

-(void)polarPlotDataLineTouchUp:(nonnull CPTPolarPlot *)plot
{
    NSLog(@"polarPlotDataLineTouchUp: %@", plot);
}

#pragma mark -
#pragma mark Plot area delegate method

-(void)plotAreaWasSelected:(nonnull CPTPlotArea *)plotArea
{
    CPTPolarGraph *graph = (self.graphs)[0];

    if ( graph ) {
        // Remove the annotation
        CPTPolarPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

        if ( annotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
            self.symbolTextAnnotation = nil;
        }
        else {
            CPTPolarPlotInterpolation interpolation = CPTPolarPlotInterpolationCurved;

            // Decrease the histogram display option, and if < CPTScatterPlotHistogramNormal display linear graph
            if ( --self.curvedOption < CPTPolarPlotHistogramNormal ) {
                interpolation = CPTPolarPlotInterpolationLinear;

                // Set the histogram option to the count, as that is guaranteed to be the last available option + 1
                // (thus the next time the user clicks in the empty plot area the value will be decremented, becoming last option)
                self.curvedOption = CPTPolarPlotCurvedInterpolationHermiteCubic;
            }
            CPTPolarPlot *dataSourceLinePlot1 = (CPTPolarPlot *)[graph plotWithIdentifier:@"Polar Source Plot"];
            dataSourceLinePlot1.interpolation   = interpolation;
            dataSourceLinePlot1.curvedInterpolationOption = self.curvedOption;
            CPTPolarPlot *dataSourceLinePlot2 = (CPTPolarPlot *)[graph plotWithIdentifier:@"Polar Parametric Plot"];
            dataSourceLinePlot2.interpolation   = interpolation;
            dataSourceLinePlot2.curvedInterpolationOption = self.curvedOption;
        }
    }
}

@end
