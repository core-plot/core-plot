
#import "CPBorderedLayer.h"
#import "CPPathExtensions.h"
#import "CPLineStyle.h"
#import "CPFill.h"

/** @brief A layer with rounded corners.
 **/

@implementation CPBorderedLayer

/** @property borderLineStyle 
 *  @brief The line style for the layer border.
 *	If nil, the border is not drawn.
 **/
@synthesize borderLineStyle;

/** @property cornerRadius 
 *  @brief Radius for the rounded corners of the layer.
 **/
@synthesize cornerRadius;

/** @property fill 
 *  @brief The fill for the layer background.
 *	If nil, the layer background is not filled.
 **/
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
	[self.borderLineStyle release];
    [self.fill release];
	
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

#pragma mark -
#pragma mark <CPMasking>

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
