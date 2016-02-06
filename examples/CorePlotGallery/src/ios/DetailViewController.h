//
// DetailViewController.h
// CorePlotGallery
//

@class PlotItem;

@interface DetailViewController : UIViewController

@property (nonatomic, strong) PlotItem *detailItem;
@property (nonatomic, copy) NSString *currentThemeName;

@property (nonatomic, strong) IBOutlet UIView *hostingView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *themeBarButton;

-(void)themeSelectedWithName:(NSString *)themeName;

@end
