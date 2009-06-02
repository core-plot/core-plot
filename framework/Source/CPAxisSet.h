
#import <Foundation/Foundation.h>
#import "CPLayer.h"

@class CPPlotSpace;
@class CPPlotArea;
@class CPGraph;

@interface CPAxisSet : CPLayer {
    NSArray *axes;
}

@property (nonatomic, readwrite, retain) NSArray *axes;

-(id)initWithFrame:(CGRect)frame;

-(void)positionInGraph:(CPGraph *)graph;

@end
