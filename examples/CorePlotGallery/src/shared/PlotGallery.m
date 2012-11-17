//
//  PlotGallery.m
//  CorePlotGallery
//
//  Created by Jeff Buck on 7/31/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import "PlotGallery.h"

@implementation PlotGallery

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

-(id)retain
{
    return self;
}

-(NSUInteger)retainCount
{
    return UINT_MAX;
}

-(oneway void)release
{
}

-(id)autorelease
{
    return self;
}

-(void)addPlotItem:(PlotItem *)plotItem
{
    [plotItems addObject:plotItem];

    NSString *sectionName = plotItem.section;
    if ( sectionName ) {
        [plotSections addObject:sectionName];
    }
}

-(NSUInteger)count
{
    return plotItems.count;
}

-(NSUInteger)numberOfSections
{
    return plotSections.count;
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [plotSections countForObject:[[self sectionTitles] objectAtIndex:section]];
}

-(PlotItem *)objectInSection:(NSInteger)section atIndex:(NSUInteger)index
{
    NSUInteger offset = 0;

    for ( NSUInteger i = 0; i < section; i++ ) {
        offset += [self numberOfRowsInSection:i];
    }

    return [plotItems objectAtIndex:offset + index];
}

-(void)sortByTitle
{
    [plotItems sortUsingSelector:@selector(titleCompare:)];
}

-(NSArray *)sectionTitles
{
    return [[plotSections allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
