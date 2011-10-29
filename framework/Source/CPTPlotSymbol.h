#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/// @file

@class CPTLineStyle;
@class CPTFill;
@class CPTShadow;

/**
 *	@brief Plot symbol types.
 **/
typedef enum _CPTPlotSymbolType {
	CPTPlotSymbolTypeNone,      ///< No symbol.
	CPTPlotSymbolTypeRectangle, ///< Rectangle symbol.
	CPTPlotSymbolTypeEllipse,   ///< Elliptical symbol.
	CPTPlotSymbolTypeDiamond,   ///< Diamond symbol.
	CPTPlotSymbolTypeTriangle,  ///< Triangle symbol.
	CPTPlotSymbolTypeStar,      ///< 5-point star symbol.
	CPTPlotSymbolTypePentagon,  ///< Pentagon symbol.
	CPTPlotSymbolTypeHexagon,   ///< Hexagon symbol.
	CPTPlotSymbolTypeCross,     ///< X symbol.
	CPTPlotSymbolTypePlus,      ///< Plus symbol.
	CPTPlotSymbolTypeDash,      ///< Dash symbol.
	CPTPlotSymbolTypeSnow,      ///< Snowflake symbol.
	CPTPlotSymbolTypeCustom     ///< Custom symbol.
}
CPTPlotSymbolType;

@interface CPTPlotSymbol : NSObject<NSCoding, NSCopying> {
	@private
	CGSize size;
	CPTPlotSymbolType symbolType;
	CPTLineStyle *lineStyle;
	CPTFill *fill;
	CGPathRef cachedSymbolPath;
	CGPathRef customSymbolPath;
	BOOL usesEvenOddClipRule;
	CGLayerRef cachedLayer;
	CPTShadow *shadow;
}

@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CPTPlotSymbolType symbolType;
@property (nonatomic, readwrite, retain) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, retain) CPTFill *fill;
@property (nonatomic, readwrite, copy) CPTShadow *shadow;
@property (nonatomic, readwrite, assign) CGPathRef customSymbolPath;
@property (nonatomic, readwrite, assign) BOOL usesEvenOddClipRule;

/// @name Factory Methods
/// @{
+(CPTPlotSymbol *)plotSymbol;
+(CPTPlotSymbol *)crossPlotSymbol;
+(CPTPlotSymbol *)ellipsePlotSymbol;
+(CPTPlotSymbol *)rectanglePlotSymbol;
+(CPTPlotSymbol *)plusPlotSymbol;
+(CPTPlotSymbol *)starPlotSymbol;
+(CPTPlotSymbol *)diamondPlotSymbol;
+(CPTPlotSymbol *)trianglePlotSymbol;
+(CPTPlotSymbol *)pentagonPlotSymbol;
+(CPTPlotSymbol *)hexagonPlotSymbol;
+(CPTPlotSymbol *)dashPlotSymbol;
+(CPTPlotSymbol *)snowPlotSymbol;
+(CPTPlotSymbol *)customPlotSymbolWithPath:(CGPathRef)aPath;
///	@}

/// @name Drawing
/// @{
-(void)renderInContext:(CGContextRef)theContext atPoint:(CGPoint)center scale:(CGFloat)scale alignToPixels:(BOOL)alignToPixels;
-(void)renderAsVectorInContext:(CGContextRef)theContext atPoint:(CGPoint)center scale:(CGFloat)scale;
///	@}

@end
