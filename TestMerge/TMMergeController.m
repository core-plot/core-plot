//
//  TMMergeController.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMMergeController.h"
#import "TMOutputGroupCDFactory.h"
#import "TMOutputSorter.h"
#import "TMErrors.h"
#import "TMCompareController.h"
#import "TMImageCompareController.h"
#import "TMOutputGroup.h"

#import "GTMDefines.h"
#import "GTMGarbageCollection.h"
#import "GTMNSObject+KeyValueObserving.h"

NSString * const TMMergeControllerDidCommitMerge = @"TMMergeControllerDidCommitMerge";

@interface TMMergeController ()

@property (retain,readwrite) TMCompareController *currentCompareController;

- (void)commitMergeForGroups:(NSSet*)groups;
- (void)updateMergeViewForGroup:(id<TMOutputGroup>)newGroup;

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
@synthesize currentCompareController;
@synthesize groupSelectionIndexes;

- (void)dealloc {
    [referencePath release];
    [outputPath release];
    [managedObjectContext release];
    [groupsController release];
    [mergeViewContainer release];
    [compareControllersByExtension release];
    [currentCompareController release];
    
    [super dealloc];
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
    
    TMOutputGroupCDFactory *factory = [[TMOutputGroupCDFactory alloc] initWithManagedObjectContext:self.managedObjectContext];
    
    NSArray *referencePaths = [self gtmUnitTestOutputPathsFromPath:self.referencePath];
    NSArray *outputPaths = [self gtmUnitTestOutputPathsFromPath:self.outputPath];
    
    //quit if there's no new output
    //if(outputPaths.count == 0) [NSApp terminate:self];
    
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
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[NSApp delegate] managedObjectModel]];
    
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
    
    self.managedObjectContext = [[NSManagedObjectContext alloc] init];
    [self.managedObjectContext setPersistentStoreCoordinator:psc];
    
    _GTMDevLog(@"TMMergeController created moc: %@", self.managedObjectContext);
}

- (void)windowDidLoad {
    _GTMDevAssert([self groupsController] != nil, @"nil groups controller");
}

- (void)setGroupSelectionIndexes:(NSIndexSet*)newSelectionIndexes {
    if(newSelectionIndexes != self.groupSelectionIndexes) {
        [groupSelectionIndexes release];
        groupSelectionIndexes = newSelectionIndexes;
        
        _GTMDevAssert(self.groupSelectionIndexes.count <= 1, @"Multiple group selection");
        
        if(self.groupSelectionIndexes.count > 0) {
            [self updateMergeViewForGroup:[[[self groupsController] arrangedObjects] objectAtIndex:[[self groupSelectionIndexes] firstIndex]]];
        } else {
            [self updateMergeViewForGroup:nil];
        }
    }
}


- (void)updateMergeViewForGroup:(id<TMOutputGroup>)newGroup {
    NSViewController *controller = [[self compareControllersByExtension] objectForKey:newGroup.extension];
    
    self.currentCompareController = [[[controller class] alloc] initWithNibName:[controller nibName] bundle:[controller nibBundle]];
    
    (void)[self.currentCompareController view];

    [self.currentCompareController setRepresentedObject:newGroup];
    
    [self.mergeViewContainer setContentView:self.currentCompareController.view];
}

- (NSArray*)groupSortDescriptors {
    return [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
}

- (IBAction)commitMerge:(id)sender {
    _GTMDevLog(@"TMMergeController commiting merge for output groups: %@", self.outputGroups);
    
    [self commitMergeForGroups:self.outputGroups];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TMMergeControllerDidCommitMerge object:self];
}

- (void)commitMergeForGroups:(NSSet*)groups {
    NSError *err;
    
    for(id<TMOutputGroup>group in groups) {
        if(group.replaceReference == nil) continue; //skip groups with no user choice
        
        if(group.replaceReferenceValue) { // move output -> reference
            //delete reference if it exists
            if(group.referencePath != nil) {
                if(![[NSFileManager defaultManager] removeItemAtPath:group.referencePath
                                                               error:&err]) {
                    _GTMDevLog(@"Error removing old referencePath: %@", err);
                    [NSApp presentError:err]; // !!!:barry:20090603 TODO wrap error
                }
            }
            
            //move outputs
            NSString *newRefPath;
            if(group.referencePath != nil) {
                newRefPath = group.referencePath;
            } else {
                newRefPath = [[self.referencePath stringByAppendingPathComponent:group.name] stringByAppendingPathExtension:group.extension];
            }
            
            if(![[NSFileManager defaultManager] moveItemAtPath:group.outputPath
                                                        toPath:newRefPath
                                                         error:&err]) {
                _GTMDevLog(@"Error moving outputPath to referencePath: %@", err);
                [NSApp presentError:err]; // !!!:barry:20090603 TODO wrap error
            }
        } else { // keep reference, deleting output
            //delete output
            if(group.outputPath != nil) {
                if(![[NSFileManager defaultManager] removeItemAtPath:group.outputPath error:&err]) {
                    _GTMDevLog(@"Erorr deleting outputPath: %@", err);
                    [NSApp presentError:err]; // !!!:barry:20090603 TODO wrap error
                }
            }
        }
        
        // in either case, we delete the _Failed_Diff, if present
        if(group.failureDiffPath != nil) {
            if(![[NSFileManager defaultManager] removeItemAtPath:group.failureDiffPath error:&err]) {
                [NSApp presentError:err]; // !!!:barry:20090603 TODO wrap error
            }
        }
    }
}


- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem {
    if([anItem action] == @selector(selectReference:)) {
        return [[[self currentCompareController] representedObject] referencePath] != nil;
    }
    
    if([anItem action] == @selector(selectOutput:)) {
        return [[[self currentCompareController] representedObject] outputPath] != nil;
    }
    
    
    if([anItem action] == @selector(selectMergeNone:)) return YES;
    
    return NO;
}

- (IBAction)selectReference:(id)sender {
    _GTMDevLog(@"User selected reference");
    [self.currentCompareController setMergeChoice:ReferenceChoice];
}

- (IBAction)selectOutput:(id)sender {
    _GTMDevLog(@"User selected output");
    [self.currentCompareController setMergeChoice:OutputChoice];
}

- (IBAction)selectMergeNone:(id)sender {
    _GTMDevLog(@"User selected merge none");
    [self.currentCompareController setMergeChoice:NeitherChoice];
}

@end
