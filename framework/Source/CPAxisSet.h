
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPPlotSpace;
@class CPPlotArea;
@class CPGraph;

@interface CPAxisSet : CPLayer {
	@private
    NSArray *axes;
	CPGraph	*graph;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, assign) CPGraph *graph;

-(void)relabelAxes;

@end
