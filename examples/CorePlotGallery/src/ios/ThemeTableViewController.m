//
// ThemeTableViewController.m
// CorePlotGallery
//

#import "ThemeTableViewController.h"

#import <CorePlot/CorePlot.h>

NSString *const kThemeTableViewControllerNoTheme      = @"None";
NSString *const kThemeTableViewControllerDefaultTheme = @"Default";

NSString *const PlotGalleryThemeDidChangeNotification = @"PlotGalleryThemeDidChangeNotification";
NSString *const PlotGalleryThemeNameKey               = @"PlotGalleryThemeNameKey";

@interface ThemeTableViewController()

@property (nonatomic, readwrite, strong, nonnull) CPTMutableStringArray *themes;

@end

#pragma mark -

@implementation ThemeTableViewController

@synthesize themes;

-(void)setupThemes
{
    CPTMutableStringArray *themeList = [[NSMutableArray alloc] init];

    [themeList addObject:kThemeTableViewControllerDefaultTheme];
    [themeList addObject:kThemeTableViewControllerNoTheme];

    for ( Class themeClass in [CPTTheme themeClasses] ) {
        [themeList addObject:[themeClass name]];
    }

    self.themes = themeList;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    [self setupThemes];
}

-(nonnull instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
        [self setupThemes];
    }

    return self;
}

#pragma mark -
#pragma mark Table view data source

-(NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.themes.count;
}

-(nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ThemeCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.textLabel.text = self.themes[(NSUInteger)indexPath.row];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

-(void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSDictionary<NSString *, NSString *> *themeInfo = @{
                                                          PlotGalleryThemeNameKey: self.themes[(NSUInteger)indexPath.row]
    };

    [[NSNotificationCenter defaultCenter] postNotificationName:PlotGalleryThemeDidChangeNotification
                                                        object:self
                                                      userInfo:themeInfo];

    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
