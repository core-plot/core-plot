
#import "CPPlotArea.h"
#import "CPPlotSpace.h"

@implementation CPPlotArea

#pragma mark Init/Dealloc
-(id)init
{
	if ( self = [super init] ) {
		plotSpaces = [[NSMutableArray alloc] init];
        self.autoresizingMask = (kCALayerHeightSizable | kCALayerWidthSizable);
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
    // Temporary: fill bounds
    CGContextSetGrayFillColor(theContext, 0.2, 0.3);
    CGContextFillRect(theContext, self.bounds); 
}

@end
