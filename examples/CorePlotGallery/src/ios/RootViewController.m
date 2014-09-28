//
//  RootViewController.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"

#import "PlotGallery.h"
#import "PlotItem.h"

@implementation RootViewController

@synthesize detailViewController;

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;

    if ( [self respondsToSelector:@selector(setPreferredContentSize:)] ) {
        self.preferredContentSize = self.view.bounds.size;
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.contentSizeForViewInPopover = self.view.bounds.size;
#pragma clang diagnostic pop
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    return [[PlotGallery sharedPlotGallery] numberOfSections];
}

-(NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [[PlotGallery sharedPlotGallery] numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"PlotCell";

    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellId];

    if ( cell == nil ) {
        cell               = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    PlotItem *plotItem = [[PlotGallery sharedPlotGallery] objectInSection:indexPath.section atIndex:indexPath.row];
    cell.imageView.image = [plotItem image];
    cell.textLabel.text  = plotItem.title;

    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[PlotGallery sharedPlotGallery] sectionTitles][section];
}

#pragma mark -
#pragma mark Table view delegate

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlotItem *plotItem = [[PlotGallery sharedPlotGallery] objectInSection:indexPath.section atIndex:indexPath.row];

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        detailViewController.detailItem = plotItem;
    }
    else {
        detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        [self.navigationController pushViewController:detailViewController animated:YES];
        detailViewController.view.frame = self.view.bounds;
        detailViewController.detailItem = plotItem;
        detailViewController            = nil;
    }
}

#pragma mark -
#pragma mark Memory management

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidUnload
{
    detailViewController = nil;

    [super viewDidUnload];
}

@end
