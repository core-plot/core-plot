//
//  ContourPlot.m
//  CorePlotGallery
//
//  Created by Steve Wainwright on 14/12/2020.
//

#import "ContourPlot.h"


@interface ContourPlot()

@property (nonatomic, readwrite, strong, nullable) CPTGraph *graph;

@property (nonatomic, readwrite, strong) NSMutableSet<CPTFieldFunctionDataSource *> *dataSources;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
typedef UIFont CPTFont;
#else
typedef NSFont CPTFont;
#endif

-(nullable CPTFont *)italicFontForFont:(nonnull CPTFont *)oldFont;

@end

@implementation ContourPlot

@synthesize graph;
@synthesize dataSources;

+(void)load
{
    [super registerPlotItem:self];
}

-(nonnull instancetype)init
{
    if ( (self = [super init]) ) {
        graph    = nil;
        dataSources = [[NSMutableSet alloc] init];

        self.title   = @"Contour Plot";
        self.section = kFieldsPlots;
    }

    return self;
}

-(void)killGraph
{
    [self.dataSources removeAllObjects];

    [super killGraph];
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
    
#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:bounds];
    self.graph = newGraph;

    [self addGraph:newGraph toHostingView:hostingView];
    [self applyTheme:theme toGraph:newGraph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    newGraph.plotAreaFrame.masksToBorder = NO;

    // Instructions
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color    = [CPTColor whiteColor];
    textStyle.fontName = @"Helvetica";
    textStyle.fontSize = self.titleSize * CPTFloat(0.5);

    CGFloat ratio = self.graph.bounds.size.width / self.graph.bounds.size.height;
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)newGraph.defaultPlotSpace;
    if (ratio > 1) {
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-5.0 * ratio) length:@(10.0  * ratio)];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-5.0) length:@(10.0)];
    }
    else {
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:@(-5.0) length:@(10.0)];
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:@(-5.0 / ratio) length:@(10.0 / ratio)];
    }

    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)newGraph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength   = @(1.0);
    x.orthogonalPosition    = @(0.0);
    x.minorTicksPerInterval = 5;

    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength   = @1.0;
    y.minorTicksPerInterval = 5;
    y.orthogonalPosition    = @(0.0);

    // Contour properties
    
    // Create some function plots
    NSString *titleString          = @"sin(x)sin(y)";//@"0.5*(cos(x + π/4)+sin(y + π/4)";
    CPTContourDataSourceBlock block       = ^(double xVal, double yVal) {
//        return 0.5*(cos(xVal + M_PI_4)+sin(yVal + M_PI_4));
        return sin(xVal) * sin(yVal);
    };
        
    // Create a plot that uses the data source method
    CPTContourPlot *contourPlot = [[CPTContourPlot alloc] init];
    contourPlot.identifier = [NSString stringWithFormat:@"Function Contour Plot %lu", (unsigned long)(1)];

    CPTDictionary *textAttributes = x.titleTextStyle.attributes;

    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(titleString, @"")
                                                                                  attributes:textAttributes];

    CPTFont *fontAttribute = textAttributes[NSFontAttributeName];
    if ( fontAttribute ) {
        CPTFont *italicFont = [self italicFontForFont:fontAttribute];

        [title addAttribute:NSFontAttributeName
                      value:italicFont
                      range:NSMakeRange(0, 1)];
        [title addAttribute:NSFontAttributeName
                      value:italicFont
                      range:NSMakeRange(8, 1)];
    }

    CPTFont *labelFont = [CPTFont fontWithName:@"Helvetica" size:self.titleSize * CPTFloat(0.5)];
    [title addAttribute:NSFontAttributeName
                  value:labelFont
                  range:NSMakeRange(0, title.length)];

    contourPlot.attributedTitle = title;

    contourPlot.interpolation = CPTContourPlotInterpolationCurved;//CPTContourPlotInterpolationLinear;
    contourPlot.curvedInterpolationOption = CPTContourPlotCurvedInterpolationHermiteCubic;
    
    contourPlot.alignsPointsToPixels = YES;

    CPTFieldFunctionDataSource *plotDataSource  = [CPTFieldFunctionDataSource dataSourceForPlot:contourPlot withBlock:block];

    CGFloat resolution;
    if(ratio < 1.0) {
        resolution = self.graph.plotAreaFrame.plotArea.bounds.size.height * 0.02;
    }
    else {
        resolution = self.graph.plotAreaFrame.plotArea.bounds.size.width * 0.02;
    }
    plotDataSource.resolutionX = resolution;
    plotDataSource.resolutionY = resolution;

    [self.dataSources addObject:plotDataSource];
    
    contourPlot.noIsoCurves = 21;
    contourPlot.showLabels = NO;
    contourPlot.showIsoCurvesLabels = YES;
    
    contourPlot.dataSource = plotDataSource;
    contourPlot.contourAppearanceDataSource = self;
    contourPlot.delegate     = self;
    
    // isoCurve label appearance
    CPTMutableTextStyle *labelTextstyle = [[CPTMutableTextStyle alloc] init];
    labelTextstyle.fontName = @"Helvetica";
    labelTextstyle.fontSize = 15.0;
    labelTextstyle.textAlignment = CPTAlignmentCenter;
    labelTextstyle.color = nil;//[CPTColor lightGrayColor];
    contourPlot.isoCurvesLabelTextStyle = labelTextstyle;
    NSNumberFormatter *labelFormatter = [[NSNumberFormatter alloc] init];
    labelFormatter.maximumFractionDigits = 1;
    contourPlot.isoCurvesLabelFormatter = labelFormatter;

    // Add plot
    [newGraph addPlot:contourPlot];
 //   newGraph.defaultPlotSpace.delegate = self;

    // Add legend
    newGraph.legend                    = [CPTLegend legendWithGraph:newGraph];
    newGraph.legend.textStyle          = x.titleTextStyle;
    newGraph.legend.fill               = [CPTFill fillWithColor:[CPTColor clearColor]];
    newGraph.legend.borderLineStyle    = x.axisLineStyle;
    newGraph.legend.cornerRadius       = 5.0;
    newGraph.legend.swatchCornerRadius = 3.0;
    newGraph.legendAnchor              = CPTRectAnchorTop;
    newGraph.legendDisplacement        = CGPointMake(0.0, self.titleSize * CPTFloat(-2.0) - CPTFloat(12.0) );
}


#pragma mark -
#pragma mark Plot Space Delegate Methods

-(BOOL)plotSpace:(nonnull CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(nonnull CPTNativeEvent *)event atPoint:(CGPoint)point
{
    return NO;
}

#pragma mark -
#pragma mark Plot Delegate Methods

-(void)contourPlot:(nonnull CPTContourPlot *)plot contourWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Range for '%@' was selected at index %d.", plot.identifier, (int)index);
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(nullable UIFont *)italicFontForFont:(nonnull UIFont *)oldFont
{
    NSString *italicName = nil;

    CPTStringArray *fontNames = [UIFont fontNamesForFamilyName:oldFont.familyName];

    for ( NSString *fontName in fontNames ) {
        NSString *upperCaseFontName = fontName.uppercaseString;
        if ( [upperCaseFontName rangeOfString:@"ITALIC"].location != NSNotFound ) {
            italicName = fontName;
            break;
        }
    }
    if ( !italicName ) {
        for ( NSString *fontName in fontNames ) {
            NSString *upperCaseFontName = fontName.uppercaseString;
            if ( [upperCaseFontName rangeOfString:@"OBLIQUE"].location != NSNotFound ) {
                italicName = fontName;
                break;
            }
        }
    }

    UIFont *italicFont = nil;
    if ( italicName ) {
        italicFont = [UIFont fontWithName:italicName
                                     size:oldFont.pointSize];
    }
    return italicFont;
}

#else
-(nullable NSFont *)italicFontForFont:(nonnull NSFont *)oldFont
{
    return [[NSFontManager sharedFontManager] convertFont:oldFont
                                              toHaveTrait:NSFontItalicTrait];
}

#endif

#pragma mark -
#pragma mark Plot Appearance Source Methods

-(nullable CPTLineStyle *)lineStyleForContourPlot:(nonnull CPTContourPlot *)plot isoCurveIndex:(NSUInteger)idx {
    
    CPTMutableLineStyle *linestyle = [plot.contourLineStyle mutableCopy];
    linestyle.lineWidth = 2.0;

    linestyle.lineColor = [CPTColor colorWithComponentRed:(CGFloat)((float)(idx) / (float)(plot.noIsoCurves)) green:(CGFloat)(1.0f - (float)(idx) / (float)(plot.noIsoCurves)) blue:0.0 alpha:1.0];
    
    return linestyle;
}

-(nullable CPTLayer *)isoCurveLabelForPlot:(CPTContourPlot *)plot isoCurveIndex:(NSUInteger)idx {
    static CPTMutableTextStyle *lightGrayText = nil;
    static dispatch_once_t lightGrayOnceToken      = 0;
    
    dispatch_once(&lightGrayOnceToken, ^{
        lightGrayText          = [[CPTMutableTextStyle alloc] init];
        lightGrayText.color    = [CPTColor lightGrayColor];
        lightGrayText.fontSize = self.titleSize * CPTFloat(0.5);
    });
    
    CPTTextLayer *newLayer    = nil;
    CPTNumberArray *isoCurveValues = [plot getIsoCurveValues];
    if( isoCurveValues != nil && idx < isoCurveValues.count ) {
        NSNumberFormatter *formatter = (NSNumberFormatter*)plot.isoCurvesLabelFormatter;
        NSString *labelString = [formatter stringForObjectValue: isoCurveValues[idx]];
        if (plot.isoCurvesLabelTextStyle != nil) {
            if ( plot.isoCurvesLabelTextStyle.color == nil ) {
                CPTMutableTextStyle *mutLabelTextStyle = [CPTMutableTextStyle textStyleWithStyle: plot.isoCurvesLabelTextStyle];
                mutLabelTextStyle.color = [CPTColor colorWithComponentRed:(CGFloat)((float)idx / (float)([plot getIsoCurveValues].count)) green:(CGFloat)(1.0f - (float)idx / (float)([plot getIsoCurveValues].count)) blue:0.0 alpha:1.0];
                newLayer = [[CPTTextLayer alloc] initWithText:labelString style:mutLabelTextStyle];
            }
            else {
                newLayer = [[CPTTextLayer alloc] initWithText:labelString style:plot.isoCurvesLabelTextStyle];
            }
        }
        else {
            newLayer = [[CPTTextLayer alloc] initWithText:labelString style:lightGrayText];
        }
    }

    return newLayer;
}

- (NSUInteger)numberOfRecordsForPlot:(nonnull CPTPlot *)plot { 
    return 0;
}


@end
