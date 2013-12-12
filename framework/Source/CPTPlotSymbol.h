/// @file

@class CPTLineStyle;
@class CPTFill;
@class CPTShadow;

/**
 *  @brief Plot symbol types.
 **/
typedef NS_ENUM (NSInteger, CPTPlotSymbolType) {
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
};

@interface CPTPlotSymbol : NSObject<NSCoding, NSCopying>

@property (nonatomic, readwrite, assign) CGPoint anchorPoint;
@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CPTPlotSymbolType symbolType;
@property (nonatomic, readwrite, strong) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, strong) CPTFill *fill;
@property (nonatomic, readwrite, copy) CPTShadow *shadow;
@property (nonatomic, readwrite, assign) CGPathRef customSymbolPath;
@property (nonatomic, readwrite, assign) BOOL usesEvenOddClipRule;

/// @name Factory Methods
/// @{
+(instancetype)plotSymbol;
+(instancetype)crossPlotSymbol;
+(instancetype)ellipsePlotSymbol;
+(instancetype)rectanglePlotSymbol;
+(instancetype)plusPlotSymbol;
+(instancetype)starPlotSymbol;
+(instancetype)diamondPlotSymbol;
+(instancetype)trianglePlotSymbol;
+(instancetype)pentagonPlotSymbol;
+(instancetype)hexagonPlotSymbol;
+(instancetype)dashPlotSymbol;
+(instancetype)snowPlotSymbol;
+(instancetype)customPlotSymbolWithPath:(CGPathRef)aPath;
/// @}

/// @name Drawing
/// @{
-(void)renderInContext:(CGContextRef)context atPoint:(CGPoint)center scale:(CGFloat)scale alignToPixels:(BOOL)alignToPixels;
-(void)renderAsVectorInContext:(CGContextRef)context atPoint:(CGPoint)center scale:(CGFloat)scale;
/// @}

@end
