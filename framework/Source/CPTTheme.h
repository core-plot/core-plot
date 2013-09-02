/// @ingroup themeNames
/// @{
extern NSString *const kCPTDarkGradientTheme; ///< A graph theme with dark gray gradient backgrounds and light gray lines.
extern NSString *const kCPTPlainBlackTheme;   ///< A graph theme with black backgrounds and white lines.
extern NSString *const kCPTPlainWhiteTheme;   ///< A graph theme with white backgrounds and black lines.
extern NSString *const kCPTSlateTheme;        ///< A graph theme with colors that match the default iPhone navigation bar, toolbar buttons, and table views.
extern NSString *const kCPTStocksTheme;       ///< A graph theme with a gradient background and white lines.
/// @}

@class CPTGraph;
@class CPTPlotAreaFrame;
@class CPTAxisSet;
@class CPTMutableTextStyle;

@interface CPTTheme : NSObject<NSCoding>

@property (nonatomic, readwrite, strong) Class graphClass;

/// @name Theme Management
/// @{
+(void)registerTheme:(Class)themeClass;
+(NSArray *)themeClasses;
+(instancetype)themeNamed:(NSString *)theme;
+(NSString *)name;
/// @}

/// @name Theme Usage
/// @{
-(void)applyThemeToGraph:(CPTGraph *)graph;
/// @}

@end

/** @category CPTTheme(AbstractMethods)
 *  @brief CPTTheme abstract methods—must be overridden by subclasses
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
