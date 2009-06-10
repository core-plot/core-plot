//
//  MainViewController.m
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "CPYahooDataPuller.h"

@interface MainViewController (PrivateAPI)

- (CPYahooDataPuller *)datapuller;
- (void)setDatapuller:(CPYahooDataPuller *)aDatapuller;

@end


@implementation MainViewController

- (void)dealloc
{
    [datapuller release];
    
    datapuller = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        CPYahooDataPuller *dp = [[CPYahooDataPuller alloc] init];
        [dp setDelegate:self];
        [self setDatapuller:dp];
        [dp release];
    }
    return self;
}

-(void)dataPullerDidFinishFetch:(CPYahooDataPuller *)dp;
{
    NSLog(@"Fetch is done!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (CPYahooDataPuller *)datapuller
{
    //NSLog(@"in -datapuller, returned datapuller = %@", datapuller);
    
    return datapuller; 
}
- (void)setDatapuller:(CPYahooDataPuller *)aDatapuller
{
    //NSLog(@"in -setDatapuller:, old value of datapuller: %@, changed to: %@", datapuller, aDatapuller);
    
    if (datapuller != aDatapuller)
    {
        [aDatapuller retain];
        [datapuller release];
        datapuller = aDatapuller;
    }
}

@end




/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

