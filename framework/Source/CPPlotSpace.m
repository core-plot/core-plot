
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"

@implementation CPPlotSpace

@synthesize identifier;

#pragma mark -
#pragma mark Init/Dealloc

- (id) init
{
	self = [super init];
	if (self != nil) {

#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
		// TODO: Add resizing code for iPhone
#else
		[self setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
#endif
		
	}
	return self;
}

-(void)dealloc
{
    [super dealloc];
}

@end
