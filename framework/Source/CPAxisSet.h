
#import <Foundation/Foundation.h>
#import "CPLayer.h"


@class CPPlotSpace;

@interface CPAxisSet : CPLayer {
    NSArray *axes;
	CPPlotSpace* plotSpace;
}

@property (nonatomic, readwrite, retain) NSArray *axes;
@property (nonatomic, readwrite, retain) CPPlotSpace* plotSpace;

-(void)renderAsVectorInContext:(CGContextRef)theContext;


@end
