#import <Foundation/Foundation.h>

@class CPTGraph;
@class CPTPlotAreaFrame;
@class CPTAxisSet;
@class CPTMutableTextStyle;

/// @file

/// @name Theme Names
/// @{
extern NSString * const kCPTDarkGradientTheme;
extern NSString * const kCPTPlainWhiteTheme;
extern NSString * const kCPTPlainBlackTheme;
extern NSString * const kCPTSlateTheme;
extern NSString * const kCPTStocksTheme;
/// @}

@interface CPTTheme : NSObject <NSCoding> {
	@private
	NSString *name;
	Class graphClass;
}

@property (nonatomic, readwrite, copy) NSString *name;
@property (nonatomic, readwrite, retain) Class graphClass;

/// @name Theme Management
/// @{
+(NSArray *)themeClasses;
+(CPTTheme *)themeNamed:(NSString *)theme;
+(void)addTheme:(CPTTheme *)newTheme;
+(NSString *)defaultName;
/// @}

/// @name Theme Usage
/// @{
-(void)applyThemeToGraph:(CPTGraph *)graph;
/// @}

@end

/**	@category CPTTheme(AbstractMethods)
 *	@brief CPTTheme abstract methods—must be overridden by subclasses
 **/
@interface CPTTheme(AbstractMethods)

/// @name Theme Usage
/// @{
-(id)newGraph;

-(void)applyThemeToBackground:(CPTGraph *)graph;
-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame;
-(void)applyThemeToAxisSet:(CPTAxisSet *)axisSet; 
/// @}

@end
