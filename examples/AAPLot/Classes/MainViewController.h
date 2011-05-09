
#import <UIKit/UIKit.h>
#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"

@class CPTGraphHostingView;
@class APYahooDataPuller;
@class CPTXYGraph;

@interface MainViewController : UIViewController <APYahooDataPullerDelegate, CPTPlotDataSource> {
    CPTGraphHostingView *graphHost;
    
	@private
    APYahooDataPuller *datapuller;
    CPTXYGraph *graph;
}

@property (nonatomic, retain) IBOutlet CPTGraphHostingView *graphHost;

@end