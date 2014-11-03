//
//  ImageDemo.m
//  Plot Gallery
//

#import "ImageDemo.h"

@implementation ImageDemo

+(void)load
{
    [super registerPlotItem:self];
}

-(id)init
{
    if ( (self = [super init]) ) {
        self.title   = @"Image Demo";
        self.section = kDemoPlots;
    }

    return self;
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    // Create graph
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTSlateTheme]];

    [self setTitleDefaultsForGraph:graph withBounds:bounds];
    [self setPaddingDefaultsForGraph:graph withBounds:bounds];

    graph.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];

    graph.plotAreaFrame.fill          = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.plotAreaFrame.paddingTop    = 20.0;
    graph.plotAreaFrame.paddingBottom = 50.0;
    graph.plotAreaFrame.paddingLeft   = 50.0;
    graph.plotAreaFrame.paddingRight  = 50.0;
    graph.plotAreaFrame.cornerRadius  = 10.0;

    graph.axisSet.axes = nil;

    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontSize      = 12.0;
    textStyle.fontName      = @"Helvetica";
    textStyle.textAlignment = CPTTextAlignmentCenter;

    CPTPlotArea *thePlotArea = graph.plotAreaFrame.plotArea;

    // Note
    CPTTextLayer *titleLayer = [[CPTTextLayer alloc] initWithText:@"Standard images have a blue tint.\nHi-res (@2x) images have a green tint and @3x images have a red tint."
                                                            style:textStyle];
    CPTLayerAnnotation *titleAnnotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:thePlotArea];
    titleAnnotation.rectAnchor         = CPTRectAnchorTop;
    titleAnnotation.contentLayer       = titleLayer;
    titleAnnotation.contentAnchorPoint = CGPointMake(0.5, 1.0);
    [thePlotArea addAnnotation:titleAnnotation];

    textStyle.color = [CPTColor darkGrayColor];

    // Tiled
    titleLayer = [[CPTTextLayer alloc] initWithText:@"Tiled image"
                                              style:textStyle];
    CPTImage *fillImage = [CPTImage imageNamed:@"Checkerboard"];
    fillImage.tiled          = YES;
    titleLayer.fill          = [CPTFill fillWithImage:fillImage];
    titleLayer.paddingLeft   = 25.0;
    titleLayer.paddingRight  = 25.0;
    titleLayer.paddingTop    = 100.0;
    titleLayer.paddingBottom = 5.0;

    CPTLayerAnnotation *annotation = [[CPTLayerAnnotation alloc] initWithAnchorLayer:thePlotArea];
    annotation.rectAnchor         = CPTRectAnchorBottomLeft;
    annotation.contentLayer       = titleLayer;
    annotation.contentAnchorPoint = CGPointMake(0.0, 0.0);
    [thePlotArea addAnnotation:annotation];

    // Stretched
    titleLayer = [[CPTTextLayer alloc] initWithText:@"Stretched image"
                                              style:textStyle];
    fillImage.tiled          = NO;
    titleLayer.fill          = [CPTFill fillWithImage:fillImage];
    titleLayer.paddingLeft   = 25.0;
    titleLayer.paddingRight  = 25.0;
    titleLayer.paddingTop    = 100.0;
    titleLayer.paddingBottom = 5.0;

    annotation                    = [[CPTLayerAnnotation alloc] initWithAnchorLayer:graph.plotAreaFrame.plotArea];
    annotation.rectAnchor         = CPTRectAnchorBottomRight;
    annotation.contentLayer       = titleLayer;
    annotation.contentAnchorPoint = CGPointMake(1.0, 0.0);
    [graph.plotAreaFrame.plotArea addAnnotation:annotation];
}

@end
