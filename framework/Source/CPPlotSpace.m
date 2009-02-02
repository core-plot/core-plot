
#import "CPPlotSpace.h"
#import "CPPlotArea.h"

@implementation CPPlotSpace

@synthesize plotArea;


-(void)dealloc
{
    self.plotArea = nil;
    [super dealloc];
}


@end
