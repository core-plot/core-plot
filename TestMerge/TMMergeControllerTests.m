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

- (void)testOutputGroupsSortsReferenceAndOutputFiles {
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

- (void)testSelectsAndRendersImageCompareController {
    NSString *groupTestRoot = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"OutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:groupTestRoot isDirectory:&dir] && dir, @"");
    
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = [groupTestRoot stringByAppendingPathComponent:@"Reference"];
    controller.outputPath = [groupTestRoot stringByAppendingPathComponent:@"Output"];
    
    controller.compareControllersByExtension = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [[[TMImageCompareController alloc] initWithNibName:@"ImageCompareView" bundle:[NSBundle mainBundle]] autorelease],
                                                TMGTMUnitTestImageExtension,
                                                nil];
    
    
    (void)[controller window];
    
    STAssertTrue(controller.outputGroups.count > 0, @"");
    
    [controller.groupsController setSelectedObjects:[NSArray arrayWithObject:[[controller outputGroups] anyObject]]];
    
    GTMAssertObjectEqualToStateAndImageNamed(controller.window, @"TMMergeControllerTests-testSelectsAndRendersImageCompareController", @"");
}

- (void)testUnitTestOutputPathsFromPath {
    NSString *groupTestRoot = [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"OutputGroupTest"];
    
    BOOL dir;
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:groupTestRoot isDirectory:&dir] && dir, @"");
    
    TMMergeController *controller = [[[TMMergeController alloc] initWithWindowNibName:@"MergeUI"] autorelease];
    
    controller.referencePath = [groupTestRoot stringByAppendingPathComponent:@"Reference"];
    controller.outputPath = [groupTestRoot stringByAppendingPathComponent:@"Output"];
    
    STAssertEqualObjects([controller gtmUnitTestOutputPathsFromPath:controller.referencePath],
                         [NSArray arrayWithObject:[[controller referencePath] stringByAppendingPathComponent:@"TMMergeControllerTests-testWindowUIRendering.tiff"]], @"");
    
    
    NSArray *controllerPaths = [[controller gtmUnitTestOutputPathsFromPath:controller.outputPath] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *expectedPaths = [[NSArray arrayWithObjects:
                            [[controller outputPath] stringByAppendingPathComponent:@"TMMergeControllerTests-testWindowUIRendering_Failed.i386.10.5.7.tiff"],
                            [[controller outputPath] stringByAppendingPathComponent:@"TMMergeControllerTests-testWindowUIRendering_Failed_Diff.i386.10.5.7.tiff"],
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
        
        [controller commitMerge:self];
        
        
        //test that only TM* in Reference and only CP* in Output
        for(NSString *path in [[NSFileManager defaultManager] enumeratorAtPath:[targetPath stringByAppendingPathComponent:@"Reference"]]) {
            STAssertTrue([[[path pathComponents] lastObject] hasPrefix:@"TM"], @"Non-TM in reference");
        }
        
        for(NSString *path in [[NSFileManager defaultManager] enumeratorAtPath:[targetPath stringByAppendingPathComponent:@"Output"]]) {
            STAssertTrue([[[path pathComponents] lastObject] hasPrefix:@"CP"], @"Non-TM in reference");
        }
        
    }
    @finally {
        STAssertTrue([[NSFileManager defaultManager] removeItemAtPath:targetPath error:NULL], @"");
    }
}

@end
