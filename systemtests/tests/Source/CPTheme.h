
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
	@private
	NSString *name;
	Class graphClass;
}

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, retain) Class graphClass;

+(NSArray *)themeClasses;
+(CPTheme *)themeNamed:(NSString *)theme;
+(void)addTheme:(CPTheme *)newTheme;

+(NSString *)defaultName;

-(id)newGraph;

-(void)applyThemeToGraph:(CPGraph *)graph;
-(void)applyThemeToBackground:(CPGraph *)graph;
-(void)applyThemeToPlotArea:(CPPlotArea *)plotArea;
-(void)applyThemeToAxisSet:(CPAxisSet *)axisSet; 

@end