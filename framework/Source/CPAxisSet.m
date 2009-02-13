
#import "CPAxisSet.h"


@implementation CPAxisSet

@synthesize axes;

-(void)dealloc {
    self.axes = nil;
    [super dealloc];
}

@end
