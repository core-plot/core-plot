//
//  RootViewController.h
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class FlipsideViewController;

@interface RootViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *infoButton;
@property (nonatomic, strong) MainViewController *mainViewController;
@property (nonatomic, strong) UINavigationBar *flipsideNavigationBar;
@property (nonatomic, strong) FlipsideViewController *flipsideViewController;

-(IBAction)toggleView;

@end
