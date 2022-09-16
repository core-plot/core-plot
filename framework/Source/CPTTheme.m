#import "CPTTheme.h"

#import "CPTExceptions.h"
#import "CPTGraph.h"
#import <objc/runtime.h>

/// @cond

/**
 *  @brief A dictionary with CPTThemeName keys and Class values.
 **/
typedef NSDictionary<CPTThemeName, Class> CPTThemeDictionary;

/**
 *  @brief A mutable dictionary with CPTThemeName keys and Class values.
 **/
typedef NSMutableDictionary<CPTThemeName, Class> CPTMutableThemeDictionary;

@interface CPTTheme()

NSArray * ClassGetSubclasses(Class parentClass);

+(nonnull CPTThemeDictionary *)themeDictionary;

@end

#pragma mark -

/// @endcond

/** @defgroup themeNames Theme Names
 *  @brief Names of the predefined themes.
 **/

/** @brief Creates a CPTGraph instance formatted with a predefined style.
 *
 *  Themes apply a predefined combination of line styles, text styles, and fills to
 *  the graph. The styles are applied to the axes, the plot area, and the graph itself.
 *  Using a theme to format the graph does not prevent any of the style properties
 *  from being changed later. Therefore, it is possible to apply initial formatting to
 *  a graph using a theme and then customize the styles to suit the application later.
 **/
@implementation CPTTheme

/** @property nullable Class graphClass
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
-(nonnull instancetype)init
{
    if ((self = [super init])) {
        graphClass = Nil;
    }
    return self;
}

/// @}

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(nonnull NSCoder *)coder
{
    [coder encodeObject:[[self class] name] forKey:@"CPTTheme.name"];

    Class theGraphClass = self.graphClass;

    if ( theGraphClass ) {
        [coder encodeObject:NSStringFromClass(theGraphClass) forKey:@"CPTTheme.graphClass"];
    }
}

-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder
{
    self = [CPTTheme themeNamed:[coder decodeObjectOfClass:[NSString class]
                                                    forKey:@"CPTTheme.name"]];

    if ( self ) {
        NSString *className = [coder decodeObjectOfClass:[NSString class]
                                                  forKey:@"CPTTheme.graphClass"];
        if ( className ) {
            self.graphClass = NSClassFromString(className);
        }
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark NSSecureCoding Methods

/// @cond

+(BOOL)supportsSecureCoding
{
    return YES;
}

/// @endcond

#pragma mark -
#pragma mark Theme management

/// @cond

// Code from https://stackoverflow.com/questions/7923586/objective-c-get-list-of-subclasses-from-superclass/23038932
NSArray<Class> *ClassGetSubclasses(Class parentClass)
{
    int numClasses = objc_getClassList(NULL, 0);

    // According to the docs of objc_getClassList we should check
    // if numClasses is bigger than 0.
    if ( numClasses <= 0 ) {
        return [NSArray array];
    }

    size_t memSize = sizeof(Class) * (size_t)numClasses;
    Class *classes = (__unsafe_unretained Class *)malloc(memSize);

    if ((classes == NULL) && memSize ) {
        return [NSArray array];
    }

    numClasses = objc_getClassList(classes, numClasses);

    NSMutableArray<Class> *result = [NSMutableArray new];

    for ( NSInteger i = 0; i < numClasses; i++ ) {
        Class superClass = classes[i];

        // Don't add the parent class to list of sublcasses
        if ( superClass == parentClass ) {
            continue;
        }

        // Using a do while loop, like pointed out in Cocoa with Love,
        // can lead to EXC_I386_GPFLT, which stands for General
        // Protection Fault and means we are doing something we
        // shouldn't do. It's safer to use a regular while loop to
        // check if superClass is valid.
        while ( superClass && superClass != parentClass ) {
            superClass = class_getSuperclass(superClass);
        }

        if ( superClass ) {
            [result addObject:classes[i]];
        }
    }

    free(classes);

    return result;
}

/** @brief A shared CPTAnimation instance responsible for scheduling and executing animations.
 *  @return The shared CPTAnimation instance.
 **/
+(nonnull CPTThemeDictionary *)themeDictionary
{
    static dispatch_once_t once = 0;
    static CPTThemeDictionary *themes;

    dispatch_once(&once, ^{
        CPTMutableThemeDictionary *mutThemes = [[CPTMutableThemeDictionary alloc] init];

        for ( Class cls in ClassGetSubclasses(self)) {
            CPTThemeName themeName = [cls name];

            if ( themeName.length > 0 ) {
                [mutThemes setObject:cls forKey:themeName];
            }
        }

        themes = [mutThemes copy];
    });

    return themes;
}

/// @endcond

/** @brief List of the available theme classes, sorted by name.
 *  @return An NSArray containing all available theme classes, sorted by name.
 **/
+(nullable NSArray<Class> *)themeClasses
{
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];

    return [[self themeDictionary].allValues sortedArrayUsingDescriptors:@[nameSort]];
}

/** @brief Gets a named theme.
 *  @param  themeName The name of the desired theme.
 *  @return           A CPTTheme instance with name matching @par{themeName} or @nil if no themes with a matching name were found.
 *  @see              See @ref themeNames "Theme Names" for a list of named themes provided by Core Plot.
 **/
+(nullable instancetype)themeNamed:(nullable CPTThemeName)themeName
{
    CPTTheme *newTheme = nil;

    CPTThemeName theName = themeName;

    if ( theName ) {
        Class themeClass = [self themeDictionary][theName];
        newTheme = [[themeClass alloc] init];
    }

    return newTheme;
}

/** @brief The name used for this theme class.
 *  @return The name.
 **/
+(nonnull CPTThemeName)name
{
    return @"";
}

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setGraphClass:(nullable Class)newGraphClass
{
    if ( graphClass != newGraphClass ) {
        if ( ![newGraphClass isSubclassOfClass:[CPTGraph class]] ) {
            [NSException raise:CPTException format:@"Invalid graph class for theme; must be a subclass of CPTGraph"];
        }
        else if ( [newGraphClass isEqual:[CPTGraph class]] ) {
            [NSException raise:CPTException format:@"Invalid graph class for theme; must be a subclass of CPTGraph"];
        }
        else {
            graphClass = newGraphClass;
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Apply the theme

/** @brief Applies the theme to the provided graph.
 *  @param graph The graph to style.
 **/
-(void)applyThemeToGraph:(nonnull CPTGraph *)graph
{
    [self applyThemeToBackground:graph];

    CPTPlotAreaFrame *plotAreaFrame = graph.plotAreaFrame;

    if ( plotAreaFrame ) {
        [self applyThemeToPlotArea:plotAreaFrame];
    }

    CPTAxisSet *axisSet = graph.axisSet;

    if ( axisSet ) {
        [self applyThemeToAxisSet:axisSet];
    }
}

@end

#pragma mark -

@implementation CPTTheme(AbstractMethods)

/** @brief Creates a new graph styled with the theme.
 *  @return The new graph.
 **/
-(nullable id)newGraph
{
    return nil;
}

/** @brief Applies the background theme to the provided graph.
 *  @param graph The graph to style.
 **/
-(void)applyThemeToBackground:(nonnull CPTGraph *__unused)graph
{
}

/** @brief Applies the theme to the provided plot area.
 *  @param plotAreaFrame The plot area to style.
 **/
-(void)applyThemeToPlotArea:(nonnull CPTPlotAreaFrame *__unused)plotAreaFrame
{
}

/** @brief Applies the theme to the provided axis set.
 *  @param axisSet The axis set to style.
 **/
-(void)applyThemeToAxisSet:(nonnull CPTAxisSet *__unused)axisSet
{
}

@end
