
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

/** @property masksToBorder 
 *  @brief If YES (the default), a sublayer mask is applied to clip sublayer content to the inside of the border.
 **/
@synthesize masksToBorder;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		borderLineStyle = nil;
		fill = nil;
		cornerRadius = 0.0f;
		outerBorderPath = NULL;
		innerBorderPath = NULL;
		masksToBorder = YES;

		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(void)dealloc
{
	[borderLineStyle release];
    [fill release];
	CGPathRelease(outerBorderPath);
	CGPathRelease(innerBorderPath);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	[super renderAsVectorInContext:context];
	
	[self.fill fillRect:self.bounds inContext:context];
    if ( self.borderLineStyle ) {
		CGFloat inset = self.borderLineStyle.lineWidth / 2;
		CGRect selfBounds = CGRectInset(self.bounds, inset, inset);
		
        [self.borderLineStyle setLineStyleInContext:context];
		CGContextBeginPath(context);

		if ( self.cornerRadius > 0.0f ) {
			CGFloat radius = MIN(MIN(self.cornerRadius, selfBounds.size.width / 2), selfBounds.size.height / 2);
			AddRoundedRectPath(context, selfBounds, radius);
		}
		else {
			CGContextAddRect(context, selfBounds);
		}

        CGContextStrokePath(context);
    }
}

#pragma mark -
#pragma mark Layout

-(void)layoutSublayers
{
	// This is where we do our custom replacement for the Mac-only layout manager and autoresizing mask
	// Subclasses should override to lay out their own sublayers
	// TODO: create a generic layout manager akin to CAConstraintLayoutManager ("struts and springs" is not flexible enough)
	// Sublayers fill the super layer's bounds minus any padding by default
	CGRect selfBounds = self.bounds;
	CGSize subLayerSize = selfBounds.size;
	CGFloat lineWidth = self.borderLineStyle.lineWidth;
	
	subLayerSize.width -= self.paddingLeft + self.paddingRight + lineWidth;
	subLayerSize.width = MAX(subLayerSize.width, 0.0f);
	subLayerSize.height -= self.paddingTop + self.paddingBottom + lineWidth;
	subLayerSize.height = MAX(subLayerSize.height, 0.0f);
	
	for (CALayer *subLayer in self.sublayers) {
		CGRect subLayerBounds = subLayer.bounds;
		subLayerBounds.size = subLayerSize;
		subLayer.bounds = subLayerBounds;
		subLayer.anchorPoint = CGPointZero;
		subLayer.position = CGPointMake(selfBounds.origin.x + self.paddingLeft, selfBounds.origin.y	+ self.paddingBottom);
	}
}

#pragma mark -
#pragma mark Masking

-(CGPathRef)maskingPath 
{
	if ( outerBorderPath ) return outerBorderPath;
	
	CGPathRelease(outerBorderPath);

	CGFloat lineWidth = self.borderLineStyle.lineWidth;
	CGRect selfBounds = self.bounds;
	
	if ( self.cornerRadius > 0.0f ) {
		CGFloat radius = MIN(MIN(self.cornerRadius + lineWidth / 2, selfBounds.size.width / 2), selfBounds.size.height / 2);
		outerBorderPath = CreateRoundedRectPath(selfBounds, radius);
	}
	else {
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, selfBounds);
		outerBorderPath = path;
	}
	
	return outerBorderPath;
}

-(CGPathRef)sublayerMaskingPath 
{
	if ( self.masksToBorder ) {
		if ( innerBorderPath ) return innerBorderPath;
		
		CGPathRelease(innerBorderPath);
		
		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		CGRect selfBounds = CGRectInset(self.bounds, lineWidth, lineWidth);
		
		if ( self.cornerRadius > 0.0f ) {
			CGFloat radius = MIN(MIN(self.cornerRadius - lineWidth / 2, selfBounds.size.width / 2), selfBounds.size.height / 2);
			innerBorderPath = CreateRoundedRectPath(selfBounds, radius);
		}
		else {
			CGMutablePathRef path = CGPathCreateMutable();
			CGPathAddRect(path, NULL, selfBounds);
			innerBorderPath = path;
		}
		
		return innerBorderPath;
	}
	else {
		return NULL;
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setBorderLineStyle:(CPLineStyle *)newLineStyle
{
	if ( newLineStyle != borderLineStyle ) {
		if ( newLineStyle.lineWidth != borderLineStyle.lineWidth ) {
			CGPathRelease(innerBorderPath);
			innerBorderPath = NULL;
		}
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
		
		CGPathRelease(outerBorderPath);
		outerBorderPath = NULL;
		CGPathRelease(innerBorderPath);
		innerBorderPath = NULL;
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

-(void)setBounds:(CGRect)newBounds
{
	[super setBounds:newBounds];
	CGPathRelease(outerBorderPath);
	outerBorderPath = NULL;
	CGPathRelease(innerBorderPath);
	innerBorderPath = NULL;
}

@end
