
#import "CPPlotSpace.h"
#import "CPPlotArea.h"

@implementation CPPlotSpace

@synthesize plotArea;
@synthesize transformToView;
@synthesize transformToPlot;

- (void) setPlotArea: (CPPlotArea*) newPlotArea
{
  plotArea = newPlotArea;
  
  //Need to update the transform as it relied on the min and max x,y points
  transformToView = [self calculateTransformToView];
  transformToPlot = CGAffineTransformInvert(transformToView);
}

- (CGAffineTransform) calculateTransformToView
{
  //The default transform does nothing
  return CGAffineTransformIdentity;
}

- (id) init
{
  self = [super init];
  if (self != nil) {
    transformToView = CGAffineTransformIdentity;
    transformToPlot = CGAffineTransformIdentity;
    plotArea = nil;
  }
  return self;
}

-(void)dealloc
{
    self.plotArea = nil;
    [super dealloc];
}


@end
