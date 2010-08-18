#import <Foundation/Foundation.h>
#import "CPAnnotation.h"

@class CPPlotSpace;

@interface CPPlotSpaceAnnotation : CPAnnotation {
	NSArray *anchorPlotPoint;
    CPPlotSpace *plotSpace;
}

@property (nonatomic, readwrite, copy) NSArray *anchorPlotPoint;
@property (nonatomic, readonly, retain) CPPlotSpace *plotSpace;

-(id)initWithPlotSpace:(CPPlotSpace *)space anchorPlotPoint:(NSArray *)plotPoint;

@end
