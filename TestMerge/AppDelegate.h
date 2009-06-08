//
//  TestMerge_AppDelegate.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright Barry Wark 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TMMergeController;

@interface AppDelegate : NSObject 
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    
    TMMergeController *mergeController;
}

@property (retain,readonly) TMMergeController * mergeController;

@end
