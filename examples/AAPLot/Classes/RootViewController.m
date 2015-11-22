//
//  RootViewController.m
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import "FlipsideViewController.h"
#import "MainViewController.h"
#import "RootViewController.h"

@implementation RootViewController

@synthesize infoButton;
@synthesize flipsideNavigationBar;
@synthesize mainViewController;
@synthesize flipsideViewController;

-(void)viewDidLoad
{
    [super viewDidLoad];
    MainViewController *viewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
    self.mainViewController = viewController;

    [self.view insertSubview:self.mainViewController.view belowSubview:self.infoButton];
    self.mainViewController.view.frame = self.view.bounds;
}

-(void)loadFlipsideViewController
{
    FlipsideViewController *viewController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];

    self.flipsideViewController = viewController;

    self.flipsideViewController.view.frame = self.view.bounds;

    // Set up the navigation bar
    UINavigationBar *aNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    aNavigationBar.barStyle    = UIBarStyleBlackOpaque;
    self.flipsideNavigationBar = aNavigationBar;

    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(toggleView)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"AAPLot"];
    navigationItem.rightBarButtonItem = buttonItem;
    [self.flipsideNavigationBar pushNavigationItem:navigationItem animated:NO];
}

-(IBAction)toggleView
{
    /*
     * This method is called when the info or Done button is pressed.
     * It flips the displayed view from the main view to the flipside view and vice-versa.
     */
    if ( self.flipsideViewController == nil ) {
        [self loadFlipsideViewController];
    }

    UIView *mainView     = self.mainViewController.view;
    UIView *flipsideView = self.flipsideViewController.view;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    UIViewAnimationTransition transition = (mainView.superview ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft);
    [UIView setAnimationTransition:transition forView:self.view cache:YES];

    if ( mainView.superview != nil ) {
        [self.flipsideViewController viewWillAppear:YES];
        [self.mainViewController viewWillDisappear:YES];
        [mainView removeFromSuperview];
        [self.infoButton removeFromSuperview];
        [self.view addSubview:flipsideView];
        [self.view insertSubview:self.flipsideNavigationBar aboveSubview:flipsideView];
        [self.mainViewController viewDidDisappear:YES];
        [self.flipsideViewController viewDidAppear:YES];
    }
    else {
        [self.mainViewController viewWillAppear:YES];
        [self.flipsideViewController viewWillDisappear:YES];
        [flipsideView removeFromSuperview];
        [self.flipsideNavigationBar removeFromSuperview];
        [self.view addSubview:mainView];
        [self.view insertSubview:self.infoButton aboveSubview:self.mainViewController.view];
        [self.flipsideViewController viewDidDisappear:YES];
        [self.mainViewController viewDidAppear:YES];
    }
    [UIView commitAnimations];
}

/*
 * // Override to allow orientations other than the default portrait orientation.
 * - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 *  // Return YES for supported orientations
 *  return (interfaceOrientation == UIInterfaceOrientationPortrait);
 * }
 */

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

@end
