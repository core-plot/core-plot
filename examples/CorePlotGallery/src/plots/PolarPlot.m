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

@property (nonatomic, readwrite, assign) CPTScaleType radialScaleType;
@property (nonatomic, readwrite, assign) CPTPolarRadialAngleMode angleMode;

@property (nonatomic, readwrite, strong, nonnull) PiNumberFormatter *piFormatter;
@property (nonatomic, readwrite, strong, nonnull) NSNumberFormatter *formatter;

@end

@implementation PolarPlot

@synthesize symbolTextAnnotation;
@synthesize plotDatum;
@synthesize curvedOption;

@synthesize radialScaleType, angleMode;
@synthesize piFormatter, formatter;

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
        self.radialScaleType = CPTScaleTypeLinear;
        self.angleMode = CPTPolarRadialAngleModeDegrees;
        
        self.piFormatter = [[PiNumberFormatter alloc] init];
        self.formatter = [[NSNumberFormatter alloc] init];
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
            [contentArray1 addObject:@{ @"theta": theta, @"radius": radius } ];
        }
        
        NSMutableArray<NSDictionary *> *contentArray2 = [NSMutableArray array];
        double t = 0.0;
        for ( NSUInteger i = 0; i < 49; i++ ) {
            NSNumber *theta = @( M_PI_4 - sin(t) );
            NSNumber *radius = @( 0.5 + 1.5 * cos(3.0 * t) );
            [contentArray2 addObject:@{ @"theta": theta, @"radius": radius } ];
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
    plotSpace.radialAngleOption = self.angleMode;
    
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
    majorAxis.minorTicksPerInterval = 9;
    majorAxis.majorGridLineStyle    = majorGridLineStyle;
    majorAxis.minorGridLineStyle    = minorGridLineStyle;

    majorAxis.title         = @"Radius";
    majorAxis.titleOffset   = 30.0;
    majorAxis.titleLocation = @1.25;
    majorAxis.delegate = self;

    // Label minor with an automatic label policy.
    CPTPolarAxis *minorAxis = axisSet.minorAxis;
    minorAxis.labelingPolicy              = CPTAxisLabelingPolicyFixedInterval;
    minorAxis.majorIntervalLength = @1;
    minorAxis.minorTicksPerInterval       = 9;
    minorAxis.majorGridLineStyle          = majorGridLineStyle;
    minorAxis.minorGridLineStyle          = minorGridLineStyle;
    minorAxis.labelOffset                 = 10.0;

    minorAxis.title         = @"Radius";
    minorAxis.titleOffset   = 30.0;
    minorAxis.titleLocation = @1.25;
    minorAxis.delegate = self;
    
    // RADIAL AXIS ie polar  in degrees
    CPTPolarAxis *radialaxis = axisSet.radialAxis;
    if( plotSpace.radialAngleOption == CPTPolarRadialAngleModeRadians) {
        self.piFormatter.multiplier = @16;
        radialaxis.labelFormatter = self.piFormatter;
        radialaxis.majorIntervalLength = [NSNumber numberWithDouble: M_PI / 8.0];
    }
    else {
        self.formatter.maximumFractionDigits = 1;
        radialaxis.labelFormatter = self.formatter;
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
//    radialAxisTextStyle.color = [[CPTColor colorWithGenericGray:CPTFloat(0.5)] colorWithAlphaComponent:CPTFloat(0.8)];
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
    plotSymbol.size               = CGSizeMake(5.0, 5.0);
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
    graph.legend.fill            = [CPTFill fillWithColor:[[CPTColor lightGrayColor] colorWithAlphaComponent:0.5]];
    graph.legend.borderLineStyle = majorAxis.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake(0.0, 12.0);
    graph.legend.numberOfRows    = graph.allPlots.count;
    graph.legend.delegate        = self;
    // in order to place the correct index in the Legend Entry must assign otherwise index = 0
    NSUInteger index = 0;
    NSMutableArray *legendEntries = [graph.legend getLegendEntries];
    for(CPTLegendEntry *legendEntry in legendEntries) {
        legendEntry.index = index;
        index++;
    }
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName      = @"Helvetica";
    textStyle.fontSize      = self.titleSize * CPTFloat(0.4);
    textStyle.textAlignment = CPTTextAlignmentCenter;

    CPTPlotArea *thePlotArea = graph.plotAreaFrame.plotArea;

    // Note
    CPTTextLayer *explanationLayer = [[CPTTextLayer alloc] initWithText:@"Tap on a radial angle label to toggle between degress & radians.\nTap on major/minor axis label to toggle between linear scale and log-modulus."
                                                            style:textStyle];
    CPTLayerAnnotation *explantionAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:thePlotArea];
    explantionAnnotation.rectAnchor         = CPTRectAnchorTop;
    explantionAnnotation.contentLayer       = explanationLayer;
    explantionAnnotation.contentAnchorPoint = CGPointMake(0.5, 1.0);
    [thePlotArea addAnnotation:explantionAnnotation];
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
    if( [key isEqualToString: @"theta"] && self.angleMode == CPTPolarRadialAngleModeDegrees) {
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
        if (self.radialScaleType == CPTScaleTypeLinear) {
            CPTMutablePlotRange *maxRange            = [CPTMutablePlotRange plotRangeWithLocation:@(-4.5) length:@8.5];
            if( coordinate == CPTCoordinateY ) {
                NSDecimalNumber *ratio = [NSDecimalNumber decimalNumberWithDecimal: CPTDecimalDivide(self.graphs[0].plotAreaFrame.plotArea.heightDecimal, self.graphs[0].plotAreaFrame.plotArea.widthDecimal)];
                [maxRange expandRangeByFactor:ratio];
            }
            CPTMutablePlotRange *changedRange = [newRange mutableCopy];
            [changedRange shiftEndToFitInRange:maxRange];
            [changedRange shiftLocationToFitInRange:maxRange];
            newRange = changedRange;
        }
        else {
            double maxXPow = pow(10.0, ceil(CPTLogModulus(2.125)));
            CPTMutablePlotRange *maxRange = [CPTMutablePlotRange plotRangeWithLocation:[NSNumber numberWithDouble: -maxXPow * 100.0] length:[NSNumber numberWithDouble: 200.0 * maxXPow]];
            if( coordinate == CPTCoordinateY ) {
                NSDecimalNumber *ratio = [NSDecimalNumber decimalNumberWithDecimal: CPTDecimalDivide(self.graphs[0].plotAreaFrame.plotArea.heightDecimal, self.graphs[0].plotAreaFrame.plotArea.widthDecimal)];
                [maxRange expandRangeByFactor:ratio];
            }
            CPTMutablePlotRange *changedRange = [newRange mutableCopy];
            [changedRange shiftEndToFitInRange:maxRange];
            [changedRange shiftLocationToFitInRange:maxRange];
            newRange = changedRange;
        }
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
        if (self.angleMode == CPTPolarRadialAngleModeDegrees) {
            double _theta = [theta doubleValue] * 180.0 / M_PI;
            theta = [NSNumber numberWithDouble:_theta];;
        }
        radius = dataPoint[@"radius"];
    }
    else {
        dataPoint = self.plotDatum[1][index];
        theta = dataPoint[@"theta"];
        radius = dataPoint[@"radius"];
        double _theta = [theta doubleValue];
        if (self.angleMode == CPTPolarRadialAngleModeDegrees) {
            _theta *= 180.0 / M_PI;
        }
        double _radius = [radius doubleValue];
        if ( _theta < 0 ) {
            if (self.angleMode == CPTPolarRadialAngleModeRadians) {
                theta = [NSNumber numberWithDouble: 2.0 * M_PI + _theta];
            }
            else {
                theta = [NSNumber numberWithDouble: 360.0 + _theta];
            }
        }
        if ( _radius < 0 ) {
            radius = [NSNumber numberWithDouble: fabs(_radius)];
            if (self.angleMode == CPTPolarRadialAngleModeRadians) {
                theta = [NSNumber numberWithDouble: M_PI + _theta];
            }
            else {
                theta = [NSNumber numberWithDouble: 180.0 + _theta];
            }
        }
    }

    // Now add the annotation to the plot area
    CPTPolarPlotSpace *defaultSpace = (CPTPolarPlotSpace*)graph.defaultPlotSpace;
    
    CPTNumberArray *anchorPoint = @[theta, radius];
    // Add annotation
    NSString *annotationString;
    self.formatter.maximumFractionDigits = 2;
    if( self.angleMode == CPTPolarRadialAngleModeRadians ) {
        self.piFormatter.multiplier = @32;
        annotationString = [NSString stringWithFormat:@"%@rads, %@", [self.piFormatter stringFromNumber:theta], [self.formatter stringFromNumber:radius]];
        self.piFormatter.multiplier = @16;
    }
    else {
        annotationString = [NSString stringWithFormat:@"%@°, %@", [self.formatter stringFromNumber:theta], [self.formatter stringFromNumber:radius]];
    }
    self.formatter.maximumFractionDigits = 1;
    
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

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(CPTNumberSet *)locations {

    NSNumberFormatter *axisFormatter = (NSNumberFormatter*)axis.labelFormatter;
    CGFloat labelOffset = axis.labelOffset;
    CGFloat labelRotation = axis.labelRotation;
    NSSet<NSNumber*> *_locations = locations;
    
    if (axis.coordinate == CPTCoordinateZ) {
        NSMutableSet<NSNumber*> *newLocations = [[NSMutableSet alloc] init]; // get rid of 180/pi from location as already got 0
        for (NSNumber *tickLocation in locations) {
            if (self.angleMode == CPTPolarRadialAngleModeRadians) {
                if ([tickLocation doubleValue] == 2.0 * M_PI) {
                    continue;
                }
            }
            else {
                if ([tickLocation doubleValue] == 360.0) {
                    continue;
                }
            }
            [newLocations addObject:tickLocation];
        }
        _locations = [NSSet setWithSet: newLocations];
        
        if ([axisFormatter isKindOfClass: [PiNumberFormatter class]]) {
            ((PiNumberFormatter*)axisFormatter).multiplier = @16;
        }
    }
    NSMutableSet<CPTAxisLabel*> *newLabels = [[NSMutableSet alloc] init];
    for (NSNumber *tickLocation in _locations) {
        NSNumber *adjustedTickLocation = tickLocation;
        NSString *labelString;
        if ( axis.coordinate == CPTCoordinateZ ) {
            if ( self.angleMode == CPTPolarRadialAngleModeRadians ) {
                labelString = [(PiNumberFormatter*)axisFormatter stringFromNumber: tickLocation];
            }
            else {
                labelString = [NSString stringWithFormat:@"%@°", [axisFormatter stringFromNumber:tickLocation]];
                adjustedTickLocation = [NSNumber numberWithDouble:[tickLocation doubleValue] / 180.0 * M_PI];
            }
        }
        else {
            if ([tickLocation doubleValue] < 0.0 ) {
                labelString = [axisFormatter stringFromNumber: [NSNumber numberWithDouble: -[tickLocation doubleValue]]];
            }
            else {
//                if ( [tickLocation doubleValue] == 0.0 && ((CPTPolarPlotSpace*)axis.plotSpace).majorScaleType == CPTScaleTypeLogModulus) {
//                    labelString = @"1";
//                }
//                else {
                    labelString = [axisFormatter stringFromNumber: tickLocation];
//                }
            }
        }
        CPTTextLayer *newLabelLayer = [[CPTTextLayer alloc] initWithText: labelString style: axis.labelTextStyle];
        
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithContentLayer: newLabelLayer];
        newLabel.tickLocation = adjustedTickLocation;
        
        newLabel.offset = labelOffset;
        newLabel.rotation = labelRotation;
        [newLabels addObject: newLabel];
        
    }
    axis.axisLabels = newLabels;
    return FALSE;
}
    
-(void)axis:(nonnull CPTAxis *)axis labelWasSelected:(nonnull CPTAxisLabel *)label {
    if (axis.coordinate == CPTCoordinateZ) {
        [self changeRadialAngleMode];
    }
    else {
        [self changeRadialScale];
    }
}

- (void) changeRadialAngleMode {
    
    if (self.plotDatum.count > 0) {
        CPTGraph *graph = (self.graphs)[0];
        CPTPolarPlotSpace *plotSpace = (CPTPolarPlotSpace *)graph.defaultPlotSpace;
        
        self.angleMode = (self.angleMode == CPTPolarRadialAngleModeRadians) ? CPTPolarRadialAngleModeDegrees : CPTPolarRadialAngleModeRadians;
        
        CPTPolarAxisSet *axisSet = (CPTPolarAxisSet *)graph.axisSet;
        // RADIAL AXIS ie polar  in degrees
        CPTPolarAxis *radialaxis = axisSet.radialAxis;
        radialaxis.axisLabels = nil;
        [radialaxis relabel];
        if( self.angleMode == CPTPolarRadialAngleModeRadians) {
            self.piFormatter.multiplier = @16;
            radialaxis.labelFormatter = self.piFormatter;
            radialaxis.majorIntervalLength = [NSNumber numberWithDouble: M_PI / 8.0];
        }
        else {
            
            self.formatter.maximumFractionDigits = 1;
            radialaxis.labelFormatter = self.formatter;
            radialaxis.majorIntervalLength = @22.5;
        }
        [radialaxis relabel];
        plotSpace.radialAngleOption = self.angleMode;
    }
}

- (void) changeRadialScale {
    CPTGraph *graph = (self.graphs)[0];
    CPTPolarPlotSpace *plotSpace = (CPTPolarPlotSpace *)graph.defaultPlotSpace;
    
    self.radialScaleType = (self.radialScaleType == CPTScaleTypeLinear) ? CPTScaleTypeLogModulus :  CPTScaleTypeLinear;
    CPTPolarAxisSet *axisSet = (CPTPolarAxisSet *)graph.axisSet;
    axisSet.radialAxis.axisLabels = nil;
    [axisSet.radialAxis relabel];
    
    axisSet.majorAxis.majorTickLocations = nil;
    axisSet.majorAxis.minorTickLocations = nil;
    axisSet.minorAxis.majorTickLocations = nil;
    axisSet.minorAxis.minorTickLocations = nil;
    
    if (self.radialScaleType == CPTScaleTypeLogModulus) {
//        plotSpace.centrePosition = [CPTNumberArray arrayWithObjects:@1, @1, nil];
        double maxXPow = pow(10.0, ceil(CPTLogModulus(2.125)));
        CPTMutablePlotRange *majorRange = [CPTMutablePlotRange plotRangeWithLocation:[NSNumber numberWithDouble: -maxXPow * 10.0] length:[NSNumber numberWithDouble: 20.0 * maxXPow]];
        NSDecimalNumber *ratio = [NSDecimalNumber decimalNumberWithDecimal: CPTDecimalDivide(graph.plotAreaFrame.plotArea.heightDecimal, graph.plotAreaFrame.plotArea.widthDecimal)];
        CPTMutablePlotRange *minorRange = [majorRange mutableCopy];
        [minorRange expandRangeByFactor:ratio];
        
        plotSpace.majorRange = majorRange;
        plotSpace.minorRange = minorRange;
        
        axisSet.majorAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
        axisSet.minorAxis.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
 
        axisSet.radialAxis.radialLabelLocation = [NSNumber numberWithDouble: plotSpace.majorRange.midPointDouble + plotSpace.majorRange.lengthDouble * 0.4];
    }
    else {
        CPTMutablePlotRange *majorRange = [CPTMutablePlotRange plotRangeWithLocation:@-2.125 length:@4.25];
        NSDecimalNumber *ratio = [NSDecimalNumber decimalNumberWithDecimal: CPTDecimalDivide(graph.plotAreaFrame.plotArea.heightDecimal, graph.plotAreaFrame.plotArea.widthDecimal)];
        CPTMutablePlotRange *minorRange = [majorRange mutableCopy];
        [minorRange expandRangeByFactor:ratio];
        
        plotSpace.majorRange = majorRange;
        plotSpace.minorRange = minorRange;
        
        axisSet.majorAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
        axisSet.minorAxis.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
        axisSet.minorAxis.minorTicksPerInterval = 9;
        
        axisSet.radialAxis.radialLabelLocation = [NSNumber numberWithDouble: plotSpace.majorRange.midPointDouble + plotSpace.majorRange.lengthDouble * 0.5];
    }
    plotSpace.majorScaleType = self.radialScaleType;
    plotSpace.minorScaleType = self.radialScaleType;
    [graph reloadData];
}

#pragma mark -
#pragma mark Legend Delegate Methods

-(void)legend:(nonnull CPTLegend *)legend legendEntryForPlot:(nonnull CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)idx {
    NSLog(@"Legend Entry for plot: %@, index: %ld", (NSString*)plot.identifier, idx);
}

@end
