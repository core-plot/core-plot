#import "CPTBorderedLayer.h"

#import "CPTFill.h"
#import "CPTLineStyle.h"
#import "CPTPathExtensions.h"

/** @brief A layer with rounded corners.
 **/
@implementation CPTBorderedLayer

/** @property borderLineStyle
 *  @brief The line style for the layer border.
 *
 *	If nil, the border is not drawn.
 **/
@synthesize borderLineStyle;

/** @property fill
 *  @brief The fill for the layer background.
 *
 *	If nil, the layer background is not filled.
 **/
@synthesize fill;

#pragma mark -
#pragma mark Init/Dealloc

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

-(void)renderAsVectorInContext:(CGContextRef)context
{
	if ( self.hidden ) {
		return;
	}

	[super renderAsVectorInContext:context];

	BOOL useMask = self.masksToBounds;
	self.masksToBounds = YES;
	CGContextBeginPath( context );
	CGContextAddPath( context, self.maskingPath );
	[self.fill fillPathInContext:context];
	self.masksToBounds = useMask;

	CPTLineStyle *theLineStyle = self.borderLineStyle;
	if ( theLineStyle ) {
		CGFloat inset	  = theLineStyle.lineWidth / (CGFloat)2.0;
		CGRect selfBounds = CGRectInset( self.bounds, inset, inset );

		[theLineStyle setLineStyleInContext:context];

		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN( MIN( self.cornerRadius, selfBounds.size.width / (CGFloat)2.0 ), selfBounds.size.height / (CGFloat)2.0 );
			CGContextBeginPath( context );
			AddRoundedRectPath( context, selfBounds, radius );
			CGContextStrokePath( context );
		}
		else {
			CGContextStrokeRect( context, selfBounds );
		}
	}
}

#pragma mark -
#pragma mark Layout

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

#pragma mark -
#pragma mark Masking

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
			CGFloat radius = MIN( MIN( self.cornerRadius + lineWidth / (CGFloat)2.0, selfBounds.size.width / (CGFloat)2.0 ), selfBounds.size.height / (CGFloat)2.0 );
			path				 = CreateRoundedRectPath( selfBounds, radius );
			self.outerBorderPath = path;
			CGPathRelease( path );
		}
		else {
			CGMutablePathRef mutablePath = CGPathCreateMutable();
			CGPathAddRect( mutablePath, NULL, selfBounds );
			self.outerBorderPath = mutablePath;
			CGPathRelease( mutablePath );
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
		CGRect selfBounds = CGRectInset( self.bounds, lineWidth, lineWidth );

		if ( self.cornerRadius > 0.0 ) {
			CGFloat radius = MIN( MIN( self.cornerRadius - lineWidth / (CGFloat)2.0, selfBounds.size.width / (CGFloat)2.0 ), selfBounds.size.height / (CGFloat)2.0 );
			path				 = CreateRoundedRectPath( selfBounds, radius );
			self.innerBorderPath = path;
			CGPathRelease( path );
		}
		else {
			CGMutablePathRef mutablePath = CGPathCreateMutable();
			CGPathAddRect( mutablePath, NULL, selfBounds );
			self.innerBorderPath = mutablePath;
			CGPathRelease( mutablePath );
		}

		return self.innerBorderPath;
	}
	else {
		return NULL;
	}
}

#pragma mark -
#pragma mark Accessors

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

@end
