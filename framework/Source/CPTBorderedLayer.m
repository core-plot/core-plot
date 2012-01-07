#import "CPTBorderedLayer.h"

#import "CPTFill.h"
#import "CPTLineStyle.h"
#import "CPTPathExtensions.h"

/**
 *	@brief A layer with a border line and background fill.
 *
 *	Sublayers will be positioned and masked so that the border line remains visible.
 **/
@implementation CPTBorderedLayer

/** @property borderLineStyle
 *  @brief The line style for the layer border.
 *
 *	If <code>nil</code>, the border is not drawn.
 **/
@synthesize borderLineStyle;

/** @property fill
 *  @brief The fill for the layer background.
 *
 *	If <code>nil</code>, the layer background is not filled.
 **/
@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

///	@name Initialization
///	@{

/** @brief Initializes a newly allocated CPTBorderedLayer object with the provided frame rectangle.
 *
 *	This is the designated initializer. The initialized layer will have the following properties:
 *	- @link CPTBorderedLayer::borderLineStyle borderLineStyle @endlink = <code>nil</code>
 *	- @link CPTBorderedLayer::fill fill @endlink = <code>nil</code>
 *	- @link CPTLayer::masksToBorder masksToBorder @endlink = <code>YES</code>
 *	- <code>needsDisplayOnBoundsChange</code> = <code>YES</code>
 *
 *	@param newFrame The frame rectangle.
 *  @return The initialized CPTBorderedLayer object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
	if ( (self = [super initWithFrame:newFrame]) ) {
		borderLineStyle = nil;
		fill			= nil;

		self.masksToBorder				= YES;
		self.needsDisplayOnBoundsChange = YES;
	}
	return self;
}

///	@}

-(id)initWithLayer:(id)layer
{
	if ( (self = [super initWithLayer:layer]) ) {
		CPTBorderedLayer *theLayer = (CPTBorderedLayer *)layer;

		borderLineStyle = [theLayer->borderLineStyle retain];
		fill			= [theLayer->fill retain];
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
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[super encodeWithCoder:coder];

	[coder encodeObject:self.borderLineStyle forKey:@"CPTBorderedLayer.borderLineStyle"];
	[coder encodeObject:self.fill forKey:@"CPTBorderedLayer.fill"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super initWithCoder:coder]) ) {
		borderLineStyle = [[coder decodeObjectForKey:@"CPTBorderedLayer.borderLineStyle"] copy];
		fill			= [[coder decodeObjectForKey:@"CPTBorderedLayer.fill"] copy];
	}
	return self;
}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.hidden ) {
		return;
	}

	[super renderAsVectorInContext:context];

	CPTFill *theFill = self.fill;

	if ( theFill ) {
		BOOL useMask = self.masksToBounds;
		self.masksToBounds = YES;
		CGContextBeginPath(context);
		CGContextAddPath(context, self.maskingPath);
		[theFill fillPathInContext:context];
		self.masksToBounds = useMask;
	}

	CPTLineStyle *theLineStyle = self.borderLineStyle;
	if ( theLineStyle ) {
		CGFloat inset	  = theLineStyle.lineWidth / (CGFloat)2.0;
		CGRect selfBounds = CGRectInset(self.bounds, inset, inset);

		[theLineStyle setLineStyleInContext:context];

		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN(MIN(self.cornerRadius, selfBounds.size.width / (CGFloat)2.0), selfBounds.size.height / (CGFloat)2.0);
			CGContextBeginPath(context);
			AddRoundedRectPath(context, selfBounds, radius);
			CGContextStrokePath(context);
		}
		else {
			CGContextStrokeRect(context, selfBounds);
		}
	}
}

/// @endcond

#pragma mark -
#pragma mark Layout

///	@name Layout
///	@{

/**	@brief Increases the sublayer margin on all four sides by half the width of the border line style.
 *	@param left The left margin.
 *	@param top The top margin.
 *	@param right The right margin.
 *	@param bottom The bottom margin.
 **/
-(void)sublayerMarginLeft:(CGFloat *)left top:(CGFloat *)top right:(CGFloat *)right bottom:(CGFloat *)bottom
{
	[super sublayerMarginLeft:left top:top right:right bottom:bottom];

	CPTLineStyle *theLineStyle = self.borderLineStyle;
	if ( theLineStyle ) {
		CGFloat inset = theLineStyle.lineWidth / (CGFloat)2.0;

		*left	+= inset;
		*top	+= inset;
		*right	+= inset;
		*bottom += inset;
	}
}

///	@}

#pragma mark -
#pragma mark Masking

/// @cond

-(CGPathRef)maskingPath
{
	if ( self.masksToBounds ) {
		CGPathRef path = self.outerBorderPath;
		if ( path ) {
			return path;
		}

		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		CGRect selfBounds = self.bounds;

		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN(MIN(self.cornerRadius + lineWidth / (CGFloat)2.0, selfBounds.size.width / (CGFloat)2.0), selfBounds.size.height / (CGFloat)2.0);
			path				 = CreateRoundedRectPath(selfBounds, radius);
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
		if ( path ) {
			return path;
		}

		CGFloat lineWidth = self.borderLineStyle.lineWidth;
		CGRect selfBounds = CGRectInset(self.bounds, lineWidth, lineWidth);

		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN(MIN(self.cornerRadius - lineWidth / (CGFloat)2.0, selfBounds.size.width / (CGFloat)2.0), selfBounds.size.height / (CGFloat)2.0);
			path				 = CreateRoundedRectPath(selfBounds, radius);
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

/// @endcond

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setBorderLineStyle:(CPTLineStyle *)newLineStyle
{
	if ( newLineStyle != borderLineStyle ) {
		if ( newLineStyle.lineWidth != borderLineStyle.lineWidth ) {
			self.outerBorderPath = NULL;
			self.innerBorderPath = NULL;
		}
		[borderLineStyle release];
		borderLineStyle = [newLineStyle copy];
		[self setNeedsDisplay];
	}
}

-(void)setFill:(CPTFill *)newFill
{
	if ( newFill != fill ) {
		[fill release];
		fill = [newFill copy];
		[self setNeedsDisplay];
	}
}

///	@endcond

@end
