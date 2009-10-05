
#import <Foundation/Foundation.h>

@class CPGraph;
@class CPPlotArea;
@class CPAxisSet;
@class CPTextStyle;

/// @file

/// @name Theme Names
/// @{
extern NSString * const kCPDarkGradientTheme;
extern NSString * const kCPPlainWhiteTheme;
extern NSString * const kCPPlainBlackTheme;
extern NSString * const kCPStocksTheme;
/// @}

@interface CPTheme : NSObject {	
	NSString *name;
}

@property (copy) NSString *name;

+(NSArray *)themeClasses;
+(CPTheme *)themeNamed:(NSString *)theme;
+(void)addTheme:(CPTheme *)newTheme;

-(NSString *)name;
+(NSString *)defaultName;

-(void)applyThemeToGraph:(CPGraph *)graph;
-(void)applyThemeToBackground:(CPGraph *)graph;
-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea;
-(void)applyThemeToAxisSet:(CPAxisSet *)axisSet; 

@end