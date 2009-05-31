
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPFill.h"

@implementation CPPlotArea

@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		plotSpaces = [[NSMutableArray alloc] init];
//#if defined(TARGET_IPHONE_SIMULATOR) || defined(TARGET_OS_IPHONE)
//		// TODO: Add resizing code for iPhone
//#else
//		[self setAutoresizingMask:(kCALayerHeightSizable | kCALayerWidthSizable)];
//#endif
//		self.layerAutoresizingMask = kCPLayerWidthSizable | kCPLayerHeightSizable;
		self.layerAutoresizingMask = kCPLayerWidthSizable | kCPLayerMinXMargin | kCPLayerMaxXMargin | kCPLayerHeightSizable | kCPLayerMinYMargin | kCPLayerMaxYMargin;
		self.needsDisplayOnBoundsChange = YES;

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

#pragma mark -
#pragma mark Accessors

-(void)setFill:(CPFill *)newFill;
{
	if (newFill == fill) {
		return;
	}
	[fill release];
	fill = [newFill retain];
	[self setNeedsDisplay];
}

@end
