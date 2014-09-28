//
//  PlotGalleryController.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/5/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotGalleryController.h"

#import "dlfcn.h"
//#define EMBED_NU	1

const CGFloat CPT_SPLIT_VIEW_MIN_LHS_WIDTH = 150.0;

#define kThemeTableViewControllerNoTheme      @"None"
#define kThemeTableViewControllerDefaultTheme @"Default"

@implementation PlotGalleryController

@dynamic plotItem;
@synthesize currentThemeName;

-(void)setupThemes
{
    [themePopUpButton addItemWithTitle:kThemeTableViewControllerDefaultTheme];
    [themePopUpButton addItemWithTitle:kThemeTableViewControllerNoTheme];

    for ( Class c in [CPTTheme themeClasses] ) {
        [themePopUpButton addItemWithTitle:[c name]];
    }

    self.currentThemeName = kThemeTableViewControllerDefaultTheme;
    [themePopUpButton selectItemWithTitle:kThemeTableViewControllerDefaultTheme];
}

-(void)awakeFromNib
{
    [[PlotGallery sharedPlotGallery] sortByTitle];

    [splitView setDelegate:self];

    [imageBrowser setDelegate:self];
    [imageBrowser setDataSource:self];
    [imageBrowser setCellsStyleMask:IKCellsStyleShadowed | IKCellsStyleTitled]; //| IKCellsStyleSubtitled];

    [imageBrowser reloadData];

    [hostingView setDelegate:self];

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
    if ( [plotItem respondsToSelector:@selector(setFrameSize:)] ) {
        [plotItem setFrameSize:newSize];
    }
}

#pragma mark -
#pragma mark Theme Selection

-(CPTTheme *)currentTheme
{
    CPTTheme *theme;

    if ( [currentThemeName isEqualToString:kThemeTableViewControllerNoTheme] ) {
        theme = (id)[NSNull null];
    }
    else if ( [currentThemeName isEqualToString:kThemeTableViewControllerDefaultTheme] ) {
        theme = nil;
    }
    else {
        theme = [CPTTheme themeNamed:currentThemeName];
    }

    return theme;
}

-(IBAction)themeSelectionDidChange:(id)sender
{
    self.currentThemeName = [sender titleOfSelectedItem];
    [plotItem renderInView:hostingView withTheme:[self currentTheme] animated:YES];
}

#pragma mark -
#pragma mark PlotItem Property

-(PlotItem *)plotItem
{
    return plotItem;
}

-(void)setPlotItem:(PlotItem *)item
{
    if ( plotItem != item ) {
        [plotItem killGraph];

        plotItem = item;

        [plotItem renderInView:hostingView withTheme:[self currentTheme] animated:YES];
    }
}

#pragma mark -
#pragma mark IKImageBrowserViewDataSource methods

-(NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)browser
{
    return [[PlotGallery sharedPlotGallery] count];
}

-(id)imageBrowser:(IKImageBrowserView *)browser itemAtIndex:(NSUInteger)index
{
    return [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:index];
}

-(NSUInteger)numberOfGroupsInImageBrowser:(IKImageBrowserView *)aBrowser
{
    return [[PlotGallery sharedPlotGallery] numberOfSections];
}

-(NSDictionary *)imageBrowser:(IKImageBrowserView *)aBrowser groupAtIndex:(NSUInteger)index
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

-(void)imageBrowserSelectionDidChange:(IKImageBrowserView *)browser
{
    NSUInteger index = [[browser selectionIndexes] firstIndex];

    if ( index != NSNotFound ) {
        PlotItem *item = [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:index];
        self.plotItem = item;
    }
}

#pragma mark -
#pragma mark NSSplitViewDelegate methods

-(CGFloat)splitView:(NSSplitView *)sv constrainMinCoordinate:(CGFloat)coord ofSubviewAt:(NSInteger)index
{
    return coord + CPT_SPLIT_VIEW_MIN_LHS_WIDTH;
}

-(CGFloat)splitView:(NSSplitView *)sv constrainMaxCoordinate:(CGFloat)coord ofSubviewAt:(NSInteger)index
{
    return coord - CPT_SPLIT_VIEW_MIN_LHS_WIDTH;
}

-(void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
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
