//
//  TestMerge_AppDelegate.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright Barry Wark 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
