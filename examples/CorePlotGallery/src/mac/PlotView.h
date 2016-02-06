//
// PlotView.h
// CorePlotGallery
//

#import <Cocoa/Cocoa.h>

@protocol PlotViewDelegate<NSObject>

-(void)setFrameSize:(NSSize)newSize;

@end

@interface PlotView : NSView<PlotViewDelegate>
@property (nonatomic, weak) id<PlotViewDelegate> delegate;

@end
