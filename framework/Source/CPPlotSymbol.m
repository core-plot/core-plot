#import <Foundation/Foundation.h>
#import "CPLineStyle.h"
#import "CPFill.h"
#import "CPPlotSymbol.h"

///	@cond
@interface CPPlotSymbol()

@property (nonatomic, readwrite, assign) CGPathRef cachedSymbolPath;
@property (nonatomic, readwrite, assign) CGLayerRef cachedLayer;

-(CGPathRef)newSymbolPath;

@end
///	@endcond

#pragma mark -

/**	@brief Plot symbols for CPScatterPlot.
 */
@implementation CPPlotSymbol

/** @property size 
 *  @brief The symbol size.
 **/
@synthesize size;

/** @property symbolType 
 *  @brief The symbol type.
 **/
@synthesize symbolType;

/** @property lineStyle 
 *  @brief The line style for the border of the symbol.
 *	If nil, the border is not drawn.
 **/
@synthesize lineStyle;

/** @property fill 
 *  @brief The fill for the interior of the symbol.
 *	If nil, the symbol is not filled.
 **/
@synthesize fill;

/** @property customSymbolPath 
 *  @brief The drawing path for a custom plot symbol. It will be scaled to size before being drawn.
 **/
@synthesize customSymbolPath;

/** @property usesEvenOddClipRule 
 *  @brief If YES, the even-odd rule is used to draw the symbol, otherwise the nonzero winding number rule is used.
 *	@see <a href="http://developer.apple.com/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_paths/dq_paths.html#//apple_ref/doc/uid/TP30001066-CH211-TPXREF106">Filling a Path</a> in the Quartz 2D Programming Guide.
 **/
@synthesize usesEvenOddClipRule;

@dynamic cachedSymbolPath;

@synthesize cachedLayer;

#pragma mark -
#pragma mark Init/dealloc

-(id)init
{
	if ( self = [super init] ) {
		size = CGSizeMake(5.0, 5.0);
		symbolType = CPPlotSymbolTypeNone;
		lineStyle = [[CPLineStyle alloc] init];
		fill = nil;
		cachedSymbolPath = NULL;
		customSymbolPath = NULL;
		usesEvenOddClipRule = NO;
		cachedLayer = NULL;
	}
	return self;
}

-(void)dealloc
{
	[lineStyle release];
	[fill release];
	CGPathRelease(cachedSymbolPath);
	CGPathRelease(customSymbolPath);
	CGLayerRelease(cachedLayer);
	
	[super dealloc];
}

-(void)finalize
{
	CGPathRelease(cachedSymbolPath);
	CGPathRelease(customSymbolPath);
	CGLayerRelease(cachedLayer);
	[super finalize];
}

#pragma mark -
#pragma mark Accessors

-(void)setSize:(CGSize)newSize
{
	if ( !CGSizeEqualToSize(newSize, size) ) {
		size = newSize;
		self.cachedSymbolPath = NULL;
	}
}

-(void)setSymbolType:(CPPlotSymbolType)newType
{
	if ( newType != symbolType ) {
		symbolType = newType;
		self.cachedSymbolPath = NULL;
	}
}

-(void)setCustomSymbolPath:(CGPathRef)newPath
{
	if ( customSymbolPath != newPath ) {
		CGPathRelease(customSymbolPath);
		customSymbolPath = CGPathRetain(newPath);
		self.cachedSymbolPath = NULL;
	}
}

-(CGPathRef)cachedSymbolPath
{
	if ( !cachedSymbolPath ) {
		cachedSymbolPath = [self newSymbolPath];
	}
	return cachedSymbolPath;
}

-(void)setCachedSymbolPath:(CGPathRef)newPath
{
	if ( cachedSymbolPath != newPath ) {
		CGPathRelease(cachedSymbolPath);
		cachedSymbolPath = CGPathRetain(newPath);
		self.cachedLayer = NULL;
	}
}

-(void)setCachedLayer:(CGLayerRef)newLayer
{
	if ( cachedLayer != newLayer ) {
		CGLayerRelease(cachedLayer);
		cachedLayer = CGLayerRetain(newLayer);
	}
}

#pragma mark -
#pragma mark Class methods

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeNone.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeNone.
 **/
+(CPPlotSymbol *)plotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeNone;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeCross.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeCross.
 **/
+(CPPlotSymbol *)crossPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeCross;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeEllipse.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeEllipse.
 **/
+(CPPlotSymbol *)ellipsePlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeEllipse;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeRectangle.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeRectangle.
 **/
+(CPPlotSymbol *)rectanglePlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeRectangle;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypePlus.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypePlus.
 **/
+(CPPlotSymbol *)plusPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypePlus;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeStar.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeStar.
 **/
+(CPPlotSymbol *)starPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeStar;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeDiamond.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeDiamond.
 **/
+(CPPlotSymbol *)diamondPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeDiamond;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeTriangle.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeTriangle.
 **/
+(CPPlotSymbol *)trianglePlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeTriangle;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypePentagon.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypePentagon.
 **/
+(CPPlotSymbol *)pentagonPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypePentagon;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeHexagon.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeHexagon.
 **/
+(CPPlotSymbol *)hexagonPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeHexagon;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeDash.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeDash.
 **/
+(CPPlotSymbol *)dashPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeDash;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeSnow.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeSnow.
 **/
+(CPPlotSymbol *)snowPlotSymbol
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeSnow;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeCustom.
 *	@param aPath The bounding path for the custom symbol.
 *  @return A new CPPlotSymbol instance initialized with a symbol type of CPPlotSymbolTypeCustom.
 **/
+(CPPlotSymbol *)customPlotSymbolWithPath:(CGPathRef)aPath
{
	CPPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPPlotSymbolTypeCustom;
	symbol.customSymbolPath = aPath;
	
	return [symbol autorelease];
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPPlotSymbol *copy = [[[self class] allocWithZone:zone] init];
	
	copy.size = self.size;
	copy.symbolType = self.symbolType;
	copy.usesEvenOddClipRule = self.usesEvenOddClipRule;
	copy.lineStyle = [[self.lineStyle copy] autorelease];
	copy.fill = [[self.fill copy] autorelease];
	
	if (self.customSymbolPath) {
		CGPathRef pathCopy = CGPathCreateCopy(self.customSymbolPath);
		copy.customSymbolPath = pathCopy;
		CGPathRelease(pathCopy);
	}
	
	return copy;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the plot symbol into the given graphics context centered at the provided point.
 *  @param theContext The graphics context to draw into.
 *  @param center The center point of the symbol.
 **/
-(void)renderInContext:(CGContextRef)theContext atPoint:(CGPoint)center
{
	CGLayerRef theCachedLayer = self.cachedLayer;
	
	if ( !theCachedLayer ) {
		const CGFloat symbolMargin = 2.0;
		
		CGSize symbolSize = CGPathGetBoundingBox(self.cachedSymbolPath).size;
		CGFloat lineWidth = self.lineStyle.lineWidth;
		symbolSize.width += lineWidth + symbolMargin;
		symbolSize.height += lineWidth + symbolMargin;
		
		theCachedLayer = CGLayerCreateWithContext(theContext, symbolSize, NULL);
		
		[self renderAsVectorInContext:CGLayerGetContext(theCachedLayer)
							  atPoint:CGPointMake(symbolSize.width / 2.0, symbolSize.height / 2.0)];
		
		self.cachedLayer = theCachedLayer;
		CGLayerRelease(theCachedLayer);
	}
	
	if ( theCachedLayer ) {
		CGSize layerSize = CGLayerGetSize(theCachedLayer);
		CGContextDrawLayerAtPoint(theContext, CGPointMake(center.x - layerSize.width / 2.0, center.y - layerSize.height / 2.0), theCachedLayer);
	}
}

-(void)renderAsVectorInContext:(CGContextRef)theContext atPoint:(CGPoint)center
{
	CGPathRef theSymbolPath = self.cachedSymbolPath;
	
	if ( theSymbolPath ) {
		CPLineStyle *theLineStyle = nil;
		CPFill *theFill = nil;
		
		switch ( self.symbolType ) {
			case CPPlotSymbolTypeRectangle:
			case CPPlotSymbolTypeEllipse:
			case CPPlotSymbolTypeDiamond:
			case CPPlotSymbolTypeTriangle:
			case CPPlotSymbolTypeStar:
			case CPPlotSymbolTypePentagon:
			case CPPlotSymbolTypeHexagon:
			case CPPlotSymbolTypeCustom:
				theLineStyle = self.lineStyle;
				theFill = self.fill;
				break;
			case CPPlotSymbolTypeCross:
			case CPPlotSymbolTypePlus:
			case CPPlotSymbolTypeDash:
			case CPPlotSymbolTypeSnow:
				theLineStyle = self.lineStyle;
				break;
			default:
				break;
		}	
		
		if ( theLineStyle || theFill ) {
			CGContextSaveGState(theContext);
			CGContextTranslateCTM(theContext, center.x, center.y);
			
			if ( theFill ) {
				// use fillRect instead of fillPath so that images and gradients are properly centered in the symbol
				CGSize symbolSize = self.size;
				CGSize halfSize = CGSizeMake(symbolSize.width / 2.0, symbolSize.height / 2.0);
				CGRect bounds = CGRectMake(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height);
				
				CGContextSaveGState(theContext);
				CGContextBeginPath(theContext);
				CGContextAddPath(theContext, theSymbolPath);
				if ( self.usesEvenOddClipRule ) {
					CGContextEOClip(theContext);
				}
				else {
					CGContextClip(theContext);
				}
				[theFill fillRect:bounds inContext:theContext];
				CGContextRestoreGState(theContext);
			}
			
			if ( theLineStyle ) {
				[theLineStyle setLineStyleInContext:theContext];
				CGContextBeginPath(theContext);
				CGContextAddPath(theContext, theSymbolPath);
				CGContextStrokePath(theContext);
			}

			CGContextRestoreGState(theContext);
		}
	}
}

#pragma mark -
#pragma mark Private methods

/**	@internal
 *	@brief Creates a drawing path for the selected symbol shape and stores it in symbolPath.
 **/
-(CGPathRef)newSymbolPath
{
	CGFloat dx, dy;
	CGSize symbolSize = self.size;
	CGSize halfSize = CGSizeMake(symbolSize.width / 2.0, symbolSize.height / 2.0);
	CGRect bounds = CGRectMake(-halfSize.width, -halfSize.height, symbolSize.width, symbolSize.height);
	
	CGMutablePathRef symbolPath = CGPathCreateMutable();
	
	switch ( self.symbolType ) {
		case CPPlotSymbolTypeNone:
			// empty path
			break;
		case CPPlotSymbolTypeRectangle:
			CGPathAddRect(symbolPath, NULL, bounds);
			break;
		case CPPlotSymbolTypeEllipse:
			CGPathAddEllipseInRect(symbolPath, NULL, bounds);
			break;
		case CPPlotSymbolTypeCross:
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
			break;
		case CPPlotSymbolTypePlus:
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,                   CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,                   CGRectGetMinY(bounds));
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMinX(bounds), 0.0);
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), 0.0);
			break;
		case CPPlotSymbolTypePentagon:
			CGPathMoveToPoint(symbolPath,    NULL,	0.0,                             CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeStar:
			CGPathMoveToPoint(symbolPath,    NULL,  0.0,                             CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.22451398829,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.36327126400, -halfSize.height * 0.11803398875);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  0.0                           , -halfSize.height * 0.38196601125);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.36327126400, -halfSize.height * 0.11803398875);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.22451398829,  halfSize.height * 0.30901699437);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeDiamond:
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,                   CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), 0.0);
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,                   CGRectGetMinY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMinX(bounds), 0.0);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeTriangle:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL,  0.0, CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx, -dy);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeDash:
			CGPathMoveToPoint(symbolPath,    NULL, CGRectGetMinX(bounds), 0.0);
			CGPathAddLineToPoint(symbolPath, NULL, CGRectGetMaxX(bounds), 0.0);
			break;
		case CPPlotSymbolTypeHexagon:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,  CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, dx,   dy);
			CGPathAddLineToPoint(symbolPath, NULL, dx,  -dy);
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,  CGRectGetMinY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL, -dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx,  dy);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPPlotSymbolTypeSnow:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL,  0.0, CGRectGetMaxY(bounds));
			CGPathAddLineToPoint(symbolPath, NULL,  0.0, CGRectGetMinY(bounds));
			CGPathMoveToPoint(symbolPath,    NULL,  dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx,  dy);
			CGPathMoveToPoint(symbolPath,    NULL, -dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL,  dx,  dy);
			break;
		case CPPlotSymbolTypeCustom: {
			CGPathRef customPath = self.customSymbolPath;
			if ( customPath ) {
				CGRect oldBounds = CGRectNull;
				CGAffineTransform scaleTransform = CGAffineTransformIdentity;
				
				oldBounds = CGPathGetBoundingBox(customPath);
				CGFloat dx1 = bounds.size.width / oldBounds.size.width;
				CGFloat dy1 = bounds.size.height / oldBounds.size.height;
				CGFloat f = dx1 < dy1 ? dx1 : dy1;
				scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, f, f);
				scaleTransform = CGAffineTransformConcat(scaleTransform,
														 CGAffineTransformMakeTranslation(-halfSize.width, -halfSize.height));
				CGPathAddPath(symbolPath, &scaleTransform, customPath);
			}
		}
			break;
	}
	return symbolPath;
}

@end

