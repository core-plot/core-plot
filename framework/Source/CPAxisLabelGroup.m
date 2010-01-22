#import "CPAxisLabelGroup.h"

@implementation CPAxisLabelGroup

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	// nothing to draw
}

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers
{
	// do nothing--axis is responsible for positioning its labels
}

@end
