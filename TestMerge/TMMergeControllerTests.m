//
//  TMMergeControllerTests.m
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMMergeControllerTests.h"
#import "TMMergeController.h"
#import "TMImageCompareController.h"
#import "TMUTStateCompareController.h"
#import "TMOutputGroup.h"
#import "OutputGroup.h"
#import "TMOutputSorter.h"

#import "GTMNSObject+UnitTesting.h"
#import "GTMNSObject+BindingUnitTesting.h"

@interface OutputGroup (UnitTesting)

- (NSDictionary*)tm_unitTestState;

@end

@implementation OutputGroup (UnitTesting)

- (NSDictionary*)tm_unitTestState {
    return [self dictionaryWithValuesForKeys:[[[self entity] attributesByName] allKeys]];
}

@end


@interface TMMergeController (UnitTesting)
-(void)gtm_unitTestEncodeState:(NSCoder*)coder;
@end

@implementation TMMergeController (UnitTesting)

-(void)gtm_unitTestEncodeState:(NSCoder*)coder {
    [super gtm_unitTestEncodeState:coder];
    
    _GTMDevAssert([coder allowsKeyedCoding], @"");
    _GTMDevLog(@"encoding TMMergeController");
    
    [coder encodeObject:self.referencePath forKey:@"referencePath"];
    [coder encodeObject:self.outputPath forKey:@"outputPath"];
    [coder encodeObject:[[self outputGroups] valueForKeyPath:@"tm_unitTestState"] forKey:@"outputGroups"];
}

@end


@implementation TMMergeControllerTests
- (void)testWindowUIRendering {
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = @"/System/Library";
    controller.outputPath = @"/Library";
    
    (void)[controller window];
    
    GTMAssertObjectImageEqualToImageNamed(controller.window, @"TMMergeControllerTests-testWindowUIRendering", @"");
}

- (void)testOutputGroupsSortsReferenceAndOutputFilesForOSX {
    NSString *groupTestRoot = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"OutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:groupTestRoot isDirectory:&dir] && dir, @"");
    
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = [groupTestRoot stringByAppendingPathComponent:@"Reference"];
    controller.outputPath = [groupTestRoot stringByAppendingPathComponent:@"Output"];
    
    
    (void)[controller window];
    
    STAssertTrue(controller.outputGroups.count > 0, @"");
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testOutputGroupsSortsReferenceAndOutputFiles", @"");
    
}

- (void)testOutputGroupsSortsReferenceAndOutputFilesForIPhone {
    NSString *groupTestRoot = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"IPhoneOutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:groupTestRoot isDirectory:&dir] && dir, @"");
    
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = [groupTestRoot stringByAppendingPathComponent:@"Reference"];
    controller.outputPath = [groupTestRoot stringByAppendingPathComponent:@"Output"];
    
    
    (void)[controller window];
    
    STAssertTrue(controller.outputGroups.count > 0, @"");
    
}

- (void)testSelectsAndRendersImageCompareController {
    NSString *groupTestRoot = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"OutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:groupTestRoot isDirectory:&dir] && dir, @"");
    
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = [groupTestRoot stringByAppendingPathComponent:@"Reference"];
    controller.outputPath = [groupTestRoot stringByAppendingPathComponent:@"Output"];
    
    controller.compareControllersByExtension = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [[TMImageCompareController alloc] initWithNibName:@"ImageCompareView" bundle:[NSBundle mainBundle]],
                                                TMGTMUnitTestImageExtension,
                                                [[TMUTStateCompareController alloc] initWithNibName:@"UTStateCompareView" bundle:[NSBundle mainBundle]],
                                                TMGTMUnitTestStateExtension,
                                                nil];
    
    
    (void)[controller window];
    
    STAssertTrue(controller.outputGroups.count > 0, @"");
    
    id<TMOutputGroup> group = [[[controller outputGroups] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"extension LIKE 'tiff'"]] anyObject];
    
    STAssertNotNil(group, @"");
    
    [controller.groupsController setSelectedObjects:[NSArray arrayWithObject:group]];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersImageCompareController", @"");
    
    [group setReplaceReferenceValue:YES];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersImageCompareController+ReplaceReference", @"");
    
    [group setReplaceReferenceValue:NO];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersImageCompareController+DoNotReplaceReference", @"");
    
    [group setReplaceReference:nil];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersImageCompareController+NilReplaceReference", @"");
}

- (void)testSelectsAndRendersUTStateCompareController {
    NSString *groupTestRoot = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"OutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:groupTestRoot isDirectory:&dir] && dir, @"");
    
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = [groupTestRoot stringByAppendingPathComponent:@"Reference"];
    controller.outputPath = [groupTestRoot stringByAppendingPathComponent:@"Output"];
    
    controller.compareControllersByExtension = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [[TMImageCompareController alloc] initWithNibName:@"ImageCompareView" bundle:[NSBundle mainBundle]],
                                                TMGTMUnitTestImageExtension,
                                                [[TMUTStateCompareController alloc] initWithNibName:@"UTStateCompareView" bundle:[NSBundle mainBundle]],
                                                TMGTMUnitTestStateExtension,
                                                nil];
    
    
    (void)[controller window];
    
    STAssertTrue(controller.outputGroups.count > 0, @"");
    
    _GTMDevLog(@"%@", [[controller outputGroups] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"extension LIKE 'gtmUTState'"]]);
    
    id<TMOutputGroup> group = [[[controller outputGroups] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"extension LIKE 'gtmUTState'"]] anyObject];
    STAssertNotNil(group, @"");
    
    [controller.groupsController setSelectedObjects:[NSArray arrayWithObject:group]];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersUTStateCompareController", @"");
    
    [group setReplaceReferenceValue:YES];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersUTStateCompareController+ReplaceReference", @"");
    
    [group setReplaceReferenceValue:NO];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersUTStateCompareController+DoNotReplaceReference", @"");
    
    [group setReplaceReference:nil];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersUTStateCompareController+NilReplaceReference", @"");
}

- (void)testUnitTestOutputPathsFromPath {
    NSString *groupTestRoot = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"OutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:groupTestRoot isDirectory:&dir] && dir, @"");
    
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = [groupTestRoot stringByAppendingPathComponent:@"Reference"];
    controller.outputPath = [groupTestRoot stringByAppendingPathComponent:@"Output"];
    
    NSArray *expectedPaths = [[NSArray arrayWithObjects:
                              [[controller referencePath] stringByAppendingPathComponent:@"TMMergeControllerTests-testWindowUIRendering.tiff"],
                              [[controller referencePath] stringByAppendingPathComponent:@"CPXYGraphTests-testRenderScatterWithSymbol.i386.tiff"],
                              nil]
                              sortedArrayUsingSelector:@selector(compare:)];
    
    STAssertEqualObjects([controller gtmUnitTestOutputPathsFromPath:controller.referencePath], expectedPaths, @"");
    
    
    NSArray *controllerPaths = [[controller gtmUnitTestOutputPathsFromPath:controller.outputPath] sortedArrayUsingSelector:@selector(compare:)];
    
    expectedPaths = [[NSArray arrayWithObjects:
                               [[controller outputPath] stringByAppendingPathComponent:@"TMMergeControllerTests-testWindowUIRendering_Failed.i386.10.5.7.tiff"],
                               [[controller outputPath] stringByAppendingPathComponent:@"TMMergeControllerTests-testWindowUIRendering_Failed_Diff.i386.10.5.7.tiff"],
                               [[controller outputPath] stringByAppendingPathComponent:@"CPXYGraphTests-testRenderScatterWithSymbol_Failed.i386.10.5.7.tiff"],
                               [[controller outputPath] stringByAppendingPathComponent:@"CPXYGraphTests-testRenderScatterWithSymbol_Failed_Diff.i386.10.5.7.tiff"],
                               [[controller outputPath] stringByAppendingPathComponent:@"TMMergeControllerTests-testWindowUIRendering2.i386.10.5.7.tiff"],
                               nil] sortedArrayUsingSelector:@selector(compare:)];
    
    STAssertEqualObjects(controllerPaths, expectedPaths, @"");
}

- (void)testGroupFilterPredicate {
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    STAssertEqualObjects(controller.groupFilterPredicate, [NSPredicate predicateWithFormat:@"outputPath != nil"], @"");
}

- (void)testPSCCreation {
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    (void)[controller window];
    
    STAssertNotNil(controller.managedObjectContext, @"");
    STAssertTrue(controller.managedObjectContext.persistentStoreCoordinator.persistentStores.count > 0, @"");
}

- (void)testBindings {
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    (void)[controller window];
    
    GTMDoExposedBindingsFunctionCorrectly(controller, nil);
}

- (void)testCommitMerge {
    NSString *outpuDirPath = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"OutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outpuDirPath isDirectory:&dir] && dir, @"");

    NSString *targetPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"OutputGroupTest"];
    
    NSError *err;
    if([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        STAssertTrue([[NSFileManager defaultManager] removeItemAtPath:targetPath error:NULL], @"");
    }
    
    STAssertTrue([[NSFileManager defaultManager] copyItemAtPath:outpuDirPath toPath:targetPath error:&err], @"%@", err);
    
    @try {
        
        TMMergeController *controller = [[TMMergeController alloc] initWithWindowNibName:@"MergeUI"];
        (void)[controller window];
        
        controller.referencePath = [targetPath stringByAppendingPathComponent:@"Reference"];
        controller.outputPath = [targetPath stringByAppendingPathComponent:@"Output"];
        
        NSSet *groups = [controller outputGroups];
        
        for(OutputGroup *group in groups) {
            if([group.name hasPrefix:@"TM"]) {
                [group setReplaceReferenceValue:YES];
            }
        }
        
        _GTMDevLog(@"groups: %@", groups);
        
        [controller commitMerge:self];
        
        
        //test that only CP* in Output
        
        for(NSString *path in [[NSFileManager defaultManager] enumeratorAtPath:[targetPath stringByAppendingPathComponent:@"Output"]]) {
            STAssertTrue([[[path pathComponents] lastObject] hasPrefix:@"CP"], @"Non-TM in reference");
        }
        
        STAssertEquals([[[NSFileManager defaultManager] directoryContentsAtPath:[targetPath stringByAppendingPathComponent:@"Reference"]] count], (NSUInteger)4, @"Including added new TM image: %@", [[NSFileManager defaultManager] directoryContentsAtPath:[targetPath stringByAppendingPathComponent:@"Reference"]]);
        
        STAssertEquals([[[NSFileManager defaultManager] directoryContentsAtPath:[targetPath stringByAppendingPathComponent:@"Output"]] count], (NSUInteger)2, @"Removing _Diff, and new TM image: %@", [[NSFileManager defaultManager] directoryContentsAtPath:[targetPath stringByAppendingPathComponent:@"Output"]]);
        
    }
    @finally {
        STAssertTrue([[NSFileManager defaultManager] removeItemAtPath:targetPath error:NULL], @"");
    }
}

@end
