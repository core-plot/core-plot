
#import "CPPlotSpace.h"
#import "CPPlotArea.h"
#import "CPAxisSet.h"

@implementation CPPlotSpace

@synthesize identifier;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if (self = [super initWithFrame:newFrame]) {
		self.layerAutoresizingMask = kCPLayerWidthSizable | kCPLayerHeightSizable;		
	}
	return self;
}

-(void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark Layout

+(CGFloat)defaultZPosition 
{
	return CPDefaultZPositionPlotSpace;
}

@end
