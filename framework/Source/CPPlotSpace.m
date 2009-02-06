
#import "CPPlotSpace.h"
#import "CPPlotArea.h"

@implementation CPPlotSpace

@synthesize plotArea;
@synthesize identifier;


-(void)dealloc
{
    self.plotArea = nil;
    [super dealloc];
}

-(void)setFrame:(CGRect)rect
{
	for (CALayer* layer in self.sublayers)
		[layer setFrame:rect];

	[super setFrame:rect];
}

@end
