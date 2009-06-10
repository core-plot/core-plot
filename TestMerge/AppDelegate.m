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

#import "GTMUnitTestingUtilities.h"
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
    Implementation of the applicationShouldTerminate: method, used here to
    commit merge selections.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    int reply = NSTerminateNow;
    
    
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
