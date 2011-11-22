#import <Foundation/Foundation.h>

///	@ingroup themeNames
/// @{
extern NSString *const kCPTDarkGradientTheme;
extern NSString *const kCPTPlainBlackTheme;
extern NSString *const kCPTPlainWhiteTheme;
extern NSString *const kCPTSlateTheme;
extern NSString *const kCPTStocksTheme;
/// @}

@class CPTGraph;
@class CPTPlotAreaFrame;
@class CPTAxisSet;
@class CPTMutableTextStyle;

@interface CPTTheme : NSObject<NSCoding> {
	@private
	Class graphClass;
}

@property (nonatomic, readwrite, retain) Class graphClass;

/// @name Theme Management
/// @{
+(void)registerTheme:(Class)themeClass;
+(NSArray *)themeClasses;
+(CPTTheme *)themeNamed:(NSString *)theme;
+(NSString *)name;
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
