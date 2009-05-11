
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"

@implementation CPPlotSpace

@synthesize identifier;
@synthesize axisSet;

#pragma mark -
#pragma mark Init/Dealloc

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
	self.axisSet = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark AxisSet Management

//-(void)setAxisSet:(CPAxisSet*)aAxisSet
//{
//	if (axisSet != aAxisSet)
//	{
//		[aAxisSet retain];
//		[axisSet removeFromSuperlayer];
//		[axisSet release];
//		axisSet = aAxisSet;
//		[self addSublayer:axisSet];
//		axisSet.frame = self.bounds;
//	}
//}
//

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[axisSet drawInContext:theContext withPlotSpace:self];
}

@end
