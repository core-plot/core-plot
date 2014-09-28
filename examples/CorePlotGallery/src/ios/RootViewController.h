//
//  RootViewController.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 8/28/10.
//  Copyright Jeff Buck 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController
{
    @private
    DetailViewController *detailViewController;
}

@property (nonatomic, strong) IBOutlet DetailViewController *detailViewController;

@end
