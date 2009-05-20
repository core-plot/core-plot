
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"

@implementation CPAxisSet

@synthesize axes;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if (self = [super init]) {
		self.axes = [NSArray array];		
	}
	return self;
}

-(void)dealloc {
    self.axes = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext {
	for (CPAxis *axis in self.axes) {
		[axis drawInContext:theContext];	
	}
}

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers 
{
    for ( CPAxis *axis in self.axes ) {
        [axis relabel];
    }
}

@end
