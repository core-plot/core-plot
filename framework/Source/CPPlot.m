
#import "CPPlot.h"
#import "CPPlotSpace.h"

@implementation CPPlot

@synthesize dataSource;
@synthesize identifier;
@synthesize plotSpace;

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	NSAttributedString* tempString = [[NSAttributedString alloc] initWithString:@"CPPlot" attributes:nil];
	NSDecimalNumber* x = [[[NSDecimalNumber alloc] initWithInt:2] autorelease];
	NSDecimalNumber* y = [[[NSDecimalNumber alloc] initWithInt:2] autorelease];
	
	[tempString drawAtPoint:NSPointFromCGPoint([plotSpace viewPointForPlotPoint:[NSArray arrayWithObjects:x,y,nil]])];
	[tempString release];
}

#pragma mark -
#pragma mark init/dealloc

-(id)init
{
	self = [super init];
	if (self != nil) {
		[self setNeedsDisplayOnBoundsChange:YES];
		[self setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
	}
	return self;
}

-(void)dealloc
{
    self.dataSource = nil;
    self.identifier = nil;
    self.plotSpace = nil;
    [super dealloc];
}


@end
