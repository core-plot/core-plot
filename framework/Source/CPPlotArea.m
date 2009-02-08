
#import "CPPlotArea.h"
#import "CPPlotSpace.h"

@implementation CPPlotArea

#pragma mark Init/Dealloc
-(id)init
{
	self = [super init];
	if (self != nil) {
		plotSpaces = [[NSMutableArray alloc] init];
		self.needsDisplayOnBoundsChange = YES;
		[self setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
	}
	return self;
}

-(void)dealloc
{
	[plotSpaces release];
	[super dealloc];
}

#pragma mark Drawing
-(void)drawInContext:(CGContextRef)theContext
{
    // Temporary method just to show something...
	NSAttributedString* tempString = [[NSAttributedString alloc] initWithString:@"CPPlotArea" attributes:nil];
	[tempString drawAtPoint:NSMakePoint(10.f, 10.f)];
	[tempString release];
}

@end
