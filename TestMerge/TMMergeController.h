//
//  TMMergeController.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMOutputGroup.h"

@interface TMMergeController : NSWindowController {
    NSString *referencePath;
    NSString *outputPath;
    
    NSSet *outputGroups;
    
    NSManagedObjectContext *managedObjectContext;
    
    IBOutlet NSArrayController *groupsController;
    
    IBOutlet NSBox *mergeViewContainer;
    
    NSDictionary *compareControllersByExtension;

}

@property (copy,readwrite) NSString * referencePath;
@property (copy,readwrite) NSString * outputPath;
@property (copy,readonly) NSSet *outputGroups;
@property (retain,readwrite) NSManagedObjectContext *managedObjectContext;
@property (retain,readonly) NSPredicate *groupFilterPredicate;
@property (retain,readwrite) IBOutlet NSBox *mergeViewContainer;
@property (readonly) NSArray *groupSortDescriptors;
@property (retain,readwrite) NSDictionary *compareControllersByExtension;

@property (retain,readwrite) IBOutlet NSArrayController *groupsController;

- (NSArray*)gtmUnitTestOutputPathsFromPath:(NSString*)path;
@end
