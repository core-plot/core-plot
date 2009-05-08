
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPFill.h"

@implementation CPPlotArea

@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

-(id)init
{
	if ( self = [super init] ) {
		plotSpaces = [[NSMutableArray alloc] init];
        self.autoresizingMask = (kCALayerHeightSizable | kCALayerWidthSizable);
		self.fill = nil;
	}
	return self;
}

-(void)dealloc
{
	[plotSpaces release];
	[fill release];
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)theContext
{
	[self.fill fillRect:self.bounds inContext:theContext];
}

@end
