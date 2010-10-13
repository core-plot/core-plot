
#import <UIKit/UIKit.h>
#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"

@class CPGraphHostingView;
@class APYahooDataPuller;
@class CPXYGraph;

@interface MainViewController : UIViewController <APYahooDataPullerDelegate, CPPlotDataSource> {
    CPGraphHostingView *graphHost;
    
	@private
    APYahooDataPuller *datapuller;
    CPXYGraph *graph;
}

@property (nonatomic, retain) IBOutlet CPGraphHostingView *graphHost;

@end