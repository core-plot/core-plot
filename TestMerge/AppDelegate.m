//
//  TestMerge_AppDelegate.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright Barry Wark 2009 . All rights reserved.
//

#import "AppDelegate.h"
#import "TMMergeController.h"
#import "TMImageCompareController.h"
#import "TMUTStateCompareController.h"
#import "TMOutputSorter.h"

#import "GTMLogger.h"
#import "GTMLogger+ASL.h"


@interface AppDelegate ()

@property (retain,readwrite) TMMergeController * mergeController;

@end

@implementation AppDelegate
@synthesize mergeController;

/**
 Implementation of dealloc, to release the retained variables.
 */

- (void) dealloc {
    [mergeController release];
    
    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    [GTMLogger setSharedLogger:[GTMLogger standardLoggerWithASL]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.mergeController = [[TMMergeController alloc] initWithWindowNibName:@"MergeUI"];
    
    self.mergeController.compareControllersByExtension = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [[TMImageCompareController alloc] initWithNibName:@"ImageCompareView" bundle:[NSBundle mainBundle]],
                                                          TMGTMUnitTestImageExtension,
                                                          [[TMUTStateCompareController alloc] initWithNibName:@"UTStateCompareView" bundle:[NSBundle mainBundle]],
                                                          TMGTMUnitTestStateExtension,
                                                          nil];
    
    self.mergeController.referencePath = [[[[NSProcessInfo processInfo] environment] objectForKey:@"TM_REFERENCE_PATH"] stringByExpandingTildeInPath];
    self.mergeController.outputPath = [[[[NSProcessInfo processInfo] environment] objectForKey:@"TM_OUTPUT_PATH"] stringByExpandingTildeInPath];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mergeControllerDidCommitMerge:)
                                                 name:TMMergeControllerDidCommitMerge
                                               object:self.mergeController];
    
    [[[self mergeController] window] center];
    [[self mergeController] showWindow:self];
}

- (void)mergeControllerDidCommitMerge:(NSNotification*)notification {
    //pass
}

/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This co
 de uses a folder named "TestMerge" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"TestMerge"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"TestMerge.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
                                                  configuration:nil
                                                            URL:nil
                                                        options:nil
                                                          error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    
    
    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    
    // if the user has selected a merge direction for any output groups, prompt to commit the merge
    NSSet *groups = self.mergeController.outputGroups;
    if([[[groups allObjects] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"replaceReference=YES || replaceReference=NO"]] count] > 0) {
        
        NSInteger result = [[NSAlert alertWithMessageText:NSLocalizedString(@"Commit merge?", @"Commit merge?")
                                            defaultButton:NSLocalizedString(@"Commit",@"Commit")
                                          alternateButton:NSLocalizedString(@"Don't commit", @"Don't commit")
                                              otherButton:NSLocalizedString(@"Cancel", @"Cancel")
                                informativeTextWithFormat:NSLocalizedString(@"Don't forget to update your unit tests target by adding any new images!", @"Don't forget to update your unit tests target by adding any new images!")] 
                            runModal];
        
        switch(result) {
            case NSAlertDefaultReturn:
                [[self mergeController] commitMerge:self];
                result = NSTerminateNow;
                break;
            case NSAlertAlternateReturn:
                result = NSTerminateNow;
                break;
            case NSAlertOtherReturn:
                result = NSTerminateCancel;
                break;
        }
    }
    
    return reply;
}

@end
