//
//  PlotGallery.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotItem.h"

@interface PlotGallery : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly, strong) NSArray *sectionTitles;

+(PlotGallery *)sharedPlotGallery;

-(void)addPlotItem:(PlotItem *)plotItem;

-(void)sortByTitle;

-(PlotItem *)objectInSection:(NSUInteger)section atIndex:(NSUInteger)index;
-(NSUInteger)numberOfRowsInSection:(NSUInteger)section;

@end
