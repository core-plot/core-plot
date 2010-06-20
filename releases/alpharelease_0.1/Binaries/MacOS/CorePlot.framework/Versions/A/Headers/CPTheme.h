
#import <Foundation/Foundation.h>

@class CPGraph;
@class CPPlotAreaFrame;
@class CPAxisSet;
@class CPTextStyle;

/// @file

/// @name Theme Names
/// @{
extern NSString * const kCPDarkGradientTheme;
extern NSString * const kCPPlainWhiteTheme;
extern NSString * const kCPPlainBlackTheme;
extern NSString * const kCPSlateTheme;
extern NSString * const kCPStocksTheme;
/// @}

@interface CPTheme : NSObject {
	@private
	NSString *name;
	Class graphClass;
}

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, retain) Class graphClass;

/// @name Theme Management
/// @{
+(NSArray *)themeClasses;
+(CPTheme *)themeNamed:(NSString *)theme;
+(void)addTheme:(CPTheme *)newTheme;
+(NSString *)defaultName;
/// @}

/// @name Theme Usage
/// @{
-(void)applyThemeToGraph:(CPGraph *)graph;
/// @}

@end

/**	@category CPTheme(AbstractMethods)
 *	@brief CPTheme abstract methods—must be overridden by subclasses
 **/
@interface CPTheme(AbstractMethods)

/// @name Theme Usage
/// @{
-(id)newGraph;

-(void)applyThemeToBackground:(CPGraph *)graph;
-(void)applyThemeToPlotArea:(CPPlotAreaFrame *)plotAreaFrame;
-(void)applyThemeToAxisSet:(CPAxisSet *)axisSet; 
/// @}

@end
