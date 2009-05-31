
#import "CPAxisSet.h"
#import "CPPlotSpace.h"
#import "CPAxis.h"

@implementation CPAxisSet

@synthesize axes;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.axes = [NSArray array];
		self.layerAutoresizingMask = kCPLayerWidthSizable | kCPLayerHeightSizable;

	}
	return self;
}

-(void)dealloc {
    [axes release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

-(void)setAxes:(NSArray *)newAxes 
{
    if ( newAxes != axes ) {
        for ( CPAxis *axis in axes ) {
            [axis removeFromSuperlayer];
        }
        [axes release];
        axes = [newAxes retain];
        for ( CPAxis *axis in axes ) {
			axis.bounds = self.bounds;
            [self addSublayer:axis];
			axis.anchorPoint = CGPointZero;
			axis.position = self.bounds.origin;
			[axis setNeedsDisplay];
        }
//        [self setNeedsLayout];
    }
}

@end
