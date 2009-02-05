
#import "CPAxisSet.h"


@implementation CPAxisSet

@synthesize plotArea;
@synthesize axes;

-(void)dealloc {
    self.plotArea = nil;
    self.axes = nil;
    [super dealloc];
}

@end
