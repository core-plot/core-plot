#import "CPTAxisLabelGroup.h"

/**
 *	@brief A container layer for the axis labels.
 **/
@implementation CPTAxisLabelGroup

#pragma mark -
#pragma mark Drawing

///	@cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
	// nothing to draw
}

///	@endcond

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers
{
	// do nothing--axis is responsible for positioning its labels
}

@end
