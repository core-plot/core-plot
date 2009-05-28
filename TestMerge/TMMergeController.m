//
//  TMMergeController.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMMergeController.h"
#import "TMOutputGroupCDFactory.h"
#import "TMOutputSorter.h"
#import "TMErrors.h"
#import "TMCompareController.h"

#import "GTMDefines.h"
#import "GTMGarbageCollection.h"
#import "GTMNSObject+KeyValueObserving.h"


@interface TMMergeController ()

- (void)observeSelectedGroupsDidChange:(GTMKeyValueChangeNotification*)notification;

@end

@implementation TMMergeController
@synthesize referencePath;
@synthesize outputPath;
@dynamic outputGroups;
@dynamic groupFilterPredicate;
@dynamic groupSortDescriptors;
@synthesize managedObjectContext;
@synthesize groupsController;
@synthesize mergeViewContainer;
@synthesize compareControllersByExtension;

- (void)dealloc {
    [referencePath release];
    [outputPath release];
    [managedObjectContext release];
    [groupsController release];
    [mergeViewContainer release];
    [compareControllersByExtension release];
    
    [[self groupsController] gtm_removeObserver:self forKeyPath:@"selectedGroup" selector:@selector(observeSelectedGroupDidChange:)];
    
    [super dealloc];
}

- (void)finalize {
    [[self groupsController] gtm_removeObserver:self forKeyPath:@"selectedGroup" selector:@selector(observeSelectedGroupDidChange:)];
    
    [super finalize];
}

+ (void)initialize {
    if(self == [TMMergeController class]) {
        [self exposeBinding:@"outputGroups"];
        [self exposeBinding:@"referencePath"];
        [self exposeBinding:@"outputPath"];
    }
}

+ (NSSet*)keyPathsForValuesAffectingOutputGroups {
    return [NSSet setWithObjects:@"referencePath",
            @"outputPath",
            @"managedObjectContext",
            nil
            ];
}

- (NSSet*)outputGroups {
    
    TMOutputGroupCDFactory *factory = [[[TMOutputGroupCDFactory alloc] initWithManagedObjectContext:self.managedObjectContext] autorelease];
    
    NSArray *referencePaths = [self gtmUnitTestOutputPathsFromPath:self.referencePath];
    NSArray *outputPaths = [self gtmUnitTestOutputPathsFromPath:self.outputPath];
    
    TMOutputSorter *sorter = [[[TMOutputSorter alloc] initWithReferencePaths:referencePaths
                                                                 outputPaths:outputPaths]
                              autorelease];
    
    NSError *err;
    NSSet *result = [sorter sortedOutputWithGroupFactory:factory error:&err];
    if(result == nil) {
        [self presentError:err];
    }
    
    return result;
}

- (NSArray*)gtmUnitTestOutputPathsFromPath:(NSString*)path {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:contents.count];
    
    // We can't get this information from GTMNSObject+UnitTesting b/c it is SenTestKit dependent, so we have to recreate gtm_imageUTI/gtm_imageExtension/gtm_stateExtension
    
    CFStringRef imageUTI;
#if GTM_IPHONE_SDK
    imageUTI = kUTTypePNG;
#else
    // Currently can't use PNG on Leopard. (10.5.2)
    // Radar:5844618 PNG importer/exporter in ImageIO is lossy
    imageUTI = kUTTypeTIFF;
#endif
    
    NSString *imageExtension;
    
#if GTM_IPHONE_SDK
    if (CFEqual(imageU, kUTTypePNG)) {
        imageExtension = @"png";
    } else if (CFEqual(imageUTI, kUTTypeJPEG)) {
        imageExtension = @"jpg";
    } else {
        _GTMDevAssert(NO, @"Illegal UTI for iPhone");
    }
    
#else
    imageExtension 
    = (NSString*)UTTypeCopyPreferredTagWithClass(imageUTI, kUTTagClassFilenameExtension);
    _GTMDevAssert(imageExtension, @"No extension for uti: %@", imageUTI);
    
    GTMCFAutorelease(imageExtension);
#endif
    
    NSString *stateExtension = @"gtmUTState";
    
    // Filter contents paths for image and state extensions
    for(id filePath in contents) {
        if([filePath hasSuffix:imageExtension] ||
           [filePath hasSuffix:stateExtension]) {
            [result addObject:[path stringByAppendingPathComponent:filePath]];
        }
    }
    
    return result;
    
}

- (NSPredicate*)groupFilterPredicate {
    return [NSPredicate predicateWithFormat:@"outputPath != nil"];
}

- (void)windowWillLoad {
    NSPersistentStoreCoordinator *psc = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSApp delegate] managedObjectModel]] autorelease];
    
    NSError *err;
    if(![psc addPersistentStoreWithType:NSInMemoryStoreType
                          configuration:nil
                                    URL:nil
                                options:nil
                                  error:&err]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  err, NSUnderlyingErrorKey,
                                  NSLocalizedString(@"Unable to create an in-memory store for output groups", @"Unable to create an in-memory store for output groups"), NSLocalizedDescriptionKey,
                                  nil
                                  ];
        
        err = [NSError errorWithDomain:TMErrorDomain
                                  code:TMCoreDataError
                              userInfo:userInfo];
        
        [NSApp presentError:err];
    }
    
    self.managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
    [self.managedObjectContext setPersistentStoreCoordinator:psc];
    
    _GTMDevLog(@"TMMergeController created moc: %@", self.managedObjectContext);
}

- (void)windowDidLoad {
    _GTMDevAssert([self groupsController] != nil, @"nil groups controller");
    [[self groupsController] gtm_addObserver:self
                                  forKeyPath:@"selectedObjects"
                                    selector:@selector(observeSelectedGroupsDidChange:)
                                    userInfo:nil
                                     options:NSKeyValueObservingOptionNew];
}

- (void)observeSelectedGroupsDidChange:(GTMKeyValueChangeNotification*)notification {
    _GTMDevAssert([[[notification change] objectForKey:NSKeyValueChangeKindKey] integerValue] == NSKeyValueChangeSetting, @"");
    
    _GTMDevAssert([[[self groupsController] selectedObjects] count] <= 1, @"too many selected objects");
    
    id<TMOutputGroup> newGroup = [[[self groupsController] selectedObjects] lastObject];
    
    TMCompareController *controller = [[self compareControllersByExtension] objectForKey:newGroup.extension];
    
//    if(controller == nil) {
//        [NSException raise:NSInternalInconsistencyException format:@"Unexpected group extension (%@)", newGroup.extension];
//    }
    
    [controller setRepresentedObject:newGroup];
    
    [self.mergeViewContainer setContentView:controller.view];
}

- (NSArray*)groupSortDescriptors {
    return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]];
}
@end
