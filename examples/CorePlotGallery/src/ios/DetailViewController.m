//
// DetailViewController.m
// CorePlotGallery
//

#import "DetailViewController.h"

#import "PlotItem.h"
#import "ThemeTableViewController.h"

@interface DetailViewController()

-(nullable CPTTheme *)currentTheme;

-(void)setupView;
-(void)themeChanged:(nonnull NSNotification *)notification;

@end

#pragma mark -

@implementation DetailViewController

@synthesize detailItem;
@synthesize hostingView;
@synthesize themeBarButton;
@synthesize currentThemeName;

#pragma mark -
#pragma mark Initialization and Memory Management

-(void)setupView
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChanged:)
                                                 name:PlotGalleryThemeDidChangeNotification
                                               object:nil];

    UIView *hostView = self.hostingView;
    if ( hostView ) {
        [self.detailItem renderInView:hostView withTheme:[self currentTheme] animated:YES];
    }
}

-(void)awakeFromNib
{
    [self setupView];
}

-(nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
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

-(void)setDetailItem:(nonnull PlotItem *)newDetailItem
{
    if ( detailItem != newDetailItem ) {
        [detailItem killGraph];

        detailItem = newDetailItem;

        UIView *hostView = self.hostingView;
        if ( hostView ) {
            [detailItem renderInView:hostView withTheme:[self currentTheme] animated:YES];
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

-(void)setCurrentThemeName:(nonnull NSString *)newThemeName
{
    if ( newThemeName != currentThemeName ) {
        currentThemeName = [newThemeName copy];

        self.themeBarButton.title = [NSString stringWithFormat:@"Theme: %@", newThemeName];
    }
}

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

-(void)themeSelectedWithName:(nonnull NSString *)themeName
{
    self.currentThemeName = themeName;

    UIView *hostView = self.hostingView;
    if ( hostView ) {
        [self.detailItem renderInView:hostView withTheme:[self currentTheme] animated:YES];
    }
}

-(void)themeChanged:(nonnull NSNotification *)notification
{
    NSDictionary<NSString *, NSString *> *themeInfo = notification.userInfo;

    NSString *themeName = themeInfo[PlotGalleryThemeNameKey];
    if ( themeName ) {
        [self themeSelectedWithName:themeName];
    }
}

@end
