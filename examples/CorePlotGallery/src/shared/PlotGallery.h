//
//  PlotGallery.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface PlotGallery : NSObject
{
    NSMutableArray *plotItems;
}

+ (PlotGallery *)sharedPlotGallery;

- (void)addPlotItem:(PlotItem *)plotItem;

- (void)sortByTitle;
- (int)count;
- (PlotItem *)objectAtIndex:(int)index;

@end
