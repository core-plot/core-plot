//
//  TMMergeController.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMMergeController : NSWindowController {
    NSString *referencePath;
    NSString *outputPath;
    
    NSSet *outputGroups;
    
    NSManagedObjectContext *managedObjectContext;
}

@property (copy,readwrite) NSString * referencePath;
@property (copy,readwrite) NSString * outputPath;
@property (copy,readonly) NSSet *outputGroups;
@property (retain,readwrite) NSManagedObjectContext *managedObjectContext;
@property (retain,readonly) NSPredicate *groupFilterPredicate;

- (NSArray*)gtmUnitTestOutputPathsFromPath:(NSString*)path;
@end
