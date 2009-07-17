
#import <Foundation/Foundation.h>

@class CPGraph;
@class CPXYGraph;
@class CPPlotArea;
@class CPXYPlotSpace;
@class CPAxisSet;
@class CPLineStyle;
@class CPTextStyle;
@class CPXYAxis;

/// @file

/// @name Theme Names
/// @{
extern NSString * const kCPDarkGradientTheme;
extern NSString * const kCPPlainWhiteTheme;
extern NSString * const kCPPlainBlackTheme;
extern NSString * const kCPStocksTheme;
/// @}

@interface CPTheme : NSObject {
	Class graphClass;
}

+(NSArray *)themeClasses;
+(CPTheme *)themeNamed:(NSString *)theme;
+(NSString *)name;

@property (nonatomic, assign) Class graphClass;

@end

@interface CPTheme(AbstractMethods)

-(id)newGraph;
-(void)applyThemeToGraph:(CPXYGraph *)graph;

@end