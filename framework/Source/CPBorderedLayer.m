
#import "CPBorderedLayer.h"
#import "CPPathExtensions.h"
#import "CPLineStyle.h"
#import "CPFill.h"

@implementation CPBorderedLayer

@synthesize borderLineStyle;
@synthesize cornerRadius;
@synthesize fill;

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
    self.fill = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
    CGFloat inset = round(self.borderLineStyle.lineWidth*0.5 + 1.0f);
    CGContextBeginPath(context);
    AddRoundedRectPath(context, CGRectInset(self.bounds, inset, inset), self.cornerRadius);
    [self.fill fillPathInContext:context];
    if ( self.borderLineStyle ) {
        [self.borderLineStyle setLineStyleInContext:context];
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

-(void)setFill:(CPFill *)newFill
{
	if ( newFill != fill ) {
		[fill release];
		fill = [newFill copy];
		[self setNeedsDisplay];
	}
}

@end
