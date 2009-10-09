
#import "CPBorderedLayer.h"
#import "CPPathExtensions.h"
#import "CPLineStyle.h"
#import "CPFill.h"

@interface CPBorderedLayer ()

-(void)setMaskingPath:(CGPathRef)newPath;

@end


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
		borderLineStyle = nil;
		fill = nil;
		cornerRadius = 0.0f;
        maskingPath = NULL;

		self.needsDisplayOnBoundsChange = YES;
		self.masksToBounds = YES;
	}
	return self;
}

-(void)dealloc
{
	[borderLineStyle release];
    [fill release];
	CGPathRelease(maskingPath);
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
    CGPathRef roundedPath = [self maskingPath];
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
#pragma mark <CPMasking>

-(void)setMaskingPath:(CGPathRef)newPath 
{
    if ( newPath != maskingPath ) {
        CGPathRelease(maskingPath);
        maskingPath = CGPathRetain(newPath);
    }
}

-(CGPathRef)maskingPath 
{
	if ( maskingPath ) return maskingPath;
    
	CGFloat inset = round(self.borderLineStyle.lineWidth / 2.0f);
	CGRect selfBounds = CGRectInset(self.bounds, inset, inset);

	if ( self.cornerRadius > 0.0f ) {
		CGFloat radius = MIN(MIN(self.cornerRadius, selfBounds.size.width / 2), selfBounds.size.height / 2);
		[self setMaskingPath:CreateRoundedRectPath(selfBounds, radius)];
	}
	else {
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, selfBounds);
		[self setMaskingPath:path];
	}
    
    return maskingPath;
}

#pragma mark -
#pragma mark Mask Layer Delegate Methods

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
	CGContextSaveGState(context);
    CGContextAddPath(context, [self maskingPath]);
    CGContextClip(context);
    CGContextSetGrayFillColor(context, 0.0f, 1.0f);
    CGContextFillRect(context, layer.bounds);
    CGContextRestoreGState(context);
}

#pragma mark -
#pragma mark Accessors

-(void)setBounds:(CGRect)newBounds 
{
	[self setMaskingPath:NULL];
    [super setBounds:newBounds];    
}

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
