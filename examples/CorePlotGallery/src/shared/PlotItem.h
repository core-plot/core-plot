//
//  PlotItem.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

typedef CGRect CGNSRect;

#else

#import <CorePlot/CorePlot.h>
typedef CPLayerHostingView CPGraphHostingView;

typedef NSRect CGNSRect;

#endif

@class CPGraph;
@class CPTheme;

@interface PlotItem : NSObject
{
    CPGraphHostingView  *defaultLayerHostingView;

    NSMutableArray      *graphs;
    NSString            *title;

#if TARGET_OS_IPHONE
    UIImage             *cachedImage;
#else
    NSImage             *cachedImage;
#endif
}

#if TARGET_OS_IPHONE
@property (nonatomic, retain) CPGraphHostingView *defaultLayerHostingView;
#else
@property (nonatomic, retain) CPLayerHostingView *defaultLayerHostingView;
#endif

@property (nonatomic, retain) NSMutableArray *graphs;
@property (nonatomic, retain) NSString *title;

+ (void)registerPlotItem:(id)item;

#if TARGET_OS_IPHONE
- (void)renderInView:(UIView *)hostingView withTheme:(CPTheme *)theme;
- (UIImage *)image;
#else
- (void)renderInView:(NSView *)hostingView withTheme:(CPTheme *)theme;
- (NSImage *)image;
- (void)setFrameSize:(NSSize)size;
#endif


- (void)renderInLayer:(CPGraphHostingView *)layerHostingView withTheme:(CPTheme *)theme;

- (void)setTitleDefaultsForGraph:(CPGraph *)graph withBounds:(CGRect)bounds;
- (void)setPaddingDefaultsForGraph:(CPGraph *)graph withBounds:(CGRect)bounds;

- (void)reloadData;
- (void)applyTheme:(CPTheme *)theme toGraph:(CPGraph *)graph withDefault:(CPTheme *)defaultTheme;

- (void)addGraph:(CPGraph *)graph;
- (void)addGraph:(CPGraph *)graph toHostingView:(CPGraphHostingView *)layerHostingView;
- (void)killGraph;

- (NSComparisonResult)titleCompare:(PlotItem *)other;

@end
