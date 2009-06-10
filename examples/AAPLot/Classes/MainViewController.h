//
//  MainViewController.h
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPYahooDataPuller.h"

@interface MainViewController : UIViewController <CPYahooDataPullerDelegate> {
    
@private;
    CPYahooDataPuller *datapuller;
}

@end
