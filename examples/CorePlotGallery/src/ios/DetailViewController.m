//
//  DetailViewController.m
//  CorePlotGallery
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "ThemeTableViewController.h"

@interface DetailViewController()

@property (nonatomic, readwrite, strong) UIPopoverController *popoverController;
@property (nonatomic, readwrite, strong) UIPopoverController *themePopoverController;

-(CPTTheme *)currentTheme;

@end

@implementation DetailViewController

@synthesize toolbar;
@synthesize popoverController;
@synthesize detailItem;
@synthesize hostingView;
@synthesize themeBarButton;
@synthesize themeTableViewController;
@synthesize themePopoverController;
@synthesize currentThemeName;

#pragma mark -
#pragma mark Initialization and Memory Management

-(void)setupView
{
    NSString *themeString = [NSString stringWithFormat:@"Theme: %@", kThemeTableViewControllerDefaultTheme];

    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ) {
        self.themeBarButton = [[UIBarButtonItem alloc] initWithTitle:themeString style:UIBarButtonItemStylePlain target:self action:@selector(showThemes:)];
        [[self navigationItem] setRightBarButtonItem:self.themeBarButton];
    }

    self.currentThemeName = [NSString stringWithFormat:@"Theme: %@", kThemeTableViewControllerDefaultTheme];
}

-(void)awakeFromNib
{
    [self setupView];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
        [self setupView];
    }

    return self;
}

#pragma mark -
#pragma mark Managing the detail item

-(void)setDetailItem:(id)newDetailItem
{
    if ( detailItem != newDetailItem ) {
        [detailItem killGraph];

        detailItem = newDetailItem;
        [detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
    }

    [self.popoverController dismissPopoverAnimated:YES];
}

#pragma mark -
#pragma mark Split view support

-(void)splitViewController:(UISplitViewController *)svc
    willHideViewController:(UIViewController *)aViewController
         withBarButtonItem:(UIBarButtonItem *)barButtonItem
      forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Plot Gallery";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = pc;
}

-(void)   splitViewController:(UISplitViewController *)svc
       willShowViewController:(UIViewController *)aViewController
    invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];

    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    self.popoverController = nil;
}

#pragma mark -
#pragma mark Rotation support

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad ) {
        self.hostingView.frame = self.view.bounds;
    }
    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
}

#pragma mark -
#pragma mark View lifecycle

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    self.themeBarButton.title = self.currentThemeName;
}

#pragma mark -
#pragma mark Theme Selection

-(CPTTheme *)currentTheme
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

-(void)closeThemePopover
{
    // Cancel the popover
    [self.themePopoverController dismissPopoverAnimated:YES];
    self.themePopoverController = nil;
}

-(IBAction)showThemes:(id)sender
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        if ( self.themePopoverController == nil ) {
            self.themePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.themeTableViewController];
            [self.themeTableViewController setThemePopoverController:self.themePopoverController];
            [self.themePopoverController setPopoverContentSize:CGSizeMake(320, 320)];
            [self.themePopoverController presentPopoverFromBarButtonItem:self.themeBarButton
                                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                animated:YES];
        }
        else {
            [self closeThemePopover];
        }
    }
    else {
        self.themeTableViewController = [[ThemeTableViewController alloc] initWithNibName:@"ThemeTableViewController" bundle:nil];
        [self.navigationController pushViewController:self.themeTableViewController animated:YES];
        self.themeTableViewController.delegate = self;
    }
}

-(void)themeSelectedAtIndex:(NSString *)themeName
{
    self.themeBarButton.title = [NSString stringWithFormat:@"Theme: %@", themeName];
    self.currentThemeName     = themeName;

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        [self closeThemePopover];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
        self.themeTableViewController.delegate = nil;
        self.themeTableViewController          = nil;
    }

    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
}

@end
