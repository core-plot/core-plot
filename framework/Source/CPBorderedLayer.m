
#import "CPBorderedLayer.h"
#import "CPPathExtensions.h"
#import "CPLineStyle.h"

@implementation CPBorderedLayer

@synthesize borderLineStyle;
@synthesize cornerRadius;

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	self.borderLineStyle = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.borderLineStyle ) {
		CGFloat inset = self.borderLineStyle.lineWidth*0.5 + 1.0f;
		[self.borderLineStyle setLineStyleInContext:context];
		CGContextBeginPath(context);
		AddRoundedRectPath(context, CGRectInset(self.bounds, inset, inset), self.cornerRadius);
		CGContextStrokePath(context);
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setBorderLineStyle:(CPLineStyle *)newLineStyle
{
	if ( newLineStyle != borderLineStyle ) {
		[borderLineStyle release];
		borderLineStyle = [newLineStyle copy];
		[self setNeedsDisplay];
	}
}

@end
