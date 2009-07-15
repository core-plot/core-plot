
#import "CPTheme.h"
#import "CPExceptions.h"
#import "CPDarkGradientTheme.h"
#import "CPPlainBlackTheme.h"
#import "CPPlainWhiteTheme.h"
#import "CPStocksTheme.h"
#import "CPGraph.h"
#import "CPXYGraph.h"

// theme names
NSString * const kCPDarkGradientTheme = @"Dark Gradients";	///< Dark gradient theme.
NSString * const kCPPlainWhiteTheme = @"Plain White";		///< Plain white theme.
NSString * const kCPPlainBlackTheme = @"Plain Black";		///< Plain black theme.
NSString * const kCPStocksTheme = @"Stocks";				///< Stocks theme.

/** @brief Creates a CPGraph instance formatted with predefined themes.
 *
 *	@todo More documentation needed 
 **/

@implementation CPTheme

@synthesize graphClass;

+(NSArray *)themes {
	static NSArray *themeClasses = nil;
	if ( themeClasses == nil ) {
		themeClasses = [[NSArray alloc] initWithObjects:[CPDarkGradientTheme class], [CPPlainBlackTheme class], [CPPlainWhiteTheme class],  [CPStocksTheme class], nil];
	}
	return themeClasses;
}

/// @defgroup CPTheme CPTheme Methods
/// @{

/**	@brief Gets a named theme.
 *	@param themeName The name of the desired theme.
 *	@return A CPTheme instance with name matching themeName or nil if no themes with a matching name were found.
 **/
+(CPTheme *)themeNamed:(NSString *)themeName
{
	static NSMutableDictionary *themes = nil;
	if ( themes == nil ) themes = [[NSMutableDictionary alloc] init];
	
	CPTheme *theme = [themes objectForKey:themeName];
	if ( theme ) return theme;
	
	for ( Class themeClass in [CPTheme themes] ) {
		if ( [themeName isEqualToString:[themeClass name]] ) {
			theme = [[themeClass alloc] init];
			[themes setObject:theme forKey:themeName];
			break;
		}
	}
	
	return [theme autorelease];
}

/**	@brief The name of the theme.
 *	@return The name.
 **/
+(NSString *)name 
{
	return NSStringFromClass(self);
}


-(void)setGraphClass:(Class)newGraphClass 
{
	if ( newGraphClass && ![newGraphClass isSubclassOfClass:[CPXYGraph class]] ) {
		[NSException raise:CPException format:@"newGraphClass must be a subclass of CPXYGraph"];
	}
	
	graphClass = newGraphClass;
}
///	@}

@end

///	@brief CPTheme abstract methods—must be overridden by subclasses
@implementation CPTheme(AbstractMethods)

/// @addtogroup CPTheme CPTheme Methods
/// @{

/** @brief Creates and returns a new CPGraph instance formatted with the theme.
 *  @return A new CPGraph instance formatted with the theme.
 **/
-(id)newGraph
{
	return nil;
}

///	@}

@end
