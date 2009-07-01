#import <Foundation/Foundation.h>

@class CPLineStyle;
@class CPFill;

typedef enum _CPPlotSymbolType {
    CPPlotSymbolTypeNone,
    CPPlotSymbolTypeRectangle,
    CPPlotSymbolTypeEllipse,
    CPPlotSymbolTypeDiamond,
	CPPlotSymbolTypeTriangle,
	CPPlotSymbolTypeStar,
	CPPlotSymbolTypePentagon,
	CPPlotSymbolTypeHexagon,
	CPPlotSymbolTypeCross,
	CPPlotSymbolTypePlus,
	CPPlotSymbolTypeDash,
	CPPlotSymbolTypeSnow,
	CPPlotSymbolTypeCustom
} CPPlotSymbolType;


@interface CPPlotSymbol : NSObject <NSCopying> {
@private
	CGSize size;
	CPPlotSymbolType symbolType;
	CPLineStyle *lineStyle;
	CPFill *fill;
	CGMutablePathRef symbolPath;
	CGPathRef customSymbolPath;
	BOOL usesEvenOddClipRule;
}

@property (nonatomic, readwrite, assign) CGSize size;
@property (nonatomic, readwrite, assign) CPPlotSymbolType symbolType;
@property (nonatomic, readwrite, retain) CPLineStyle *lineStyle;
@property (nonatomic, readwrite, retain) CPFill *fill;
@property (nonatomic, readwrite, assign) CGPathRef customSymbolPath;
@property (nonatomic, readwrite, assign) BOOL usesEvenOddClipRule;

// Plot symbols
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
//+(CPPlotSymbol *)plotSymbolWithString:(NSString *)aString;

// Drawing
-(void)renderInContext:(CGContextRef)theContext atPoint:(CGPoint)center;

@end
