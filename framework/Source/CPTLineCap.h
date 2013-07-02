/// @file

@class CPTLineStyle;
@class CPTFill;

/**
 *  @brief Line cap types.
 **/
typedef NS_ENUM (NSInteger, CPTLineCapType) {
    CPTLineCapTypeNone,       ///< No line cap.
    CPTLineCapTypeOpenArrow,  ///< Open arrow line cap.
    CPTLineCapTypeSolidArrow, ///< Solid arrow line cap.
    CPTLineCapTypeSweptArrow, ///< Swept arrow line cap.
    CPTLineCapTypeRectangle,  ///< Rectangle line cap.
    CPTLineCapTypeEllipse,    ///< Elliptical line cap.
    CPTLineCapTypeDiamond,    ///< Diamond line cap.
    CPTLineCapTypePentagon,   ///< Pentagon line cap.
    CPTLineCapTypeHexagon,    ///< Hexagon line cap.
    CPTLineCapTypeBar,        ///< Bar line cap.
    CPTLineCapTypeCross,      ///< X line cap.
    CPTLineCapTypeSnow,       ///< Snowflake line cap.
    CPTLineCapTypeCustom      ///< Custom line cap.
};

@interface CPTLineCap : NSObject<NSCoding, NSCopying>

@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CPTLineCapType lineCapType;
@property (nonatomic, readwrite, strong) CPTLineStyle *lineStyle;
@property (nonatomic, readwrite, strong) CPTFill *fill;
@property (nonatomic, readwrite, assign) CGPathRef customLineCapPath;
@property (nonatomic, readwrite, assign) BOOL usesEvenOddClipRule;

/// @name Factory Methods
/// @{
+(CPTLineCap *)lineCap;
+(CPTLineCap *)openArrowPlotLineCap;
+(CPTLineCap *)solidArrowPlotLineCap;
+(CPTLineCap *)sweptArrowPlotLineCap;
+(CPTLineCap *)rectanglePlotLineCap;
+(CPTLineCap *)ellipsePlotLineCap;
+(CPTLineCap *)diamondPlotLineCap;
+(CPTLineCap *)pentagonPlotLineCap;
+(CPTLineCap *)hexagonPlotLineCap;
+(CPTLineCap *)barPlotLineCap;
+(CPTLineCap *)crossPlotLineCap;
+(CPTLineCap *)snowPlotLineCap;
+(CPTLineCap *)customLineCapWithPath:(CGPathRef)aPath;
/// @}

/// @name Drawing
/// @{
-(void)renderAsVectorInContext:(CGContextRef)context atPoint:(CGPoint)center inDirection:(CGPoint)direction;
/// @}

@end
