//
// PlotGalleryController.m
// CorePlotGallery
//

#import "PlotGalleryController.h"

#import "dlfcn.h"
// #define EMBED_NU  1

static const CGFloat CPT_SPLIT_VIEW_MIN_LHS_WIDTH = 150.0;

static NSString *const kThemeTableViewControllerNoTheme      = @"None";
static NSString *const kThemeTableViewControllerDefaultTheme = @"Default";

@interface PlotGalleryController()

@property (nonatomic, readwrite, strong, nullable) IBOutlet NSSplitView *splitView;
@property (nonatomic, readwrite, strong, nullable) IBOutlet NSScrollView *scrollView;
@property (nonatomic, readwrite, strong, nullable) IBOutlet IKImageBrowserView *imageBrowser;
@property (nonatomic, readwrite, strong, nullable) IBOutlet NSPopUpButton *themePopUpButton;

@property (nonatomic, readwrite, strong, nullable) IBOutlet PlotView *hostingView;

@end

@implementation PlotGalleryController

@synthesize splitView;
@synthesize scrollView;
@synthesize imageBrowser;
@synthesize themePopUpButton;

@synthesize hostingView;

@synthesize plotItem;
@synthesize currentThemeName;

-(void)setupThemes
{
    [self.themePopUpButton addItemWithTitle:kThemeTableViewControllerDefaultTheme];
    [self.themePopUpButton addItemWithTitle:kThemeTableViewControllerNoTheme];

    for ( Class c in [CPTTheme themeClasses] ) {
        [self.themePopUpButton addItemWithTitle:[c name]];
    }

    self.currentThemeName = kThemeTableViewControllerDefaultTheme;
    [self.themePopUpButton selectItemWithTitle:kThemeTableViewControllerDefaultTheme];
}

-(void)awakeFromNib
{
    [[PlotGallery sharedPlotGallery] sortByTitle];

    [self.splitView setDelegate:self];

    [self.imageBrowser setDelegate:self];
    [self.imageBrowser setDataSource:self];
    [self.imageBrowser setCellsStyleMask:IKCellsStyleShadowed | IKCellsStyleTitled]; // | IKCellsStyleSubtitled];

    [self.imageBrowser reloadData];

    [self.hostingView setDelegate:self];

    [self setupThemes];

#ifdef EMBED_NU
    // Setup a Nu console without the help of the Nu include files or
    // an explicit link of the Nu framework, which may not be installed
    nuHandle = dlopen("/Library/Frameworks/Nu.framework/Nu", RTLD_LAZY);

    if ( nuHandle ) {
        NSString *consoleStartup =
            @"(progn \
           (load \"console\") \
           (set $console ((NuConsoleWindowController alloc) init)))";

        Class nuClass = NSClassFromString(@"Nu");
        id parser     = [nuClass performSelector:@selector(parser)];
        id code       = [parser performSelector:@selector(parse:) withObject:consoleStartup];
        [parser performSelector:@selector(eval:) withObject:code];
    }
#endif
}

-(void)dealloc
{
    [self setPlotItem:nil];

    [splitView setDelegate:nil];
    [imageBrowser setDataSource:nil];
    [imageBrowser setDelegate:nil];
    [hostingView setDelegate:nil];

#ifdef EMBED_NU
    if ( nuHandle ) {
        dlclose(nuHandle);
    }
#endif
}

-(void)setFrameSize:(NSSize)newSize
{
    if ( [self.plotItem respondsToSelector:@selector(setFrameSize:)] ) {
        [self.plotItem setFrameSize:newSize];
    }
}

#pragma mark -
#pragma mark Theme Selection

-(nullable CPTTheme *)currentTheme
{
    CPTTheme *theme;

    if ( [self.currentThemeName isEqualToString:kThemeTableViewControllerNoTheme] ) {
        theme = (id)[NSNull null];
    }
    else if ( [self.currentThemeName isEqualToString:kThemeTableViewControllerDefaultTheme] ) {
        theme = nil;
    }
    else {
        theme = [CPTTheme themeNamed:self.currentThemeName];
    }

    return theme;
}

-(IBAction)themeSelectionDidChange:(nonnull id)sender
{
    self.currentThemeName = [sender titleOfSelectedItem];

    PlotView *hostView = self.hostingView;
    if ( hostView ) {
        [self.plotItem renderInView:hostView withTheme:[self currentTheme] animated:YES];
    }
}

#pragma mark -
#pragma mark PlotItem Property

-(void)setPlotItem:(nullable PlotItem *)item
{
    if ( plotItem != item ) {
        [plotItem killGraph];

        plotItem = item;

        PlotView *hostView = self.hostingView;
        if ( hostView ) {
            [plotItem renderInView:hostView withTheme:[self currentTheme] animated:YES];
        }
    }
}

#pragma mark -
#pragma mark IKImageBrowserViewDataSource methods

-(NSUInteger)numberOfItemsInImageBrowser:(nonnull IKImageBrowserView *)browser
{
    return [[PlotGallery sharedPlotGallery] count];
}

-(nonnull id)imageBrowser:(nonnull IKImageBrowserView *)browser itemAtIndex:(NSUInteger)index
{
    return [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:index];
}

-(NSUInteger)numberOfGroupsInImageBrowser:(nonnull IKImageBrowserView *)aBrowser
{
    return [[PlotGallery sharedPlotGallery] numberOfSections];
}

-(nonnull CPTDictionary)imageBrowser:(nonnull IKImageBrowserView *)aBrowser groupAtIndex:(NSUInteger)index
{
    NSString *groupTitle = [[PlotGallery sharedPlotGallery] sectionTitles][index];

    NSUInteger offset = 0;

    for ( NSUInteger i = 0; i < index; i++ ) {
        offset += [[PlotGallery sharedPlotGallery] numberOfRowsInSection:i];
    }

    NSValue *groupRange = [NSValue valueWithRange:NSMakeRange(offset, [[PlotGallery sharedPlotGallery] numberOfRowsInSection:index])];

    return @{
               IKImageBrowserGroupStyleKey: @(IKGroupDisclosureStyle),
               IKImageBrowserGroupTitleKey: groupTitle,
               IKImageBrowserGroupRangeKey: groupRange
    };
}

#pragma mark -
#pragma mark IKImageBrowserViewDelegate methods

-(void)imageBrowserSelectionDidChange:(nonnull IKImageBrowserView *)browser
{
    NSUInteger index = [[browser selectionIndexes] firstIndex];

    if ( index != NSNotFound ) {
        PlotItem *item = [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:index];
        self.plotItem = item;
    }
}

#pragma mark -
#pragma mark NSSplitViewDelegate methods

-(CGFloat)splitView:(nonnull NSSplitView *)sv constrainMinCoordinate:(CGFloat)coord ofSubviewAt:(NSInteger)index
{
    return coord + CPT_SPLIT_VIEW_MIN_LHS_WIDTH;
}

-(CGFloat)splitView:(nonnull NSSplitView *)sv constrainMaxCoordinate:(CGFloat)coord ofSubviewAt:(NSInteger)index
{
    return coord - CPT_SPLIT_VIEW_MIN_LHS_WIDTH;
}

-(void)splitView:(nonnull NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    // Lock the LHS width
    NSRect frame   = [sender frame];
    NSView *lhs    = [sender subviews][0];
    NSRect lhsRect = [lhs frame];
    NSView *rhs    = [sender subviews][1];
    NSRect rhsRect = [rhs frame];

    CGFloat dividerThickness = [sender dividerThickness];

    lhsRect.size.height = frame.size.height;

    rhsRect.size.width  = frame.size.width - lhsRect.size.width - dividerThickness;
    rhsRect.size.height = frame.size.height;
    rhsRect.origin.x    = lhsRect.size.width + dividerThickness;

    [lhs setFrame:lhsRect];
    [rhs setFrame:rhsRect];
}

@end
