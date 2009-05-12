
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"

@implementation CPAxisSet

@synthesize axes;
@synthesize plotSpace;

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

-(void)renderAsVectorInContext:(CGContextRef)theContext {
	for (CPAxis* axis in self.axes)
		[axis drawInContext:theContext withPlotSpace:self.plotSpace];
	
}


-(void)dealloc {
    self.axes = nil;
	self.plotSpace = nil;
	[super dealloc];
}

@end
