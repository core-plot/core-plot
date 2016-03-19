//
// PlotView.h
// CorePlotGallery
//

#import <Cocoa/Cocoa.h>

@protocol PlotViewDelegate<NSObject>

-(void)setFrameSize:(NSSize)newSize;

@end

@interface PlotView : NSView
@property (nonatomic, weak, nullable) id<PlotViewDelegate> delegate;

@end
