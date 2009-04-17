#import <Foundation/Foundation.h>
#import "CPDefinitions.h"

@class CPLineStyle;

@interface CPPlotSymbol : NSObject <NSCopying> {
	@private
	CGSize size;
	CPPlotSymbolType symbolType;
	CPLineStyle *lineStyle;
	CGColorRef fillColor;
}

@property (assign) CGSize size;
@property (assign) CPPlotSymbolType symbolType;
@property (retain) CPLineStyle *lineStyle;
@property (assign) CGColorRef fillColor;

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
//+(CPPlotSymbol *)plotSymbolWithString:(NSString *)aString;
//+(CPPlotSymbol *)plotSymbolWithImage:(CGImageRef)anImage;

-(id)copyWithZone:(NSZone *)zone;
-(void)renderInContext:(CGContextRef)theContext AtPoint:(CGPoint)center;

@end
