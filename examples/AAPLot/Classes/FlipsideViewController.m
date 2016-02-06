//
// FlipsideViewController.m
// AAPLot
//
// Created by Jonathan Saggau on 6/9/09.
// Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import "FlipsideViewController.h"

@implementation FlipsideViewController

-(void)viewDidLoad
{
    [super viewDidLoad];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ( [UIColor respondsToSelector:@selector(viewFlipsideBackgroundColor)] ) {
        self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    }
#pragma clang diagnostic pop
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
