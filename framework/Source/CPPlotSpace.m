
#import "CPPlotSpace.h"
#import "CPPlotArea.h"

@implementation CPPlotSpace

@synthesize plotArea;
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
    self.plotArea = nil;
    [super dealloc];
}

@end
