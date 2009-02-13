
#import "CPPlotSpace.h"
#import "CPPlotArea.h"

@implementation CPPlotSpace

@synthesize identifier;

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
	}
	return self;
}

-(void)dealloc
{
    [super dealloc];
}

@end
