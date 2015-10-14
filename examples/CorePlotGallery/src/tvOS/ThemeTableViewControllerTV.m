//
//  ThemeTableViewControllerTV.m
//  CorePlotGallery
//

#import "ThemeTableViewControllerTV.h"

#import <CorePlot/CorePlot.h>

NSString *const kThemeTableViewControllerNoTheme      = @"None";
NSString *const kThemeTableViewControllerDefaultTheme = @"Default";

NSString *const PlotGalleryThemeDidChangeNotification = @"PlotGalleryThemeDidChangeNotification";
NSString *const PlotGalleryThemeNameKey               = @"PlotGalleryThemeNameKey";

@interface ThemeTableViewControllerTV()

@property (nonatomic, readwrite, strong) CPTMutableStringArray themes;

@end

#pragma mark -

@implementation ThemeTableViewControllerTV

@synthesize themes;

-(void)setupThemes
{
    CPTMutableStringArray themeList = [[NSMutableArray alloc] init];

    [themeList addObject:kThemeTableViewControllerDefaultTheme];
    [themeList addObject:kThemeTableViewControllerNoTheme];

    for ( Class themeClass in [CPTTheme themeClasses] ) {
        [themeList addObject:[themeClass name]];
    }

    self.themes = themeList;
}

-(void)awakeFromNib
{
    [self setupThemes];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
        [self setupThemes];
    }

    return self;
}

#pragma mark -
#pragma mark Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.themes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
