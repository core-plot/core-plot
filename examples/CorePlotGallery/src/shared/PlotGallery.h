//
// PlotGallery.h
// CorePlotGallery
//

#import "PlotItem.h"

@interface PlotGallery : NSObject<NSCopying>

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) NSUInteger numberOfSections;
@property (nonatomic, readonly, strong, nonnull) CPTStringArray sectionTitles;

+(nonnull PlotGallery *)sharedPlotGallery;

-(void)addPlotItem:(nonnull PlotItem *)plotItem;

-(void)sortByTitle;

-(nonnull PlotItem *)objectInSection:(NSUInteger)section atIndex:(NSUInteger)index;
-(NSUInteger)numberOfRowsInSection:(NSUInteger)section;

@end
