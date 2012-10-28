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
    self.contentSizeForViewInPopover     = self.view.bounds.size;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    return [[PlotGallery sharedPlotGallery] count];
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"PlotCell";

    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellId];

    if ( cell == nil ) {
        cell               = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    PlotItem *plotItem = [[PlotGallery sharedPlotGallery] objectAtIndex:indexPath.row];
    cell.imageView.image = [plotItem image];
    cell.textLabel.text  = plotItem.title;

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

-(void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlotItem *plotItem = [[PlotGallery sharedPlotGallery] objectAtIndex:indexPath.row];

    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
        detailViewController.detailItem = plotItem;
    }
    else {
        detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
        [self.navigationController pushViewController:detailViewController animated:YES];
        detailViewController.view.frame = self.view.bounds;
        detailViewController.detailItem = plotItem;
        [detailViewController release];
        detailViewController = nil;
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
}

-(void)dealloc
{
    [detailViewController release];
    detailViewController = nil;
    [super dealloc];
}

@end
