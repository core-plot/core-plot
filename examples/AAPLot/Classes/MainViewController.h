
#import <UIKit/UIKit.h>
#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"

@class CPLayerHostingView;
@class APYahooDataPuller;
@class CPXYGraph;

@interface MainViewController : UIViewController <APYahooDataPullerDelegate, CPPlotDataSource> {
    CPLayerHostingView *layerHost;
//    UILabel *bottomLabel;
//    UILabel *topLabel;
    
	@private
    APYahooDataPuller *datapuller;
    CPXYGraph *graph;
}

@property (nonatomic, retain) IBOutlet CPLayerHostingView *layerHost;
//@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;
//@property (nonatomic, retain) IBOutlet UILabel *topLabel;

@end