
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

/// @defgroup CPTheme CPTheme
/// @{

/**	@property graphClass
 *	@brief The class of the graph object to create.
 **/
@synthesize graphClass;

/**	@brief List of the available themes.
 *	@return An NSArray with all available themes.
 **/
+(NSArray *)themeClasses {
	static NSArray *themeClasses = nil;
	if ( themeClasses == nil ) {
		themeClasses = [[NSArray alloc] initWithObjects:[CPDarkGradientTheme class], [CPPlainBlackTheme class], [CPPlainWhiteTheme class],  [CPStocksTheme class], nil];
	}
	return themeClasses;
}

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
	
	for ( Class themeClass in [CPTheme themeClasses] ) {
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

/**	@brief A subclass of CPGraph that the graphClass must descend from.
 *	@return The required subclass.
 **/
+(Class)requiredGraphSubclass
{
    return [CPGraph class];
}

/**	@brief Sets the class used when creating a new graph
 *	@param newGraphClass the type of class, must inherit from CPGraph
 **/
-(void)setGraphClass:(Class)newGraphClass 
{
	if ( newGraphClass != Nil && ![newGraphClass isSubclassOfClass:[[self class] requiredGraphSubclass]] ) {
		[NSException raise:CPException format:@"newGraphClass must be a subclass of %@", [[self class] requiredGraphSubclass]];
	}
	if ( graphClass != newGraphClass ) {
        graphClass = newGraphClass;
    }
}
///	@}

@end

///	@brief CPTheme abstract methods—must be overridden by subclasses
@implementation CPTheme(AbstractMethods)

/// @addtogroup CPTheme
/// @{

/** @brief Creates and returns a new CPGraph instance formatted with the theme.
 *  @return A new CPGraph instance formatted with the theme.
 **/
-(id)newGraph
{
	return nil;
}

/**	@brief Applies the theme to the provided graph.
 *	@param graph The graph to style.
 **/
-(void)applyThemeToGraph:(CPGraph *)graph
{
}

///	@}

@end
