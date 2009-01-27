
#import "CPPlot.h"


@implementation CPPlot

@synthesize dataSource;
@synthesize identifier;

-(void)dealloc
{
    self.dataSource = nil;
    self.identifier = nil;
    [super dealloc];
}


@end
