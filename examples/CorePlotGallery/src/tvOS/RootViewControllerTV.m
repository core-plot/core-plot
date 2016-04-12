//
// RootViewControllerTV.m
// CorePlotGallery
//

#import "RootViewControllerTV.h"

#import "DetailViewControllerTV.h"
#import "ThemeTableViewControllerTV.h"

#import "PlotGallery.h"
#import "PlotItem.h"

@interface RootViewControllerTV()

@property (nonatomic, copy) NSString *currentThemeName;

-(void)themeChanged:(NSNotification *)notification;

@end

#pragma mark -

@implementation RootViewControllerTV

@synthesize themeBarButton;
@synthesize currentThemeName;

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = NO;

    self.currentThemeName = kThemeTableViewControllerDefaultTheme;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChanged:)
                                                 name:PlotGalleryThemeDidChangeNotification
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"showDetail"] ) {
        DetailViewControllerTV *controller = (DetailViewControllerTV *)segue.destinationViewController;

        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;

        controller.currentThemeName = self.currentThemeName;

        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;

        PlotItem *plotItem = [[PlotGallery sharedPlotGallery] objectInSection:[indexPath indexAtPosition:0]
                                                                      atIndex:[indexPath indexAtPosition:1]];

        controller.detailItem = plotItem;
    }
}

#pragma mark -
#pragma mark Theme Selection

-(void)setCurrentThemeName:(NSString *)newThemeName
{
    if ( newThemeName != currentThemeName ) {
        currentThemeName = [newThemeName copy];

        self.themeBarButton.title = newThemeName;
    }
}

-(void)themeChanged:(NSNotification *)notification
{
    NSDictionary<NSString *, NSString *> *themeInfo = notification.userInfo;

    self.currentThemeName = themeInfo[PlotGalleryThemeNameKey];
}

#pragma mark -
#pragma mark Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    return (NSInteger)[PlotGallery sharedPlotGallery].numberOfSections;
}

-(NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[[PlotGallery sharedPlotGallery] numberOfRowsInSection:(NSUInteger)section];
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"PlotCell";

    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellId];

    if ( cell == nil ) {
        cell               = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    PlotItem *plotItem = [[PlotGallery sharedPlotGallery] objectInSection:[indexPath indexAtPosition:0]
                                                                  atIndex:[indexPath indexAtPosition:1]];
    cell.imageView.image = [plotItem image];
    cell.textLabel.text  = plotItem.title;

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [PlotGallery sharedPlotGallery].sectionTitles[(NSUInteger)section];
}

@end
