#import "CPTTheme.h"
#import "CPTExceptions.h"
#import "CPTGraph.h"

///	@defgroup themeNames Theme Names

// Registered themes
static NSMutableSet *themes = nil;

/** @brief Creates a CPTGraph instance formatted with predefined themes.
 *
 *	@todo More documentation needed 
 **/
@implementation CPTTheme

/** @property graphClass
 *	@brief The class used to create new graphs. Must be a subclass of CPTGraph.
 **/
@synthesize graphClass;

#pragma mark -
#pragma mark Init/dealloc

-(id)init
{
	if ( (self = [super init]) ) {
		graphClass = Nil;
	}
	return self;
}

-(void)dealloc
{
	[graphClass release];
	[super dealloc];
}

#pragma mark -
#pragma mark NSCoding methods

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:NSStringFromClass(self.graphClass) forKey:@"CPTTheme.graphClass"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super init]) ) {
		graphClass = [NSClassFromString([coder decodeObjectForKey:@"CPTTheme.graphClass"]) retain];
	}
    return self;
}

#pragma mark -
#pragma mark Theme management

/**	@brief List of the available theme classes, sorted by name.
 *	@return An NSArray containing all available theme classes, sorted by name.
 **/
+(NSArray *)themeClasses {
	NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
	
	return [themes sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSort]];
}

/**	@brief Gets a named theme.
 *	@param themeName The name of the desired theme.
 *	@return A CPTTheme instance with name matching themeName or nil if no themes with a matching name were found.
 **/
+(CPTTheme *)themeNamed:(NSString *)themeName
{
	CPTTheme *newTheme = nil;
	
	for ( Class themeClass in themes ) {
		if ( [themeName isEqualToString:[themeClass name]] ) {
			newTheme = [[themeClass alloc] init];
			break;
		}
	}
	
	return [newTheme autorelease];
}

/**	@brief Register a theme class.
 *	@param themeClass Theme class to register.
 **/
+(void)registerTheme:(Class)themeClass
{
	@synchronized(self) {
		if ( !themes ) {
			themes = [[NSMutableSet alloc] init];
		}

		if ( [themes containsObject:themeClass] ) {
			[NSException raise:CPTException format:@"Theme class already registered: %@", themeClass];
		}
		else {
			[themes addObject:themeClass];
		}
	}
}

/**	@brief The name used for this theme class.
 *	@return The name.
 **/
+(NSString *)name 
{
	return NSStringFromClass(self);
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

#pragma mark -
#pragma mark Apply the theme

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
