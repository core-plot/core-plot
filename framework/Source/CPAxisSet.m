
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"

@implementation CPAxisSet

@synthesize axes;

-(void)drawInContext:(CGContextRef)theContext withPlotSpace:(CPPlotSpace*)aPlotSpace {
	for (CPAxis* axis in self.axes)
		[axis drawInContext:theContext withPlotSpace:aPlotSpace];
	
}


-(void)dealloc {
    self.axes = nil;
	[super dealloc];
}

@end
