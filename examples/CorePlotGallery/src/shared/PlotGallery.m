//
//  PlotGallery.m
//  CorePlotGallery
//

#import "PlotGallery.h"

@interface PlotGallery()

@property (nonatomic, readwrite, strong) NSMutableArray *plotItems;
@property (nonatomic, readwrite, strong) NSCountedSet *plotSections;

@end

@implementation PlotGallery

@synthesize plotItems;
@synthesize plotSections;

static PlotGallery *sharedPlotGallery = nil;

+(PlotGallery *)sharedPlotGallery
{
    @synchronized(self)
    {
        if ( sharedPlotGallery == nil ) {
            sharedPlotGallery = [[self alloc] init];
        }
    }
    return sharedPlotGallery;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if ( sharedPlotGallery == nil ) {
            return [super allocWithZone:zone];
        }
    }
    return sharedPlotGallery;
}

-(id)init
{
    Class thisClass = [self class];

    @synchronized(thisClass)
    {
        if ( sharedPlotGallery == nil ) {
            if ( (self = [super init]) ) {
                sharedPlotGallery = self;
                plotItems         = [[NSMutableArray alloc] init];
                plotSections      = [[NSCountedSet alloc] init];
            }
        }
    }

    return sharedPlotGallery;
}

-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(void)addPlotItem:(PlotItem *)plotItem
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

-(PlotItem *)objectInSection:(NSUInteger)section atIndex:(NSUInteger)index
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

-(NSArray *)sectionTitles
{
    return [[self.plotSections allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
