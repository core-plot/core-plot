
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPPlotSpace;
@class CPPlotArea;
@class CPGraph;

@interface CPAxisSet : CPLayer {
	@private
    NSArray *axes;
}

@property (nonatomic, readwrite, retain) NSArray *axes;

-(void)relabelAxes;

@end
