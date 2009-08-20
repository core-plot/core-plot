//
//  CorePlotQCPlugInPlugIn.h
//  CorePlotQCPlugIn
//
//  Created by Caleb Cannon on 8/3/09.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>
#import <CorePlot/CorePlot.h>

@interface CorePlotQCPlugIn : QCPlugIn <CPPlotDataSource>
{	
	NSUInteger numberOfPlots;
	BOOL configurationCheck;
	
	void *imageData;
	CGContextRef bitmapContext;
	id<QCPlugInOutputImageProvider> imageProvider;
	CPGraph *graph;
}

/*
Declare here the Obj-C 2.0 properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property(assign) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@property(assign) id<QCPlugInOutputImageProvider> outputImage;

@property(assign) NSUInteger numberOfPlots;

@property(assign) NSUInteger inputPixelsWide;
@property(assign) NSUInteger inputPixelsHigh;

@property(assign) NSUInteger inputTopMargin;
@property(assign) NSUInteger inputBottomMargin;
@property(assign) NSUInteger inputLeftMargin;
@property(assign) NSUInteger inputRightMargin;

@property(assign) CGColorRef inputBackgroundColor;
@property(assign) CGColorRef inputPlotAreaColor;
@property(assign) CGColorRef inputBorderColor;

@property(assign) CGColorRef inputAxisColor;
@property(assign) double inputAxisLineWidth;
@property(assign) double inputAxisMajorTickWidth;
@property(assign) double inputAxisMinorTickWidth;
@property(assign) double inputAxisMajorTickLength;
@property(assign) double inputAxisMinorTickLength;
@property(assign) double inputMajorGridLineWidth;
@property(assign) double inputMinorGridLineWidth;

@property(assign) NSUInteger inputXMajorIntervals;
@property(assign) NSUInteger inputYMajorIntervals;
@property(assign) NSUInteger inputXMinorIntervals;
@property(assign) NSUInteger inputYMinorIntervals;

@property(assign) double inputXMin;
@property(assign) double inputXMax;
@property(assign) double inputYMin;
@property(assign) double inputYMax;

- (void) createGraph;
- (void) addPlots:(NSUInteger)count;
- (void) addPlotWithIndex:(NSUInteger)index;
- (void) removePlots:(NSUInteger)count;
- (BOOL) configureGraph;
- (BOOL) configurePlots;
- (BOOL) configureAxis;

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot;
- (CGColorRef) defaultColorForPlot:(NSUInteger)index alpha:(float)alpha;

- (void) freeResources;

- (CGColorRef) dataLineColor:(NSUInteger)index;
- (CGFloat) dataLineWidth:(NSUInteger)index;
- (CGColorRef) areaFillColor:(NSUInteger)index;
- (CGImageRef) areaFillImage:(NSUInteger)index;

@end
