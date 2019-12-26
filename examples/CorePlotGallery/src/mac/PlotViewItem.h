//
// PlotViewItem.h
// CorePlotGallery
//

#import <Cocoa/Cocoa.h>

@interface PlotViewItem : NSCollectionViewItem

@property (nonatomic, readwrite, strong) IBOutlet NSImageView *plotItemImage;
@property (nonatomic, readwrite, strong) IBOutlet NSTextField *plotItemTitle;

@end
