//
// PlotGallery.m
// CorePlotGallery
//

#import "PlotGallery.h"
#import <objc/runtime.h>

@interface PlotGallery()

@property (nonatomic, readwrite, strong) NSMutableArray<PlotItem *> *plotItems;
@property (nonatomic, readwrite, strong) NSCountedSet *plotSections;

NSArray<Class> *ClassGetSubclasses(Class parentClass);

-(void)addPlotItem:(nonnull PlotItem *)plotItem;

@end

#pragma mark -

@implementation PlotGallery

@synthesize plotItems;
@synthesize plotSections;

// Code from https://stackoverflow.com/questions/7923586/objective-c-get-list-of-subclasses-from-superclass/23038932
NSArray<Class> *ClassGetSubclasses(Class parentClass)
{
    int numClasses = objc_getClassList(NULL, 0);

    // According to the docs of objc_getClassList we should check
    // if numClasses is bigger than 0.
    if ( numClasses <= 0 ) {
        return [NSArray array];
    }

    size_t memSize = sizeof(Class) * (size_t)numClasses;
    Class *classes = (__unsafe_unretained Class *)malloc(memSize);

    if ( !classes && memSize ) {
        return [NSArray array];
    }

    numClasses = objc_getClassList(classes, numClasses);

    NSMutableArray<Class> *result = [NSMutableArray new];

    for ( NSInteger i = 0; i < numClasses; i++ ) {
        Class superClass = classes[i];

        // Don't add the parent class to list of sublcasses
        if ( superClass == parentClass ) {
            continue;
        }

        // Using a do while loop, like pointed out in Cocoa with Love,
        // can lead to EXC_I386_GPFLT, which stands for General
        // Protection Fault and means we are doing something we
        // shouldn't do. It's safer to use a regular while loop to
        // check if superClass is valid.
        while ( superClass && superClass != parentClass ) {
            superClass = class_getSuperclass(superClass);
        }

        if ( superClass ) {
            [result addObject:classes[i]];
        }
    }

    free(classes);

    return result;
}

static PlotGallery *sharedPlotGallery = nil;

+(nonnull PlotGallery *)sharedPlotGallery
{
    @synchronized ( self ) {
        if ( !sharedPlotGallery ) {
            sharedPlotGallery = [[self alloc] init];
        }
    }
    return sharedPlotGallery;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized ( self ) {
        if ( !sharedPlotGallery ) {
            return [super allocWithZone:zone];
        }
    }
    return sharedPlotGallery;
}

-(nonnull instancetype)init
{
    Class thisClass = [self class];

    @synchronized ( thisClass ) {
        if ( !sharedPlotGallery ) {
            if ((self = [super init])) {
                sharedPlotGallery = self;
                plotItems         = [[NSMutableArray alloc] init];
                plotSections      = [[NSCountedSet alloc] init];

                for ( Class itemClass in ClassGetSubclasses([PlotItem class])) {
                    PlotItem *plotItem = [[itemClass alloc] init];

                    if ( plotItem ) {
                        [self addPlotItem:plotItem];
                    }
                }
            }
        }
    }

    return sharedPlotGallery;
}

-(nonnull id)copyWithZone:(nullable NSZone *__unused)zone
{
    return self;
}

-(void)addPlotItem:(nonnull PlotItem *)plotItem
{
    NSLog(@"addPlotItem for class %@", [plotItem class]);

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
