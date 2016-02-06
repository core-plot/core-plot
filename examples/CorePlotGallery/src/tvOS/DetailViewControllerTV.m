//
// DetailViewControllerTV
// CorePlotGallery
//

#import "DetailViewControllerTV.h"

#import "PlotItem.h"
#import "ThemeTableViewControllerTV.h"

@interface DetailViewControllerTV()

-(CPTTheme *)currentTheme;

-(void)setupView;
-(void)themeChanged:(NSNotification *)notification;

@end

#pragma mark -

@implementation DetailViewControllerTV

@synthesize detailItem;
@synthesize hostingView;
@synthesize currentThemeName;

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

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    NSDictionary<NSString *, NSString *> *themeInfo = notification.userInfo;

    [self themeSelectedWithName:themeInfo[PlotGalleryThemeNameKey]];
}

@end
