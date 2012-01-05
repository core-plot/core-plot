#import "CPTLineCap.h"

#import "CPTFill.h"
#import "CPTLineStyle.h"
#import "NSCoderExtensions.h"
#import <Foundation/Foundation.h>
#import <tgmath.h>

///	@cond
@interface CPTLineCap()

@property (nonatomic, readwrite, assign) CGPathRef cachedLineCapPath;

-(CGPathRef)newLineCapPath;

@end

///	@endcond

#pragma mark -

/**
 *	@brief End cap decorations for lines.
 */
@implementation CPTLineCap

/**	@property size
 *  @brief The symbol size when the line is drawn in a vertical direction.
 **/
@synthesize size;

/** @property lineCapType
 *  @brief The line cap type.
 **/
@synthesize lineCapType;

/** @property lineStyle
 *  @brief The line style for the border of the line cap.
 *	If <code>nil</code>, the border is not drawn.
 **/
@synthesize lineStyle;

/** @property fill
 *  @brief The fill for the interior of the line cap.
 *	If <code>nil</code>, the symbol is not filled.
 **/
@synthesize fill;

/** @property customLineCapPath
 *  @brief The drawing path for a custom line cap. It will be scaled to size before being drawn.
 **/
@synthesize customLineCapPath;

/** @property usesEvenOddClipRule
 *  @brief If YES, the even-odd rule is used to draw the line cap, otherwise the nonzero winding number rule is used.
 *	@see <a href="http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_paths/dq_paths.html#//apple_ref/doc/uid/TP30001066-CH211-TPXREF106">Filling a Path</a> in the Quartz 2D Programming Guide.
 **/
@synthesize usesEvenOddClipRule;

@dynamic cachedLineCapPath;

#pragma mark -
#pragma mark Init/dealloc

-(id)init
{
	if ( (self = [super init]) ) {
		size				= CGSizeMake(5.0, 5.0);
		lineCapType			= CPTLineCapTypeNone;
		lineStyle			= [[CPTLineStyle alloc] init];
		fill				= nil;
		cachedLineCapPath	= NULL;
		customLineCapPath	= NULL;
		usesEvenOddClipRule = NO;
	}
	return self;
}

-(void)dealloc
{
	[lineStyle release];
	[fill release];
	CGPathRelease(cachedLineCapPath);
	CGPathRelease(customLineCapPath);

	[super dealloc];
}

-(void)finalize
{
	CGPathRelease(cachedLineCapPath);
	CGPathRelease(customLineCapPath);
	[super finalize];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeCPTSize:self.size forKey:@"CPTLineCap.size"];
	[coder encodeInteger:self.lineCapType forKey:@"CPTLineCap.lineCapType"];
	[coder encodeObject:self.lineStyle forKey:@"CPTLineCap.lineStyle"];
	[coder encodeObject:self.fill forKey:@"CPTLineCap.fill"];
	[coder encodeCGPath:self.customLineCapPath forKey:@"CPTLineCap.customLineCapPath"];
	[coder encodeBool:self.usesEvenOddClipRule forKey:@"CPTLineCap.usesEvenOddClipRule"];

	// No need to archive these properties:
	// cachedLineCapPath
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		size				= [coder decodeCPTSizeForKey:@"CPTLineCap.size"];
		lineCapType			= [coder decodeIntegerForKey:@"CPTLineCap.lineCapType"];
		lineStyle			= [[coder decodeObjectForKey:@"CPTLineCap.lineStyle"] retain];
		fill				= [[coder decodeObjectForKey:@"CPTLineCap.fill"] retain];
		customLineCapPath	= [coder newCGPathDecodeForKey:@"CPTLineCap.customLineCapPath"];
		usesEvenOddClipRule = [coder decodeBoolForKey:@"CPTLineCap.usesEvenOddClipRule"];

		cachedLineCapPath = NULL;
	}
	return self;
}

#pragma mark -
#pragma mark Accessors

///	@cond

-(void)setSize:(CGSize)newSize
{
	if ( !CGSizeEqualToSize(newSize, size) ) {
		size				   = newSize;
		self.cachedLineCapPath = NULL;
	}
}

-(void)setLineCapType:(CPTLineCapType)newType
{
	if ( newType != lineCapType ) {
		lineCapType			   = newType;
		self.cachedLineCapPath = NULL;
	}
}

-(void)setCustomLineCapPath:(CGPathRef)newPath
{
	if ( customLineCapPath != newPath ) {
		CGPathRelease(customLineCapPath);
		customLineCapPath	   = CGPathRetain(newPath);
		self.cachedLineCapPath = NULL;
	}
}

-(CGPathRef)cachedLineCapPath
{
	if ( !cachedLineCapPath ) {
		cachedLineCapPath = [self newLineCapPath];
	}
	return cachedLineCapPath;
}

-(void)setCachedLineCapPath:(CGPathRef)newPath
{
	if ( cachedLineCapPath != newPath ) {
		CGPathRelease(cachedLineCapPath);
		cachedLineCapPath = CGPathRetain(newPath);
	}
}

///	@endcond

#pragma mark -
#pragma mark Factory methods

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeNone.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeNone.
 **/
+(CPTLineCap *)lineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeNone;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeOpenArrow.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeOpenArrow.
 **/
+(CPTLineCap *)openArrowPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeOpenArrow;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeSolidArrow.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeSolidArrow.
 **/
+(CPTLineCap *)solidArrowPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeSolidArrow;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeSweptArrow.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeSweptArrow.
 **/
+(CPTLineCap *)sweptArrowPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeSweptArrow;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeRectangle.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeRectangle.
 **/
+(CPTLineCap *)rectanglePlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeRectangle;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeEllipse.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeEllipse.
 **/
+(CPTLineCap *)ellipsePlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeEllipse;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeDiamond.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeDiamond.
 **/
+(CPTLineCap *)diamondPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeDiamond;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypePentagon.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypePentagon.
 **/
+(CPTLineCap *)pentagonPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypePentagon;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeHexagon.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeHexagon.
 **/
+(CPTLineCap *)hexagonPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeHexagon;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeBar.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeBar.
 **/
+(CPTLineCap *)barPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeBar;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeCross.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeCross.
 **/
+(CPTLineCap *)crossPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeCross;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeSnow.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeSnow.
 **/
+(CPTLineCap *)snowPlotLineCap
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType = CPTLineCapTypeSnow;

	return [lineCap autorelease];
}

/** @brief Creates and returns a new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeCustom.
 *	@param aPath The bounding path for the custom line cap.
 *  @return A new CPTLineCap instance initialized with a line cap type of #CPTLineCapTypeCustom.
 **/
+(CPTLineCap *)customLineCapWithPath:(CGPathRef)aPath
{
	CPTLineCap *lineCap = [[self alloc] init];

	lineCap.lineCapType		  = CPTLineCapTypeCustom;
	lineCap.customLineCapPath = aPath;

	return [lineCap autorelease];
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPTLineCap *copy = [[[self class] allocWithZone:zone] init];

	copy.size				 = self.size;
	copy.lineCapType		 = self.lineCapType;
	copy.usesEvenOddClipRule = self.usesEvenOddClipRule;
	copy.lineStyle			 = [[self.lineStyle copy] autorelease];
	copy.fill				 = [[self.fill copy] autorelease];

	if ( self.customLineCapPath ) {
		CGPathRef pathCopy = CGPathCreateCopy(self.customLineCapPath);
		copy.customLineCapPath = pathCopy;
		CGPathRelease(pathCopy);
	}

	return copy;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the line cap into the given graphics context centered at the provided point.
 *  @param theContext The graphics context to draw into.
 *  @param center The center point of the line cap.
 *  @param direction The direction the line is pointing.
 **/
-(void)renderAsVectorInContext:(CGContextRef)theContext atPoint:(CGPoint)center inDirection:(CGPoint)direction
{
	CGPathRef theLineCapPath = self.cachedLineCapPath;

	if ( theLineCapPath ) {
		CPTLineStyle *theLineStyle = nil;
		CPTFill *theFill		   = nil;

		switch ( self.lineCapType ) {
			case CPTLineCapTypeSolidArrow:
			case CPTLineCapTypeSweptArrow:
			case CPTLineCapTypeRectangle:
			case CPTLineCapTypeEllipse:
			case CPTLineCapTypeDiamond:
			case CPTLineCapTypePentagon:
			case CPTLineCapTypeHexagon:
			case CPTLineCapTypeCustom:
				theLineStyle = self.lineStyle;
				theFill		 = self.fill;
				break;

			case CPTLineCapTypeOpenArrow:
			case CPTLineCapTypeBar:
			case CPTLineCapTypeCross:
			case CPTLineCapTypeSnow:
				theLineStyle = self.lineStyle;
				break;

			default:
				break;
		}

		if ( theLineStyle || theFill ) {
			CGContextSaveGState(theContext);
			CGContextTranslateCTM(theContext, center.x, center.y);
			CGContextRotateCTM(theContext, atan2(direction.y, direction.x) - (CGFloat)M_PI_2); // standard symbol points up

			if ( theFill ) {
				// use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
				CGSize symbolSize = self.size;
				CGSize halfSize	  = CGSizeMake(symbolSize.width / (CGFloat)2.0, symbolSize.height / (CGFloat)2.0);
				CGRect bounds	  = CGRectMake(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height);

				CGContextSaveGState(theContext);
				if ( !CGPathIsEmpty(theLineCapPath) ) {
					CGContextBeginPath(theContext);
					CGContextAddPath(theContext, theLineCapPath);
					if ( self.usesEvenOddClipRule ) {
						CGContextEOClip(theContext);
					}
					else {
						CGContextClip(theContext);
					}
				}
				[theFill fillRect:bounds inContext:theContext];
				CGContextRestoreGState(theContext);
			}

			if ( theLineStyle ) {
				[theLineStyle setLineStyleInContext:theContext];
				CGContextBeginPath(theContext);
				CGContextAddPath(theContext, theLineCapPath);
				CGContextStrokePath(theContext);
			}

			CGContextRestoreGState(theContext);
		}
	}
}

#pragma mark -
#pragma mark Private methods

///	@cond

/**	@internal
 *	@brief Creates and returns a drawing path for the current line cap type.
 *	The path is standardized for a line direction of "up".
 *	@return A path describing the outline of the current line cap type.
 **/
-(CGPathRef)newLineCapPath
{
	CGFloat dx, dy;
	CGSize lineCapSize = self.size;
	CGSize halfSize	   = CGSizeMake(lineCapSize.width / (CGFloat)2.0, lineCapSize.height / (CGFloat)2.0);

	CGMutablePathRef lineCapPath = CGPathCreateMutable();

	switch ( self.lineCapType ) {
		case CPTLineCapTypeNone:
			// empty path
			break;

		case CPTLineCapTypeOpenArrow:
			CGPathMoveToPoint(lineCapPath, NULL, -halfSize.width, -halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, 0.0, 0.0);
			CGPathAddLineToPoint(lineCapPath, NULL, halfSize.width, -halfSize.height);
			break;

		case CPTLineCapTypeSolidArrow:
			CGPathMoveToPoint(lineCapPath, NULL, -halfSize.width, -halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, 0.0, 0.0);
			CGPathAddLineToPoint(lineCapPath, NULL, halfSize.width, -halfSize.height);
			CGPathCloseSubpath(lineCapPath);
			break;

		case CPTLineCapTypeSweptArrow:
			CGPathMoveToPoint(lineCapPath, NULL, -halfSize.width, -halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, 0.0, 0.0);
			CGPathAddLineToPoint(lineCapPath, NULL, halfSize.width, -halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, 0.0, -lineCapSize.height * (CGFloat)0.375);
			CGPathCloseSubpath(lineCapPath);
			break;

		case CPTLineCapTypeRectangle:
			CGPathAddRect( lineCapPath, NULL, CGRectMake(-halfSize.width, -halfSize.height, halfSize.width * (CGFloat)2.0, halfSize.height * (CGFloat)2.0) );
			break;

		case CPTLineCapTypeEllipse:
			CGPathAddEllipseInRect( lineCapPath, NULL, CGRectMake(-halfSize.width, -halfSize.height, halfSize.width * (CGFloat)2.0, halfSize.height * (CGFloat)2.0) );
			break;

		case CPTLineCapTypeDiamond:
			CGPathMoveToPoint(lineCapPath, NULL, 0.0, halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, halfSize.width, 0.0);
			CGPathAddLineToPoint(lineCapPath, NULL, 0.0, -halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, -halfSize.width, 0.0);
			CGPathCloseSubpath(lineCapPath);
			break;

		case CPTLineCapTypePentagon:
			CGPathMoveToPoint(lineCapPath, NULL, 0.0, halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, halfSize.width * (CGFloat)0.95105651630, halfSize.height * (CGFloat)0.30901699437);
			CGPathAddLineToPoint(lineCapPath, NULL, halfSize.width * (CGFloat)0.58778525229, -halfSize.height * (CGFloat)0.80901699437);
			CGPathAddLineToPoint(lineCapPath, NULL, -halfSize.width * (CGFloat)0.58778525229, -halfSize.height * (CGFloat)0.80901699437);
			CGPathAddLineToPoint(lineCapPath, NULL, -halfSize.width * (CGFloat)0.95105651630, halfSize.height * (CGFloat)0.30901699437);
			CGPathCloseSubpath(lineCapPath);
			break;

		case CPTLineCapTypeHexagon:
			dx = halfSize.width * (CGFloat)0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / (CGFloat)2.0;

			CGPathMoveToPoint(lineCapPath, NULL, 0.0, halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, dx, dy);
			CGPathAddLineToPoint(lineCapPath, NULL, dx, -dy);
			CGPathAddLineToPoint(lineCapPath, NULL, 0.0, -halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, -dx, -dy);
			CGPathAddLineToPoint(lineCapPath, NULL, -dx, dy);
			CGPathCloseSubpath(lineCapPath);
			break;

		case CPTLineCapTypeBar:
			CGPathMoveToPoint(lineCapPath, NULL, halfSize.width, 0.0);
			CGPathAddLineToPoint(lineCapPath, NULL, -halfSize.width, 0.0);
			break;

		case CPTLineCapTypeCross:
			CGPathMoveToPoint(lineCapPath, NULL, -halfSize.width, halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, halfSize.width, -halfSize.height);
			CGPathMoveToPoint(lineCapPath, NULL, halfSize.width, halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, -halfSize.width, -halfSize.height);
			break;

		case CPTLineCapTypeSnow:
			dx = halfSize.width * (CGFloat)0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / (CGFloat)2.0;

			CGPathMoveToPoint(lineCapPath, NULL, 0.0, halfSize.height);
			CGPathAddLineToPoint(lineCapPath, NULL, 0.0, -halfSize.height);
			CGPathMoveToPoint(lineCapPath, NULL, dx, -dy);
			CGPathAddLineToPoint(lineCapPath, NULL, -dx, dy);
			CGPathMoveToPoint(lineCapPath, NULL, -dx, -dy);
			CGPathAddLineToPoint(lineCapPath, NULL, dx, dy);
			break;

		case CPTLineCapTypeCustom:
		{
			CGPathRef customPath = self.customLineCapPath;
			if ( customPath ) {
				CGRect oldBounds				 = CGRectNull;
				CGAffineTransform scaleTransform = CGAffineTransformIdentity;

				oldBounds = CGPathGetBoundingBox(customPath);
				CGFloat dx1 = lineCapSize.width / oldBounds.size.width;
				CGFloat dy1 = lineCapSize.height / oldBounds.size.height;
				scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, dx1, dy1);
				scaleTransform = CGAffineTransformConcat( scaleTransform,
														  CGAffineTransformMakeTranslation(-halfSize.width, -halfSize.height) );
				CGPathAddPath(lineCapPath, &scaleTransform, customPath);
			}
		}
		break;
	}
	return lineCapPath;
}

///	@endcond

@end
