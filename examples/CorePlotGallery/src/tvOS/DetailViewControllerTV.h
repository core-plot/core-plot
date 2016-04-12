//
// DetailViewControllerTV.h
// CorePlotGallery
//

@class PlotItem;

@interface DetailViewControllerTV : UIViewController

@property (nonatomic, strong) PlotItem *detailItem;
@property (nonatomic, copy) NSString *currentThemeName;

@property (nonatomic, strong) IBOutlet UIView *hostingView;

-(void)themeSelectedWithName:(NSString *)themeName;

@end
