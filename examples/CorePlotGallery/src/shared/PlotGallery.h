//
//  PlotGallery.h
//  CorePlotGallery
//

#import "PlotItem.h"

@interface PlotGallery : NSObject

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly, strong) CPTStringArray sectionTitles;

+(PlotGallery *)sharedPlotGallery;

-(void)addPlotItem:(PlotItem *)plotItem;

-(void)sortByTitle;

-(PlotItem *)objectInSection:(NSUInteger)section atIndex:(NSUInteger)index;
-(NSUInteger)numberOfRowsInSection:(NSUInteger)section;

@end
