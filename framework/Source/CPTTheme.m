#import "CPTTheme.h"

#import "CPTExceptions.h"
#import "CPTGraph.h"

/** @defgroup themeNames Theme Names
 *  @brief Names of the predefined themes.
 **/

// Registered themes
static NSMutableSet *themes = nil;

/** @brief Creates a CPTGraph instance formatted with a predefined style.
 *
 *  Themes apply a predefined combination of line styles, text styles, and fills to
 *  the graph. The styles are applied to the axes, the plot area, and the graph itself.
 *  Using a theme to format the graph does not prevent any of the style properties
 *  from being changed later. Therefore, it is possible to apply initial formatting to
 *  a graph using a theme and then customize the styles to suit the application later.
 **/
@implementation CPTTheme

/** @property Class graphClass
 *  @brief The class used to create new graphs. Must be a subclass of CPTGraph.
 **/
@synthesize graphClass;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTTheme object.
 *
 *  The initialized object will have the following properties:
 *  - @ref graphClass = @Nil
 *
 *  @return The initialized object.
 **/
-(id)init
{
    if ( (self = [super init]) ) {
        graphClass = Nil;
    }
    return self;
}

/// @}

/// @cond

-(void)dealloc
{
    [graphClass release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[[self class] name] forKey:@"CPTTheme.name"];
    [coder encodeObject:NSStringFromClass(self.graphClass) forKey:@"CPTTheme.graphClass"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    [self release];
    self = [[CPTTheme themeNamed:[coder decodeObjectForKey:@"CPTTheme.name"]] retain];

    if ( self ) {
        self.graphClass = NSClassFromString([coder decodeObjectForKey:@"CPTTheme.graphClass"]);
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Theme management

/** @brief A list of the available theme classes, sorted by name.
 *  @return An NSArray containing all available theme classes, sorted by name.
 *  @if MacOnly
 *  @since Sorting is supported on MacOS 10.6 and later. Returns an unsorted array on earlier systems.
 *  @endif
 *  @if iOSOnly
 *  @since Sorting is supported on iOS 5 and later. Returns an unsorted array on earlier systems.
 *  @endif
 **/
+(NSArray *)themeClasses
{
#if MAC_OS_X_VERSION_10_6 <= MAC_OS_X_VERSION_MAX_ALLOWED || __IPHONE_5_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];

    return [themes sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameSort]];

#else
    return [themes allObjects];
#endif
}

/** @brief Gets a named theme.
 *  @param themeName The name of the desired theme.
 *  @return A CPTTheme instance with name matching @par{themeName} or @nil if no themes with a matching name were found.
 *  @see See @ref themeNames "Theme Names" for a list of named themes provided by Core Plot.
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

/** @brief Register a theme class.
 *  @param themeClass Theme class to register.
 **/
+(void)registerTheme:(Class)themeClass
{
    @synchronized(self)
    {
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

/** @brief The name used for this theme class.
 *  @return The name.
 **/
+(NSString *)name
{
    return NSStringFromClass(self);
}

#pragma mark -
#pragma mark Accessors

/// @cond

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

/// @endcond

#pragma mark -
#pragma mark Apply the theme

/** @brief Applies the theme to the provided graph.
 *  @param graph The graph to style.
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

/** @brief Creates a new graph styled with the theme.
 *  @return The new graph.
 **/
-(id)newGraph
{
    return nil;
}

/** @brief Applies the background theme to the provided graph.
 *  @param graph The graph to style.
 **/
-(void)applyThemeToBackground:(CPTGraph *)graph
{
}

/** @brief Applies the theme to the provided plot area.
 *  @param plotAreaFrame The plot area to style.
 **/
-(void)applyThemeToPlotArea:(CPTPlotAreaFrame *)plotAreaFrame
{
}

/** @brief Applies the theme to the provided axis set.
 *  @param axisSet The axis set to style.
 **/
-(void)applyThemeToAxisSet:(CPTAxisSet *)axisSet
{
}

@end
