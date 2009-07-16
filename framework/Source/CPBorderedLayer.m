
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
    CGPathRef roundedPath = [self newMaskingPath];
	if ( self.fill ) {
		CGContextBeginPath(context);
        CGContextAddPath(context, roundedPath);
		[self.fill fillPathInContext:context];
	}
    if ( self.borderLineStyle ) {
		CGContextBeginPath(context);
        CGContextAddPath(context, roundedPath);
        [self.borderLineStyle setLineStyleInContext:context];
        CGContextStrokePath(context);
    }
    CGPathRelease(roundedPath);
}

-(CGPathRef)newMaskingPath 
{
    CGFloat inset = round(self.borderLineStyle.lineWidth*0.5 + 1.0f);
	CGRect selfBounds = CGRectInset(self.bounds, inset, inset);
    CGFloat radius = MIN(MIN(self.cornerRadius, selfBounds.size.width / 2), selfBounds.size.height / 2);
    return CreateRoundedRectPath(selfBounds, radius);
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

-(void)setCornerRadius:(CGFloat)newRadius
{
	if ( newRadius != cornerRadius ) {
		cornerRadius = ABS(newRadius);
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
