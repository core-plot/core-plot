#import "APYahooDataPuller.h"
#import "CorePlot-CocoaTouch.h"
#import <UIKit/UIKit.h>

@class CPTGraphHostingView;
@class APYahooDataPuller;
@class CPTXYGraph;

@interface MainViewController : UIViewController<APYahooDataPullerDelegate, CPTPlotDataSource>

@property (nonatomic, readwrite, strong, nullable) IBOutlet CPTGraphHostingView *graphHost;

@end
