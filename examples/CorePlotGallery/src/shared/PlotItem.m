//
//  PlotItem.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/4/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotGallery.h"

#import <tgmath.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
// For IKImageBrowser
#import <Quartz/Quartz.h>
#endif

NSString *const kDemoPlots      = @"Demos";
NSString *const kPieCharts      = @"Pie Charts";
NSString *const kLinePlots      = @"Line Plots";
NSString *const kBarPlots       = @"Bar Plots";
NSString *const kFinancialPlots = @"Financial Plots";

@implementation PlotItem

@synthesize defaultLayerHostingView;
@synthesize graphs;
@synthesize section;
@synthesize title;

+(void)registerPlotItem:(id)item
{
    NSLog(@"registerPlotItem for class %@", [item class]);

    Class itemClass = [item class];

    if ( itemClass ) {
        // There's no autorelease pool here yet...
        PlotItem *plotItem = [[itemClass alloc] init];
        if ( plotItem ) {
            [[PlotGallery sharedPlotGallery] addPlotItem:plotItem];
            [plotItem release];
        }
    }
}

-(id)init
{
    if ( (self = [super init]) ) {
        defaultLayerHostingView = nil;
        graphs                  = [[NSMutableArray alloc] init];
        section                 = nil;
        title                   = nil;
    }

    return self;
}

-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView
{
    [graphs addObject:graph];

    if ( layerHostingView ) {
        layerHostingView.hostedGraph = graph;
    }
}

-(void)addGraph:(CPTGraph *)graph
{
    [self addGraph:graph toHostingView:nil];
}

-(void)killGraph
{
    [[CPTAnimation sharedInstance] removeAllAnimationOperations];

    // Remove the CPTLayerHostingView
    if ( defaultLayerHostingView ) {
        [defaultLayerHostingView removeFromSuperview];

        defaultLayerHostingView.hostedGraph = nil;
        [defaultLayerHostingView release];
        defaultLayerHostingView = nil;
    }

    [cachedImage release];
    cachedImage = nil;

    [graphs removeAllObjects];
}

-(void)dealloc
{
    [self killGraph];
    [title release];
    [section release];

    [super dealloc];
}

// override to generate data for the plot if needed
-(void)generateData
{
}

-(NSComparisonResult)titleCompare:(PlotItem *)other
{
    NSComparisonResult comparisonResult = [self.section caseInsensitiveCompare:other.section];

    if ( comparisonResult == NSOrderedSame ) {
        comparisonResult = [self.title caseInsensitiveCompare:other.title];
    }

    return comparisonResult;
}

-(void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
    graph.title = self.title;
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color                = [CPTColor grayColor];
    textStyle.fontName             = @"Helvetica-Bold";
    textStyle.fontSize             = round( bounds.size.height / CPTFloat(20.0) );
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CPTPointMake( 0.0, textStyle.fontSize * CPTFloat(1.5) );
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
}

-(void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds
{
    CGFloat boundsPadding = round( bounds.size.width / CPTFloat(20.0) ); // Ensure that padding falls on an integral pixel

    graph.paddingLeft = boundsPadding;

    if ( graph.titleDisplacement.y > 0.0 ) {
        graph.paddingTop = graph.titleTextStyle.fontSize * 2.0;
    }
    else {
        graph.paddingTop = boundsPadding;
    }

    graph.paddingRight  = boundsPadding;
    graph.paddingBottom = boundsPadding;
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

-(UIImage *)image
{
    if ( cachedImage == nil ) {
        CGRect imageFrame = CGRectMake(0, 0, 400, 300);
        UIView *imageView = [[UIView alloc] initWithFrame:imageFrame];
        [imageView setOpaque:YES];
        [imageView setUserInteractionEnabled:NO];

        [self renderInView:imageView withTheme:nil animated:NO];

        CGSize boundsSize = imageView.bounds.size;

        if ( UIGraphicsBeginImageContextWithOptions ) {
            UIGraphicsBeginImageContextWithOptions(boundsSize, YES, 0.0);
        }
        else {
            UIGraphicsBeginImageContext(boundsSize);
        }

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

        cachedImage = UIGraphicsGetImageFromCurrentImageContext();
        [cachedImage retain];
        UIGraphicsEndImageContext();

        [imageView release];
    }

    return cachedImage;
}

#else // OSX

-(NSImage *)image
{
    if ( cachedImage == nil ) {
        CGRect imageFrame = CGRectMake(0, 0, 400, 300);

        NSView *imageView = [[NSView alloc] initWithFrame:NSRectFromCGRect(imageFrame)];
        [imageView setWantsLayer:YES];

        [self renderInView:imageView withTheme:nil animated:NO];

        CGSize boundsSize = imageFrame.size;

        NSBitmapImageRep *layerImage = [[NSBitmapImageRep alloc]
                                        initWithBitmapDataPlanes:NULL
                                                      pixelsWide:boundsSize.width
                                                      pixelsHigh:boundsSize.height
                                                   bitsPerSample:8
                                                 samplesPerPixel:4
                                                        hasAlpha:YES
                                                        isPlanar:NO
                                                  colorSpaceName:NSCalibratedRGBColorSpace
                                                     bytesPerRow:(NSInteger)boundsSize.width * 4
                                                    bitsPerPixel:32];

        NSGraphicsContext *bitmapContext = [NSGraphicsContext graphicsContextWithBitmapImageRep:layerImage];
        CGContextRef context             = (CGContextRef)[bitmapContext graphicsPort];

        CGContextClearRect( context, CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height) );
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldSmoothFonts(context, false);
        [imageView.layer renderInContext:context];
        CGContextFlush(context);

        cachedImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(boundsSize)];
        [cachedImage addRepresentation:layerImage];
        [layerImage release];

        [imageView release];
    }

    return cachedImage;
}
#endif

-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme
{
    if ( theme == nil ) {
        [graph applyTheme:defaultTheme];
    }
    else if ( ![theme isKindOfClass:[NSNull class]] ) {
        [graph applyTheme:theme];
    }
}

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
-(void)setFrameSize:(NSSize)size
{
}
#endif

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#else
-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
#endif
{
    [self killGraph];

    defaultLayerHostingView = [[CPTGraphHostingView alloc] initWithFrame:hostingView.bounds];

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    defaultLayerHostingView.collapsesLayers = NO;
    [defaultLayerHostingView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
#else
    [defaultLayerHostingView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
#endif
    [defaultLayerHostingView setAutoresizesSubviews:YES];

    [hostingView addSubview:defaultLayerHostingView];
    [self generateData];
    [self renderInLayer:defaultLayerHostingView withTheme:theme animated:animated];
}

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
    NSLog(@"PlotItem:renderInLayer: Override me");
}

-(void)reloadData
{
    for ( CPTGraph *g in graphs ) {
        [g reloadData];
    }
}

#pragma mark -
#pragma mark IKImageBrowserItem methods

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
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

/*
 * - (NSString*)imageSubtitle
 * {
 *  return graph.title;
 * }
 */
#endif

@end
