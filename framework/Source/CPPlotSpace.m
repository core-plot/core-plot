
#import "CPPlotSpace.h"


@implementation CPPlotSpace

@synthesize plotArea;

-(void)dealloc
{
    self.plotArea = nil;
    [super dealloc];
}


@end
