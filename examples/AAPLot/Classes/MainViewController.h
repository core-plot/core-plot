
#import <UIKit/UIKit.h>
#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"

@class CPLayerHostingView;
@class APYahooDataPuller;
@class CPXYGraph;

@interface MainViewController : UIViewController <APYahooDataPullerDelegate, CPPlotDataSource> {
    CPLayerHostingView *layerHost;
    
	@private
    APYahooDataPuller *datapuller;
    CPXYGraph *graph;
}

@property (nonatomic, retain) IBOutlet CPLayerHostingView *layerHost;

@end