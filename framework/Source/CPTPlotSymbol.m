#import <Foundation/Foundation.h>
#import "CPTLineStyle.h"
#import "CPTFill.h"
#import "CPTPlotSymbol.h"

/**	@cond */
@interface CPTPlotSymbol()

@property (nonatomic, readwrite, assign) CGPathRef cachedSymbolPath;
@property (nonatomic, readwrite, assign) CGLayerRef cachedLayer;

-(CGPathRef)newSymbolPath;

@end
/**	@endcond */

#pragma mark -

/**	@brief Plot symbols for CPTScatterPlot.
 */
@implementation CPTPlotSymbol

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
	if ( (self = [super init]) ) {
		size = CGSizeMake(5.0, 5.0);
		symbolType = CPTPlotSymbolTypeNone;
		lineStyle = [[CPTLineStyle alloc] init];
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

-(void)setSymbolType:(CPTPlotSymbolType)newType
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

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeNone.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeNone.
 **/
+(CPTPlotSymbol *)plotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeNone;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeCross.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeCross.
 **/
+(CPTPlotSymbol *)crossPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeCross;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeEllipse.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeEllipse.
 **/
+(CPTPlotSymbol *)ellipsePlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeEllipse;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeRectangle.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeRectangle.
 **/
+(CPTPlotSymbol *)rectanglePlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeRectangle;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypePlus.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypePlus.
 **/
+(CPTPlotSymbol *)plusPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypePlus;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeStar.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeStar.
 **/
+(CPTPlotSymbol *)starPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeStar;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeDiamond.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeDiamond.
 **/
+(CPTPlotSymbol *)diamondPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeDiamond;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeTriangle.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeTriangle.
 **/
+(CPTPlotSymbol *)trianglePlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeTriangle;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypePentagon.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypePentagon.
 **/
+(CPTPlotSymbol *)pentagonPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypePentagon;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeHexagon.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeHexagon.
 **/
+(CPTPlotSymbol *)hexagonPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeHexagon;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeDash.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeDash.
 **/
+(CPTPlotSymbol *)dashPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeDash;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeSnow.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeSnow.
 **/
+(CPTPlotSymbol *)snowPlotSymbol
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeSnow;
	
	return [symbol autorelease];
}

/** @brief Creates and returns a new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeCustom.
 *	@param aPath The bounding path for the custom symbol.
 *  @return A new CPTPlotSymbol instance initialized with a symbol type of CPTPlotSymbolTypeCustom.
 **/
+(CPTPlotSymbol *)customPlotSymbolWithPath:(CGPathRef)aPath
{
	CPTPlotSymbol *symbol = [[self alloc] init];
	symbol.symbolType = CPTPlotSymbolTypeCustom;
	symbol.customSymbolPath = aPath;
	
	return [symbol autorelease];
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	CPTPlotSymbol *copy = [[[self class] allocWithZone:zone] init];
	
	copy.size = self.size;
	copy.symbolType = self.symbolType;
	copy.usesEvenOddClipRule = self.usesEvenOddClipRule;
	copy.lineStyle = [[self.lineStyle copy] autorelease];
	copy.fill = [[self.fill copy] autorelease];
	
	if ( self.customSymbolPath ) {
		CGPathRef pathCopy = CGPathCreateCopy(self.customSymbolPath);
		copy.customSymbolPath = pathCopy;
		CGPathRelease(pathCopy);
	}
	
	return copy;
}

#pragma mark -
#pragma mark Drawing

/** @brief Draws the plot symbol into the given graphics context centered at the provided point using the cached symbol image.
 *  @param theContext The graphics context to draw into.
 *  @param center The center point of the symbol.
 *  @param scale The drawing scale factor. Must be greater than zero (0).
 **/
-(void)renderInContext:(CGContextRef)theContext atPoint:(CGPoint)center scale:(CGFloat)scale
{
	static const CGFloat symbolMargin = 2.0;
	
	CGLayerRef theCachedLayer = self.cachedLayer;
	
	if ( !theCachedLayer ) {
		CGSize symbolSize = self.size;
		CGFloat margin = self.lineStyle.lineWidth + symbolMargin;
		symbolSize.width *= scale;
		symbolSize.width += margin;
		symbolSize.height *= scale;
		symbolSize.height += margin;
		
		theCachedLayer = CGLayerCreateWithContext(theContext, symbolSize, NULL);
		
		[self renderAsVectorInContext:CGLayerGetContext(theCachedLayer)
							  atPoint:CGPointMake(symbolSize.width / 2.0, symbolSize.height / 2.0)
								scale:scale];
		
		self.cachedLayer = theCachedLayer;
		CGLayerRelease(theCachedLayer);
	}
	
	if ( theCachedLayer ) {
		CGSize layerSize = CGLayerGetSize(theCachedLayer);
		layerSize.width /= scale;
		layerSize.height /= scale;

#if CGFLOAT_IS_DOUBLE
		CGPoint origin = CGPointMake(round(center.x - layerSize.width / 2.0), round(center.y - layerSize.height / 2.0));
#else
		CGPoint origin = CGPointMake(roundf(center.x - layerSize.width / 2.0f), roundf(center.y - layerSize.height / 2.0f));
#endif
		CGContextDrawLayerInRect(theContext, CGRectMake(origin.x, origin.y, layerSize.width, layerSize.height), theCachedLayer);
	}
}

/** @brief Draws the plot symbol into the given graphics context centered at the provided point.
 *  @param theContext The graphics context to draw into.
 *  @param center The center point of the symbol.
 *  @param scale The drawing scale factor. Must be greater than zero (0).
 **/
-(void)renderAsVectorInContext:(CGContextRef)theContext atPoint:(CGPoint)center scale:(CGFloat)scale
{
	CGPathRef theSymbolPath = self.cachedSymbolPath;
	
	if ( theSymbolPath ) {
		CPTLineStyle *theLineStyle = nil;
		CPTFill *theFill = nil;
		
		switch ( self.symbolType ) {
			case CPTPlotSymbolTypeRectangle:
			case CPTPlotSymbolTypeEllipse:
			case CPTPlotSymbolTypeDiamond:
			case CPTPlotSymbolTypeTriangle:
			case CPTPlotSymbolTypeStar:
			case CPTPlotSymbolTypePentagon:
			case CPTPlotSymbolTypeHexagon:
			case CPTPlotSymbolTypeCustom:
				theLineStyle = self.lineStyle;
				theFill = self.fill;
				break;
			case CPTPlotSymbolTypeCross:
			case CPTPlotSymbolTypePlus:
			case CPTPlotSymbolTypeDash:
			case CPTPlotSymbolTypeSnow:
				theLineStyle = self.lineStyle;
				break;
			default:
				break;
		}	
		
		if ( theLineStyle || theFill ) {
			CGContextSaveGState(theContext);
			CGContextTranslateCTM(theContext, center.x, center.y);
			CGContextScaleCTM(theContext, scale, scale);
			
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

	CGMutablePathRef symbolPath = CGPathCreateMutable();
	
	switch ( self.symbolType ) {
		case CPTPlotSymbolTypeNone:
			// empty path
			break;
		case CPTPlotSymbolTypeRectangle:
			CGPathAddRect(symbolPath, NULL, CGRectMake(-halfSize.width, -halfSize.height, halfSize.width * 2.0, halfSize.height * 2.0));
			break;
		case CPTPlotSymbolTypeEllipse:
			CGPathAddEllipseInRect(symbolPath, NULL, CGRectMake(-halfSize.width, -halfSize.height, halfSize.width * 2.0, halfSize.height * 2.0));
			break;
		case CPTPlotSymbolTypeCross:
			CGPathMoveToPoint(symbolPath,    NULL, -halfSize.width,  halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL, halfSize.width,  -halfSize.height);
			CGPathMoveToPoint(symbolPath,    NULL, halfSize.width,   halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width, -halfSize.height);
			break;
		case CPTPlotSymbolTypePlus:
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,             halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,            -halfSize.height);
			CGPathMoveToPoint(symbolPath,    NULL, -halfSize.width, 0.0);
			CGPathAddLineToPoint(symbolPath, NULL, halfSize.width,  0.0);
			break;
		case CPTPlotSymbolTypePentagon:
			CGPathMoveToPoint(symbolPath,    NULL,	0.0,                             halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathAddLineToPoint(symbolPath, NULL,  halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.58778525229, -halfSize.height * 0.80901699437);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width * 0.95105651630,  halfSize.height * 0.30901699437);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPTPlotSymbolTypeStar:
			CGPathMoveToPoint(symbolPath,    NULL,  0.0,                             halfSize.height);
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
		case CPTPlotSymbolTypeDiamond:
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,             halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL, halfSize.width,  0.0);
			CGPathAddLineToPoint(symbolPath, NULL, 0.0,            -halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width, 0.0);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPTPlotSymbolTypeTriangle:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
            
			CGPathMoveToPoint(symbolPath,    NULL,  0.0, halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL,  dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx, -dy);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPTPlotSymbolTypeDash:
			CGPathMoveToPoint(symbolPath,    NULL, halfSize.width,  0.0);
			CGPathAddLineToPoint(symbolPath, NULL, -halfSize.width, 0.0);
			break;
		case CPTPlotSymbolTypeHexagon:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL, 0.0,  halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL, dx,   dy);
			CGPathAddLineToPoint(symbolPath, NULL, dx,  -dy);
			CGPathAddLineToPoint(symbolPath, NULL, 0.0, -halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL, -dx, -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx,  dy);
			CGPathCloseSubpath(symbolPath);
			break;
		case CPTPlotSymbolTypeSnow:
			dx = halfSize.width * 0.86602540378; // sqrt(3.0) / 2.0;
			dy = halfSize.height / 2.0;
			
			CGPathMoveToPoint(symbolPath,    NULL,  0.0,  halfSize.height);
			CGPathAddLineToPoint(symbolPath, NULL,  0.0, -halfSize.height);
			CGPathMoveToPoint(symbolPath,    NULL,  dx,  -dy);
			CGPathAddLineToPoint(symbolPath, NULL, -dx,   dy);
			CGPathMoveToPoint(symbolPath,    NULL, -dx,  -dy);
			CGPathAddLineToPoint(symbolPath, NULL,  dx,   dy);
			break;
		case CPTPlotSymbolTypeCustom: {
			CGPathRef customPath = self.customSymbolPath;
			if ( customPath ) {
				CGRect oldBounds = CGRectNull;
				CGAffineTransform scaleTransform = CGAffineTransformIdentity;
				
				oldBounds = CGPathGetBoundingBox(customPath);
				CGFloat dx1 = symbolSize.width / oldBounds.size.width;
				CGFloat dy1 = symbolSize.height / oldBounds.size.height;
				scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, dx1, dy1);
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

