
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPPlotSpace;
@class CPPlotArea;
@class CPGraph;

@interface CPAxisSet : CPLayer {
	CPLayer *overlayLayer;
	CGFloat overlayLayerInsetX, overlayLayerInsetY;
    NSArray *axes;
	CPGraph	*graph;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, retain) CPLayer *overlayLayer;
@property (nonatomic, readwrite, assign) CPGraph *graph;
@property (nonatomic, readwrite, assign) CGFloat overlayLayerInsetX, overlayLayerInsetY;

@end
