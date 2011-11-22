//
//  PlotItem.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

typedef CGRect CGNSRect;

#else

#import <CorePlot/CorePlot.h>
typedef NSRect CGNSRect;

#endif

@class CPTGraph;
@class CPTTheme;

@interface PlotItem : NSObject
{
	CPTGraphHostingView *defaultLayerHostingView;

	NSMutableArray *graphs;
	NSString *title;
	CPTNativeImage *cachedImage;
}

@property (nonatomic, retain) CPTGraphHostingView *defaultLayerHostingView;
@property (nonatomic, retain) NSMutableArray *graphs;
@property (nonatomic, retain) NSString *title;

+(void)registerPlotItem:(id)item;

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
-(void)renderInView:(UIView *)hostingView withTheme:(CPTTheme *)theme;
#else
-(void)renderInView:(NSView *)hostingView withTheme:(CPTTheme *)theme;
-(void)setFrameSize:(NSSize)size;
#endif
-(CPTNativeImage *)image;

-(void)renderInLayer:(CPTGraphHostingView *)layerHostingView withTheme:(CPTTheme *)theme;

-(void)setTitleDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;
-(void)setPaddingDefaultsForGraph:(CPTGraph *)graph withBounds:(CGRect)bounds;

-(void)reloadData;
-(void)applyTheme:(CPTTheme *)theme toGraph:(CPTGraph *)graph withDefault:(CPTTheme *)defaultTheme;

-(void)addGraph:(CPTGraph *)graph;
-(void)addGraph:(CPTGraph *)graph toHostingView:(CPTGraphHostingView *)layerHostingView;
-(void)killGraph;

-(void)generateData;

-(NSComparisonResult)titleCompare:(PlotItem *)other;

@end
