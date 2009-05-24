
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
    [axes release];
	[super dealloc];
}

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers 
{
    for ( CPAxis *axis in self.axes ) {
        axis.bounds = self.bounds;
        axis.anchorPoint = CGPointZero;
        axis.position = self.bounds.origin;
    }
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
            [self addSublayer:axis];
        }
        [self setNeedsLayout];
    }
}

@end
