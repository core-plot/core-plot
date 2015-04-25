//
//  DetailViewController.m
//  CorePlotGallery
//

#import "DetailViewController.h"

#import "PlotItem.h"
#import "ThemeTableViewController.h"

@interface DetailViewController()

-(CPTTheme *)currentTheme;

@property (nonatomic, readwrite, weak) UIPopoverController *themePopoverController;

-(void)setupView;
-(void)themeChanged:(NSNotification *)notification;

@end

#pragma mark -

@implementation DetailViewController

@synthesize detailItem;
@synthesize hostingView;
@synthesize themeBarButton;
@synthesize currentThemeName;
@synthesize themePopoverController;

#pragma mark -
#pragma mark Initialization and Memory Management

-(void)setupView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChanged:)
                                                 name:PlotGalleryThemeDidChangeNotification
                                               object:nil];

    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Managing the detail item

-(void)setDetailItem:(PlotItem *)newDetailItem
{
    if ( detailItem != newDetailItem ) {
        [detailItem killGraph];

        detailItem = newDetailItem;

        if ( self.hostingView ) {
            [detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
        }
    }
}

#pragma mark -
#pragma mark View lifecycle

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self setupView];
}

#pragma mark -
#pragma mark Theme Selection

-(void)setCurrentThemeName:(NSString *)newThemeName
{
    if ( newThemeName != currentThemeName ) {
        currentThemeName = [newThemeName copy];

        self.themeBarButton.title = [NSString stringWithFormat:@"Theme: %@", newThemeName];
    }
}

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

-(void)themeSelectedWithName:(NSString *)themeName
{
    self.currentThemeName = themeName;

    [self.detailItem renderInView:self.hostingView withTheme:[self currentTheme] animated:YES];
}

-(void)themeChanged:(NSNotification *)notification
{
    NSDictionary *themeInfo = notification.userInfo;

    [self themeSelectedWithName:themeInfo[PlotGalleryThemeNameKey]];
}

#pragma mark -
#pragma mark Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"selectTheme"] ) {
        self.themePopoverController = segue.destinationViewController;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ( [identifier isEqualToString:@"selectTheme"] ) {
        UIPopoverController *controller = self.themePopoverController;

        if ( controller ) {
            [controller dismissPopoverAnimated:YES];
            return NO;
        }
        else {
            return YES;
        }
    }

    return YES;
}

@end
