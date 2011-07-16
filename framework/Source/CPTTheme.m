#import "CPTTheme.h"
#import "CPTExceptions.h"
#import "CPTDarkGradientTheme.h"
#import "CPTPlainBlackTheme.h"
#import "CPTPlainWhiteTheme.h"
#import "CPTStocksTheme.h"
#import "CPTSlateTheme.h"
#import "CPTGraph.h"

// theme names
NSString * const kCPTDarkGradientTheme = @"Dark Gradients";	///< Dark gradient theme.
NSString * const kCPTPlainWhiteTheme = @"Plain White";		///< Plain white theme.
NSString * const kCPTPlainBlackTheme = @"Plain Black";		///< Plain black theme.
NSString * const kCPTSlateTheme = @"Slate";		  			///< Slate theme.
NSString * const kCPTStocksTheme = @"Stocks";				///< Stocks theme.

// Registered themes
static NSMutableDictionary *themes = nil;

/** @brief Creates a CPTGraph instance formatted with predefined themes.
 *
 *	@todo More documentation needed 
 **/
@implementation CPTTheme

/** @property name
 *	@brief The name of the theme.
 **/
@synthesize name;

#pragma mark -
#pragma mark Init/dealloc

/** @property graphClass
 *	@brief The class used to create new graphs. Must be a subclass of CPTGraph.
 **/
@synthesize graphClass;

-(id)init
{
	if ( (self = [super init]) ) {
		name = nil;
		graphClass = Nil;
	}
	return self;
}

-(void)dealloc
{
	[name release];
	[graphClass release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:self.name forKey:@"CPTTheme.name"];
	
	// No need to archive these properties:
	// graphClass
}

-(id)initWithCoder:(NSCoder *)coder
{
	// use [self init] to initialize graphClass
    if ( (self = [self init]) ) {
		name = [[coder decodeObjectForKey:@"CPTTheme.name"] retain];
	}
    return self;
}

#pragma mark -
#pragma mark Accessors

-(void)setGraphClass:(Class)newGraphClass
{
	if ( graphClass != newGraphClass ) {
		if ( ![newGraphClass isSubclassOfClass:[CPTGraph class]] ) {
			[NSException raise:CPTException format:@"Invalid graph class for theme; must be a subclass of CPTGraph"];
		}
		else if ( [newGraphClass isEqual:[CPTGraph class]] ) {
			[NSException raise:CPTException format:@"Invalid graph class for theme; must be a subclass of CPTGraph"];
		}
		else {
			[graphClass release];
			graphClass = [newGraphClass retain];
		}
	}
}

/**	@brief List of the available themes.
 *	@return An NSArray with all available themes.
 **/
+(NSArray *)themeClasses {
	static NSArray *themeClasses = nil;
	if ( themeClasses == nil ) {
		themeClasses = [[NSArray alloc] initWithObjects:[CPTDarkGradientTheme class], [CPTPlainBlackTheme class], [CPTPlainWhiteTheme class],  [CPTSlateTheme class], [CPTStocksTheme class], nil];
	}
	return themeClasses;
}

/**	@brief Gets a named theme.
 *	@param themeName The name of the desired theme.
 *	@return A CPTTheme instance with name matching themeName or nil if no themes with a matching name were found.
 **/
+(CPTTheme *)themeNamed:(NSString *)themeName
{
	if ( themes == nil ) themes = [[NSMutableDictionary alloc] init];
	
	CPTTheme *theme = [themes objectForKey:themeName];
	if ( theme ) return theme;
	
	for ( Class themeClass in [CPTTheme themeClasses] ) {
		if ( [themeName isEqualToString:[themeClass defaultName]] ) {
			theme = [[themeClass alloc] init];
			[themes setObject:theme forKey:themeName];
			break;
		}
	}
	
	return [theme autorelease];
}

/**	@brief Register a theme for a given name.
 *	@param newTheme Theme to register.
 **/
+(void)addTheme:(CPTTheme *)newTheme
{
    CPTTheme *existingTheme = [self themeNamed:newTheme.name];
    if ( existingTheme ) {
        [NSException raise:CPTException format:@"Theme already exists with name %@", newTheme.name];
    }
    
    [themes setObject:newTheme forKey:newTheme.name];
}

/**	@brief The name used by default for this theme class.
 *	@return The name.
 **/
+(NSString *)defaultName 
{
	return NSStringFromClass(self);
}

-(NSString *)name 
{
	return [[(name ? name : [[self class] defaultName]) copy] autorelease];
}

/**	@brief Applies the theme to the provided graph.
 *	@param graph The graph to style.
 **/
-(void)applyThemeToGraph:(CPTGraph *)graph
{
	[self applyThemeToBackground:graph];
	[self applyThemeToPlotArea:graph.plotAreaFrame];
	[self applyThemeToAxisSet:graph.axisSet];    
}

@end

#pragma mark -

@implementation CPTTheme(AbstractMethods)

/**	@brief Creates a new graph styled with the theme.
 *	@return The new graph.
 **/
-(id)newGraph 
{
	return nil;
}

/**	@brief Applies the background theme to the provided graph.
 *	@param graph The graph to style.
 **/
-(void)applyThemeToBackground:(CPTGraph *)graph 
{
}

/**	@brief Applies the theme to the provided plot area.
 *	@param plotAreaFrame The plot area to style.
 **/
-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame
{
}

/**	@brief Applies the theme to the provided axis set.
 *	@param axisSet The axis set to style.
 **/
-(void)applyThemeToAxisSet:(CPTAxisSet *)axisSet
{
}

@end
