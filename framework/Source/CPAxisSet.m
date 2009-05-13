
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"

@implementation CPAxisSet

@synthesize axes;

-(id)init
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
	for (CPAxis* axis in self.axes) [axis drawInContext:theContext];
}

-(void)setBounds:(CGRect)bounds {
	// We need to stretch the bounds so our CGContext is big enough to draw outside the CPPlotSpace.
	bounds.origin.x = -kCPAxisExtend;
	bounds.origin.y = -kCPAxisExtend;
	bounds.size.width += kCPAxisExtend;
	bounds.size.height += kCPAxisExtend;
	
	// Make sure our origin coincides with the origin of the CPPlotSpace
	CGPoint ori = CGPointMake(kCPAxisExtend / bounds.size.width, kCPAxisExtend /bounds.size.height);
	self.anchorPoint = ori;
//	NSLog(@"CPAxisSet anchorPoint: %f, %f bounds: %f, %f %fx%f", ori.x, ori.y, bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
	[super setBounds:bounds];
	self.position = CGPointMake(0.0f, 0.0f);
}

-(void)dealloc {
    self.axes = nil;
	[super dealloc];
}

@end
