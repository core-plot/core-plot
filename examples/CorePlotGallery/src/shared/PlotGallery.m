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

+ (PlotGallery *)sharedPlotGallery
{
    @synchronized(self) {
        if (sharedPlotGallery == nil) {
            sharedPlotGallery = [[self alloc] init];
        }
    }
    return sharedPlotGallery;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)	{
        if (sharedPlotGallery == nil) {
            return[super allocWithZone:zone];
        }
    }
    return sharedPlotGallery;
}

- (id)init
{
    Class thisClass = [self class];
    @synchronized(thisClass) {
        if (sharedPlotGallery == nil) {
            if (self = [super init]) {
                sharedPlotGallery = self;
                plotItems = [[NSMutableArray alloc] init];
            }
        }
    }

    return sharedPlotGallery;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

- (void)release
{
}

- (id)autorelease
{
    return self;
}

- (void)addPlotItem:(PlotItem *)plotItem
{
    [plotItems addObject:plotItem];
}

- (int)count
{
    return [plotItems count];
}

- (PlotItem *)objectAtIndex:(int)index
{
    return [plotItems objectAtIndex:index];
}

- (void)sortByTitle
{
    [plotItems sortUsingSelector:@selector(titleCompare:)];
}

@end
