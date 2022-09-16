//
// ImageDemo.m
// Plot Gallery
//

#import "ImageDemo.h"

@implementation ImageDemo

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        self.title   = @"Image Demo";
        self.section = kDemoPlots;
    }

    return self;
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *)hostingView withTheme:(nullable CPTTheme *)theme animated:(BOOL __unused)animated
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

    graph.fill = [CPTFill fillWithColor:[CPTColor darkGrayColor]];

    graph.plotAreaFrame.fill          = [CPTFill fillWithColor:[CPTColor lightGrayColor]];
    graph.plotAreaFrame.paddingTop    = self.titleSize;
    graph.plotAreaFrame.paddingBottom = self.titleSize * CPTFloat(2.0);
    graph.plotAreaFrame.paddingLeft   = self.titleSize * CPTFloat(2.0);
    graph.plotAreaFrame.paddingRight  = self.titleSize * CPTFloat(2.0);
    graph.plotAreaFrame.cornerRadius  = self.titleSize * CPTFloat(2.0);

    graph.axisSet.axes = nil;

    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.fontName      = @"Helvetica";
    textStyle.fontSize      = self.titleSize * CPTFloat(0.5);
    textStyle.textAlignment = CPTTextAlignmentCenter;

    CPTPlotArea *thePlotArea = graph.plotAreaFrame.plotArea;

    // Note
    CPTTextLayer *titleLayer = [[CPTTextLayer alloc] initWithText:@"Standard images have a blue tint.\nHi-res (@2x) images have a green tint.\n@3x images have a red tint."
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
    titleLayer.paddingLeft   = self.titleSize;
    titleLayer.paddingRight  = self.titleSize;
    titleLayer.paddingTop    = self.titleSize * CPTFloat(4.0);
    titleLayer.paddingBottom = self.titleSize * CPTFloat(0.25);

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
    titleLayer.paddingLeft   = self.titleSize;
    titleLayer.paddingRight  = self.titleSize;
    titleLayer.paddingTop    = self.titleSize * CPTFloat(4.0);
    titleLayer.paddingBottom = self.titleSize * CPTFloat(0.25);

    CPTLayer *anchorLayer = graph.plotAreaFrame.plotArea;
    if ( anchorLayer ) {
        annotation                    = [[CPTLayerAnnotation alloc] initWithAnchorLayer:anchorLayer];
        annotation.rectAnchor         = CPTRectAnchorBottomRight;
        annotation.contentLayer       = titleLayer;
        annotation.contentAnchorPoint = CGPointMake(1.0, 0.0);
        [graph.plotAreaFrame.plotArea addAnnotation:annotation];
    }
}

@end
