//
//  MainViewController.h
//  AAPLot
//
//  Created by Jonathan Saggau on 6/9/09.
//  Copyright Sounds Broken inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"

@interface MainViewController : UIViewController <CPYahooDataPullerDelegate, CPPlotDataSource> {
    CPLayerHostingView *layerHost;
@private;
    CPYahooDataPuller *datapuller;
    CPXYGraph *graph;
}

@property(nonatomic, retain)IBOutlet CPLayerHostingView *layerHost;

@end