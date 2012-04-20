//
//  PlotView.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/6/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol PlotViewDelegate<NSObject>

-(void)setFrameSize:(NSSize)newSize;

@end

@interface PlotView : NSView
{
    id<PlotViewDelegate> delegate;
}

@property (nonatomic, retain) id<PlotViewDelegate> delegate;

@end
