#import <Foundation/Foundation.h>

/// @file

@class CPLineStyle;
@class CPFill;

/**	@brief Plot symbol types.
 **/
typedef enum _CPPlotSymbolType {
    CPPlotSymbolTypeNone,		///< No symbol.
    CPPlotSymbolTypeRectangle,	///< Rectangle symbol.
    CPPlotSymbolTypeEllipse,	///< Elliptical symbol.
    CPPlotSymbolTypeDiamond,	///< Diamond symbol.
	CPPlotSymbolTypeTriangle,	///< Triangle symbol.
	CPPlotSymbolTypeStar,		///< 5-point star symbol.
	CPPlotSymbolTypePentagon,	///< Pentagon symbol.
	CPPlotSymbolTypeHexagon,	///< Hexagon symbol.
	CPPlotSymbolTypeCross,		///< X symbol.
	CPPlotSymbolTypePlus,		///< Plus symbol.
	CPPlotSymbolTypeDash,		///< Dash symbol.
	CPPlotSymbolTypeSnow,		///< Snowflake symbol.
	CPPlotSymbolTypeCustom		///< Custom symbol.
} CPPlotSymbolType;

@interface CPPlotSymbol : NSObject <NSCopying> {
@private
	CGSize size;
	CPPlotSymbolType symbolType;
	CPLineStyle *lineStyle;
	CPFill *fill;
	CGPathRef cachedSymbolPath;
	CGPathRef customSymbolPath;
	BOOL usesEvenOddClipRule;
	CGLayerRef cachedLayer;
}

@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CPPlotSymbolType symbolType;
@property (nonatomic, readwrite, retain) CPLineStyle *lineStyle;
@property (nonatomic, readwrite, retain) CPFill *fill;
@property (nonatomic, readwrite, assign) CGPathRef customSymbolPath;
@property (nonatomic, readwrite, assign) BOOL usesEvenOddClipRule;

/// @name Factory Methods
/// @{
+(CPPlotSymbol *)plotSymbol;
+(CPPlotSymbol *)crossPlotSymbol;
+(CPPlotSymbol *)ellipsePlotSymbol;
+(CPPlotSymbol *)rectanglePlotSymbol;
+(CPPlotSymbol *)plusPlotSymbol;
+(CPPlotSymbol *)starPlotSymbol;
+(CPPlotSymbol *)diamondPlotSymbol;
+(CPPlotSymbol *)trianglePlotSymbol;
+(CPPlotSymbol *)pentagonPlotSymbol;
+(CPPlotSymbol *)hexagonPlotSymbol;
+(CPPlotSymbol *)dashPlotSymbol;
+(CPPlotSymbol *)snowPlotSymbol;
+(CPPlotSymbol *)customPlotSymbolWithPath:(CGPathRef)aPath;
///	@}

/// @name Drawing
/// @{
-(void)renderInContext:(CGContextRef)theContext atPoint:(CGPoint)center;
-(void)renderAsVectorInContext:(CGContextRef)theContext atPoint:(CGPoint)center;
///	@}

@end
