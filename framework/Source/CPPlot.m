
#import "CPPlot.h"


@implementation CPPlot

@synthesize dataSource;
@synthesize identifier;
@synthesize plotSpace;

-(void)dealloc
{
    self.dataSource = nil;
    self.identifier = nil;
    self.plotSpace = nil;
    [super dealloc];
}


@end
