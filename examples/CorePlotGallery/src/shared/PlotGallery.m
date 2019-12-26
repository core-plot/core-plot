//
// PlotGallery.m
// CorePlotGallery
//

#import "PlotGallery.h"

@interface PlotGallery()

@property (nonatomic, readwrite, strong) NSMutableArray<PlotItem *> *plotItems;
@property (nonatomic, readwrite, strong) NSCountedSet *plotSections;

@end

#pragma mark -

@implementation PlotGallery

@synthesize plotItems;
@synthesize plotSections;

static PlotGallery *sharedPlotGallery = nil;

+(nonnull PlotGallery *)sharedPlotGallery
{
    @synchronized ( self ) {
        if ( sharedPlotGallery == nil ) {
            sharedPlotGallery = [[self alloc] init];
        }
    }
    return sharedPlotGallery;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized ( self ) {
        if ( sharedPlotGallery == nil ) {
            return [super allocWithZone:zone];
        }
    }
    return sharedPlotGallery;
}

-(nonnull instancetype)init
{
    Class thisClass = [self class];

    @synchronized ( thisClass ) {
        if ( sharedPlotGallery == nil ) {
            if ((self = [super init])) {
                sharedPlotGallery = self;
                plotItems         = [[NSMutableArray alloc] init];
                plotSections      = [[NSCountedSet alloc] init];
            }
        }
    }

    return sharedPlotGallery;
}

-(nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return self;
}

-(void)addPlotItem:(nonnull PlotItem *)plotItem
{
    [self.plotItems addObject:plotItem];

    NSString *sectionName = plotItem.section;
    if ( sectionName ) {
        [self.plotSections addObject:sectionName];
    }
}

-(NSUInteger)count
{
    return self.plotItems.count;
}

-(NSUInteger)numberOfSections
{
    return self.plotSections.count;
}

-(NSUInteger)numberOfRowsInSection:(NSUInteger)section
{
    return [self.plotSections countForObject:self.sectionTitles[section]];
}

-(nonnull PlotItem *)objectInSection:(NSUInteger)section atIndex:(NSUInteger)index
{
    NSUInteger offset = 0;

    for ( NSUInteger i = 0; i < section; i++ ) {
        offset += [self numberOfRowsInSection:i];
    }

    return self.plotItems[offset + index];
}

-(void)sortByTitle
{
    [self.plotItems sortUsingSelector:@selector(titleCompare:)];
}

-(CPTStringArray *)sectionTitles
{
    return [self.plotSections.allObjects sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
