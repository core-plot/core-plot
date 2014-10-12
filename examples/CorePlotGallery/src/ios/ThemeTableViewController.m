//
//  ThemeTableViewController.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "CorePlot-CocoaTouch.h"
#import "ThemeTableViewController.h"

NSString *const kThemeTableViewControllerNoTheme      = @"None";
NSString *const kThemeTableViewControllerDefaultTheme = @"Default";

@interface ThemeTableViewController()

@property (nonatomic, readwrite, strong) NSMutableArray *themes;

@end

@implementation ThemeTableViewController

@synthesize themePopoverController;
@synthesize delegate;
@synthesize themes;

-(void)setupThemes
{
    self.themes = [[NSMutableArray alloc] init];

    [self.themes addObject:kThemeTableViewControllerDefaultTheme];
    [self.themes addObject:kThemeTableViewControllerNoTheme];

    for ( Class c in [CPTTheme themeClasses] ) {
        [self.themes addObject:[c name]];
    }
}

-(void)awakeFromNib
{
    [self setupThemes];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) ) {
        [self setupThemes];
    }

    return self;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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

// Customize the appearance of table view cells.
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
    [self.delegate themeSelectedAtIndex:self.themes[(NSUInteger)indexPath.row]];
}

#pragma mark -
#pragma mark Memory management

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    [self.tableView setDataSource:nil];
    [self.tableView setDelegate:nil];
}

@end
