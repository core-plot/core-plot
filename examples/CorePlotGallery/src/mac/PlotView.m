//
//  PlotView.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/6/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotView.h"


@implementation PlotView

@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
    }

    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
}

- (void)setFrameSize:(NSSize)newSize
{
    [super setFrameSize:newSize];
	
    if (delegate && [delegate respondsToSelector:@selector(setFrameSize:)])
        [delegate setFrameSize:newSize];
}

@end
