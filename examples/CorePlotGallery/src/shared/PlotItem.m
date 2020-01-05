//
// PlotItem.m
// CorePlotGallery
//

#import "PlotGallery.h"

#import <tgmath.h>

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
#else
// For NSCollectionView
#import <Quartz/Quartz.h>
#endif

NSString *const kDemoPlots      = @"Demos";
NSString *const kPieCharts      = @"Pie Charts";
NSString *const kLinePlots      = @"Line Plots";
NSString *const kBarPlots       = @"Bar Plots";
NSString *const kFinancialPlots = @"Financial Plots";

@interface PlotItem()

@property (nonatomic, readwrite, strong) CPTNativeImage *cachedImage;

@end

#pragma mark -

@implementation PlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize section;
@synthesize title;
@synthesize cachedImage;
@dynamic titleSize;

+(void)registerPlotItem:(nonnull id)item
{
    NSLog(@"registerPlotItem for class %@", [item class]);

    Class itemClass = [item class];

    if ( itemClass ) {
        // There's no autorelease pool here yet...
        PlotItem *plotItem = [[itemClass alloc] init];
        if ( plotItem ) {
            [[PlotGallery sharedPlotGallery] addPlotItem:plotItem];
        }
    }
}

-(nonnull instancetype)init
{
    if ((self = [super init])) {
        defaultLayerHostingView = nil;

        graphs  = [[NSMutableArray alloc] init];
        section = @"";
        title   = @"";
    }

    return self;
}

-(void)addGraph:(nonnull CPTGraph *)graph toHostingView:(nullable CPTGraphHostingView *)hostingView
{
    [self.graphs addObject:graph];

    if ( hostingView ) {
        hostingView.hostedGraph = graph;
    }
}

-(void)addGraph:(nonnull CPTGraph *)graph
{
    [self addGraph:graph toHostingView:nil];
}

-(void)killGraph
{
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];

    // Remove the CPTLayerHostingView
    CPTGraphHostingView *hostingView = self.defaultLayerHostingView;
    if ( hostingView ) {
        [hostingView removeFromSuperview];

        hostingView.hostedGraph      = nil;
        self.defaultLayerHostingView = nil;
    }

    self.cachedImage = nil;

    [self.graphs removeAllObjects];
}

-(void)dealloc
{
    [self killGraph];
}

// override to generate data for the plot if needed
-(void)generateData
{
}

-(NSComparisonResult)titleCompare:(nonnull PlotItem *)other
{
    NSComparisonResult comparisonResult = [self.section caseInsensitiveCompare:other.section];

    if ( comparisonResult == NSOrderedSame ) {
        comparisonResult = [self.title caseInsensitiveCompare:other.title];
    }

    return comparisonResult;
}

-(CGFloat)titleSize
{
    CGFloat size;

#if TARGET_OS_TV
    size = 36.0;
#elif TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    switch ( UI_USER_INTERFACE_IDIOM()) {
        case UIUserInterfaceIdiomPad:
            size = 24.0;
            break;

        case UIUserInterfaceIdiomPhone:
            size = 16.0;
            break;

        default:
            size = 12.0;
            break;
    }
#else
    size = 24.0;
#endif

    return size;
}

-(void)setPaddingDefaultsForGraph:(nonnull CPTGraph *)graph
{
    CGFloat boundsPadding = self.titleSize;

    graph.paddingLeft = boundsPadding;

    if ( graph.titleDisplacement.y > CPTFloat(0.0)) {
        graph.paddingTop = graph.titleTextStyle.fontSize * CPTFloat(2.0);
    }
    else {
        graph.paddingTop = boundsPadding;
    }

    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
}

-(void)formatAllGraphs
{
    CGFloat graphTitleSize = self.titleSize;

    for ( CPTGraph *graph in self.graphs ) {
        // Title
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.color    = [CPTColor grayColor];
        textStyle.fontName = @"Helvetica-Bold";
        textStyle.fontSize = graphTitleSize;

        graph.title                    = (self.graphs.count == 1 ? self.title : nil);
        graph.titleTextStyle           = textStyle;
        graph.titleDisplacement        = CPTPointMake(0.0, textStyle.fontSize * CPTFloat(1.5));
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;

        // Padding
        CGFloat boundsPadding = graphTitleSize;
        graph.paddingLeft = boundsPadding;

        if ( graph.title.length > 0 ) {
            graph.paddingTop = MAX(graph.titleTextStyle.fontSize * CPTFloat(2.0), boundsPadding);
        }
        else {
            graph.paddingTop = boundsPadding;
        }

        graph.paddingRight  = boundsPadding;
        graph.paddingBottom = boundsPadding;

        // Axis labels
        CGFloat axisTitleSize = graphTitleSize * CPTFloat(0.75);
        CGFloat labelSize     = graphTitleSize * CPTFloat(0.5);

        for ( CPTAxis *axis in graph.axisSet.axes ) {
            // Axis title
            textStyle          = [axis.titleTextStyle mutableCopy];
            textStyle.fontSize = axisTitleSize;

            axis.titleTextStyle = textStyle;

            // Axis labels
            textStyle          = [axis.labelTextStyle mutableCopy];
            textStyle.fontSize = labelSize;

            axis.labelTextStyle = textStyle;

            textStyle          = [axis.minorTickLabelTextStyle mutableCopy];
            textStyle.fontSize = labelSize;

            axis.minorTickLabelTextStyle = textStyle;
        }

        // Plot labels
        for ( CPTPlot *plot in graph.allPlots ) {
            textStyle          = [plot.labelTextStyle mutableCopy];
            textStyle.fontSize = labelSize;

            plot.labelTextStyle = textStyle;
        }

        // Legend
        CPTLegend *theLegend = graph.legend;
        textStyle          = [theLegend.textStyle mutableCopy];
        textStyle.fontSize = labelSize;

        theLegend.textStyle  = textStyle;
        theLegend.swatchSize = CGSizeMake(labelSize * CPTFloat(1.5), labelSize * CPTFloat(1.5));

        theLegend.rowMargin    = labelSize * CPTFloat(0.75);
        theLegend.columnMargin = labelSize * CPTFloat(0.75);

        theLegend.paddingLeft   = labelSize * CPTFloat(0.375);
        theLegend.paddingTop    = labelSize * CPTFloat(0.375);
        theLegend.paddingRight  = labelSize * CPTFloat(0.375);
        theLegend.paddingBottom = labelSize * CPTFloat(0.375);
    }
}

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE

-(nonnull CPTNativeImage *)image
{
    if ( self.cachedImage == nil ) {
        CGRect imageFrame = CGRectMake(0, 0, 400, 300);
        UIView *imageView = [[UIView alloc] initWithFrame:imageFrame];
        [imageView setOpaque:YES];
        [imageView setUserInteractionEnabled:NO];

        [self renderInView:imageView withTheme:nil animated:NO];
        [imageView layoutIfNeeded];

        CGSize boundsSize = imageView.bounds.size;

        UIGraphicsBeginImageContextWithOptions(boundsSize, YES, 0.0);

        CGContextRef context = UIGraphicsGetCurrentContext();

        CGContextSetAllowsAntialiasing(context, true);

        for ( UIView *subView in imageView.subviews ) {
            if ( [subView isKindOfClass:[CPTGraphHostingView class]] ) {
                CPTGraphHostingView *hostingView = (CPTGraphHostingView *)subView;
                CGRect frame                     = hostingView.frame;

                CGContextSaveGState(context);

                CGContextTranslateCTM(context, frame.origin.x, frame.origin.y + frame.size.height);
                CGContextScaleCTM(context, 1.0, -1.0);
                [hostingView.hostedGraph layoutAndRenderInContext:context];

                CGContextRestoreGState(context);
            }
        }

        CGContextSetAllowsAntialiasing(context, false);

        self.cachedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    return self.cachedImage;
}

#else // OSX

-(nonnull CPTNativeImage *)image
{
    if ( self.cachedImage == nil ) {
        CGRect imageFrame = CGRectMake(0, 0, 400, 300);

        NSView *imageView = [[NSView alloc] initWithFrame:NSRectFromCGRect(imageFrame)];
        [imageView setWantsLayer:YES];

        [self renderInView:imageView withTheme:nil animated:NO];

        CGSize boundsSize = imageFrame.size;

        NSBitmapImageRep *layerImage = [imageView bitmapImageRepForCachingDisplayInRect:imageFrame];
        layerImage.size = boundsSize;
        [imageView cacheDisplayInRect:imageFrame toBitmapImageRep:layerImage];

        self.cachedImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
        [self.cachedImage addRepresentation:layerImage];
    }

    return self.cachedImage;
}

#endif

-(void)applyTheme:(nullable CPTTheme *)theme toGraph:(nonnull CPTGraph *)graph withDefault:(nullable CPTTheme *)defaultTheme
{
    if ( theme == nil ) {
        [graph applyTheme:defaultTheme];
    }
    else if ( ![theme isKindOfClass:[NSNull class]] ) {
        [graph applyTheme:theme];
    }
}

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
#else
-(void)setFrameSize:(NSSize __unused)size
{
}

#endif

-(void)renderInView:(nonnull PlotGalleryNativeView *)inView withTheme:(nullable CPTTheme *)theme animated:(BOOL)animated
{
    [self killGraph];

    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:inView.bounds];

    [inView addSubview:hostingView];

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
    hostingView.translatesAutoresizingMaskIntoConstraints = NO;
    [inView addConstraint:[NSLayoutConstraint constraintWithItem:hostingView
                                                       attribute:NSLayoutAttributeLeft
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:inView
                                                       attribute:NSLayoutAttributeLeft
                                                      multiplier:1.0
                                                        constant:0.0]];
    [inView addConstraint:[NSLayoutConstraint constraintWithItem:hostingView
                                                       attribute:NSLayoutAttributeTop
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:inView
                                                       attribute:NSLayoutAttributeTop
                                                      multiplier:1.0
                                                        constant:0.0]];
    [inView addConstraint:[NSLayoutConstraint constraintWithItem:hostingView
                                                       attribute:NSLayoutAttributeRight
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:inView
                                                       attribute:NSLayoutAttributeRight
                                                      multiplier:1.0
                                                        constant:0.0]];
    [inView addConstraint:[NSLayoutConstraint constraintWithItem:hostingView
                                                       attribute:NSLayoutAttributeBottom
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:inView
                                                       attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                        constant:0.0]];
#else
    hostingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [hostingView setAutoresizesSubviews:YES];
#endif

    [self generateData];
    [self renderInGraphHostingView:hostingView withTheme:theme animated:animated];

    [self formatAllGraphs];

    self.defaultLayerHostingView = hostingView;
}

-(void)renderInGraphHostingView:(nonnull CPTGraphHostingView *__unused)hostingView withTheme:(nullable CPTTheme *__unused)theme animated:(BOOL __unused)animated
{
    NSLog(@"PlotItem:renderInLayer: Override me");
}

-(void)reloadData
{
    for ( CPTGraph *graph in self.graphs ) {
        [graph reloadData];
    }
}

#pragma mark -
#pragma mark IKImageBrowserItem methods

#if TARGET_OS_SIMULATOR || TARGET_OS_IPHONE
#else

-(NSString *)imageUID
{
    return self.title;
}

-(NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

-(id)imageRepresentation
{
    return [self image];
}

-(NSString *)imageTitle
{
    return self.title;
}

#endif

@end
