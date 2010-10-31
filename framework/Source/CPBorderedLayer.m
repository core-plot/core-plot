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

/** @property fill 
 *  @brief The fill for the layer background.
 *	If nil, the layer background is not filled.
 **/
@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

-(id)initWithFrame:(CGRect)newFrame
{
	if ( self = [super initWithFrame:newFrame] ) {
		borderLineStyle = nil;
		fill = nil;

		self.masksToBorder = YES;
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

-(id)initWithLayer:(id)layer
{
	if ( self = [super initWithLayer:layer] ) {
		CPBorderedLayer *theLayer = (CPBorderedLayer *)layer;
		
		borderLineStyle = [theLayer->borderLineStyle retain];
		fill = [theLayer->fill retain];
	}
	return self;
}

-(void)dealloc
{
	[borderLineStyle release];
    [fill release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)renderAsVectorInContext:(CGContextRef)context
{
	[super renderAsVectorInContext:context];
	
	BOOL useMask = self.masksToBounds;
	self.masksToBounds = YES;
	CGContextBeginPath(context);
	CGContextAddPath(context, self.maskingPath);
	[self.fill fillPathInContext:context];
	self.masksToBounds = useMask;
	
    if ( self.borderLineStyle ) {
		CGFloat inset = self.borderLineStyle.lineWidth / 2.0;
		CGRect selfBounds = CGRectInset(self.bounds, inset, inset);
		
        [self.borderLineStyle setLineStyleInContext:context];

		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN(MIN(self.cornerRadius, selfBounds.size.width / 2.0), selfBounds.size.height / 2.0);
			CGContextBeginPath(context);
			AddRoundedRectPath(context, selfBounds, radius);
			CGContextStrokePath(context);
		}
		else {
			CGContextStrokeRect(context, selfBounds);
		}
    }
}

#pragma mark -
#pragma mark Masking

-(CGPathRef)maskingPath 
{
	if ( self.masksToBounds ) {
		CGPathRef path = self.outerBorderPath;
		if ( path ) return path;
		
		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		CGRect selfBounds = self.bounds;
		
		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN(MIN(self.cornerRadius + lineWidth / 2.0, selfBounds.size.width / 2.0), selfBounds.size.height / 2.0);
			path = CreateRoundedRectPath(selfBounds, radius);
			self.outerBorderPath = path;
			CGPathRelease(path);
		}
		else {
			CGMutablePathRef mutablePath = CGPathCreateMutable();
			CGPathAddRect(mutablePath, NULL, selfBounds);
			self.outerBorderPath = mutablePath;
			CGPathRelease(mutablePath);
		}
		
		return self.outerBorderPath;
	}
	else {
		return NULL;
	}
}

-(CGPathRef)sublayerMaskingPath 
{
	if ( self.masksToBorder ) {
		CGPathRef path = self.innerBorderPath;
		if ( path ) return path;
		
		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		CGRect selfBounds = CGRectInset(self.bounds, lineWidth, lineWidth);
		
		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN(MIN(self.cornerRadius - lineWidth / 2.0, selfBounds.size.width / 2.0), selfBounds.size.height / 2.0);
			path = CreateRoundedRectPath(selfBounds, radius);
			self.innerBorderPath = path;
			CGPathRelease(path);
		}
		else {
			CGMutablePathRef mutablePath = CGPathCreateMutable();
			CGPathAddRect(mutablePath, NULL, selfBounds);
			self.innerBorderPath = mutablePath;
			CGPathRelease(mutablePath);
		}
		
		return self.innerBorderPath;
	}
	else {
		return NULL;
	}
}

#pragma mark -
#pragma mark Line style delegate

-(void)lineStyleDidChange:(CPLineStyle *)lineStyle
{
	[super lineStyleDidChange:lineStyle];
	
	if ( lineStyle == self.borderLineStyle ) {
		self.outerBorderPath = NULL;
		self.innerBorderPath = NULL;
	}
}

#pragma mark -
#pragma mark Accessors

-(void)setBorderLineStyle:(CPLineStyle *)newLineStyle
{
	if ( newLineStyle != borderLineStyle ) {
		if ( newLineStyle.lineWidth != borderLineStyle.lineWidth ) {
			self.outerBorderPath = NULL;
			self.innerBorderPath = NULL;
		}
		borderLineStyle.delegate = nil;
		[borderLineStyle release];
		borderLineStyle = [newLineStyle copy];
		borderLineStyle.delegate = self;
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
