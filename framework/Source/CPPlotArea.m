
#import "CPPlotArea.h"
#import "CPPlotSpace.h"

@implementation CPPlotArea

// Temporary method just to show something...
- (void)drawInContext:(CGContextRef)theContext
{
	NSAttributedString* tempString = [[NSAttributedString alloc] initWithString:@"CPPlotArea" attributes:nil];
	[tempString drawAtPoint:NSMakePoint(10.f, 10.f)];
	[tempString release];
}

#pragma mark getters/setters
- (void) setBounds:(CGRect)rect
{
	for (CALayer* plot in [self sublayers])
		[plot setBounds:rect];
	
	// Shouldn't our plotSpaces also be sublayers? They are...
//	for (CPPlotSpace* plotSpace in plotSpaces)
//		[plotSpace setBounds:rect];
	
	[super setBounds:rect];
};


- (void) setFrame:(CGRect)rect
{
	for (CALayer* plot in [self sublayers])
		[plot setFrame:rect];
	
	[super setFrame:rect];
};

#pragma mark init/dealloc
- (id) init
{
	self = [super init];
	if (self != nil) {
		plotSpaces = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[plotSpaces release];
	[super dealloc];
}


@end
