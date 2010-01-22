#import "CPLineStyle.h"
#import "CPPlotFrame.h"
#import "CPUtilities.h"

/** @brief A layer that draws a frame around the plotting area.
 **/
@implementation CPPlotFrame

/** @property borderLineStyle 
 *	@brief The line style for the layer border.
 *	If nil, the border is not drawn.
 **/
@synthesize borderLineStyle;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		borderLineStyle = nil;
		
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	[borderLineStyle release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.borderLineStyle ) {
		[super renderAsVectorInContext:context];
		
		CALayer *superlayer = self.superlayer;
		CGRect borderRect = CPAlignRectToUserSpace(context, [self convertRect:superlayer.bounds fromLayer:superlayer]);
		
		[self.borderLineStyle setLineStyleInContext:context];
		
		CGContextBeginPath(context);
		CGContextAddRect(context, borderRect);
		CGContextStrokePath(context);
	}
}

@end
