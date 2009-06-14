//
//  OutputGroupTests.m
//  TestMerge
//
//  Created by Barry Wark on 6/5/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "OutputGroupTests.h"
#import "OutputGroup.h"

#import "GTMSystemVersion.h"

@implementation OutputGroupTests
@synthesize moc;
@synthesize group;
@synthesize systemArch;


- (void)setUp {
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:[OutputGroup class]]]];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    STAssertNotNil([psc addPersistentStoreWithType:NSInMemoryStoreType
                                     configuration:nil
                                               URL:nil
                                           options:nil
                                             error:NULL],
                   @"Unable to add store");
    
    self.moc = [[NSManagedObjectContext alloc] init];
    self.moc.persistentStoreCoordinator = psc;
    
    self.group = [OutputGroup newInManagedObjectContext:self.moc];
    
    // System Version
    SInt32 major, minor, bugFix;
    [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
    systemVersions[0] = [NSString stringWithFormat:@".%d.%d.%d", 
                         major, minor, bugFix];
    systemVersions[1] = [NSString stringWithFormat:@".%d.%d", major, minor];
    systemVersions[2] = [NSString stringWithFormat:@".%d", major];
    systemVersions[3] = @"";
    
    // System architecture
    self.systemArch = [NSString stringWithFormat:@".%@", 
                       [GTMSystemVersion runtimeArchitecture]];
}

- (void)tearDown {
    self.moc = nil;
    self.group = nil;
    self.systemArch = nil;
}

- (void)testMostSpecificPathChoosesSystemArchAndVersion {
    NSMutableSet *paths = [NSMutableSet set];
    
    for(NSInteger i=0; i<4; i++) {
        [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@%@.tiff", self.systemArch, systemVersions[i]]];
        [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@.tiff", systemVersions[i]]];
    }
    
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@.tiff", self.systemArch]];
    
    NSString *expected = [NSString stringWithFormat:@"path/to/NAME%@%@.tiff", self.systemArch, systemVersions[0]];
    STAssertEqualObjects([self.group mostSpecificGTMUnitTestOutputPathInSet:paths name:@"NAME" extension:@"tiff"], expected, @"");
}

- (void)testMostSpecificPathChoosesSystemArchWhenNoVersion {
    NSMutableSet *paths = [NSMutableSet set];
    
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@%@.tiff", self.systemArch, @"1.2.3"]];
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@.tiff", self.systemArch]];
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME.xyz.%@.tiff", @"1.2.3"]];
    
    NSString *expected = [NSString stringWithFormat:@"path/to/NAME%@.tiff", self.systemArch];
    
    STAssertEqualObjects([self.group mostSpecificGTMUnitTestOutputPathInSet:paths name:@"NAME" extension:@"tiff"], expected, @"");
}

- (void)testRaisesIfMultipleNamedMatches {
    NSMutableSet *paths = [NSMutableSet set];
    
    [paths addObject:[NSString stringWithFormat:@"path1/to/NAME%@%@.tiff", self.systemArch, systemVersions[0]]];
    [paths addObject:[NSString stringWithFormat:@"path2/to/NAME%@%@.tiff", self.systemArch, systemVersions[0]]];
    
    
    STAssertThrowsSpecific([self.group mostSpecificGTMUnitTestOutputPathInSet:paths name:@"NAME" extension:@"tiff"], NSException, @"");
}

- (void)testIgnoresOtherNames {
    NSMutableSet *paths = [NSMutableSet set];
    
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME1%@%@.tiff", self.systemArch, systemVersions[0]]];
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME2%@%@.tiff", self.systemArch, systemVersions[0]]];
    
    id expected = [NSString stringWithFormat:@"path/to/NAME1%@%@.tiff", self.systemArch, systemVersions[0]]; 
    STAssertEqualObjects([self.group mostSpecificGTMUnitTestOutputPathInSet:paths name:@"NAME1" extension:@"tiff"], expected, @"");
}

- (void)testMostSpecificPathReturnsNilWhenNoVersionsMatch {
    NSMutableSet *paths = [NSMutableSet set];
    
    for(NSInteger i=0; i<4; i++) {
        [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@%@.tiff", self.systemArch, @"1.2.3"]];
        [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@.tiff", @"1.2.3"]];
    }
    
    STAssertNil([self.group mostSpecificGTMUnitTestOutputPathInSet:paths name:@"NAME" extension:@"tiff"], @"");
}

- (void)testMostSpecificPathChoosesSystemVersionWhenNoArch {
    NSMutableSet *paths = [NSMutableSet set];
    
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@%@.tiff", @"abc", systemVersions[0]]];
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@.tiff", systemVersions[0]]];
    [paths addObject:[NSString stringWithFormat:@"path/to/NAME.xyz.tiff"]];
    
    NSString *expected = [NSString stringWithFormat:@"path/to/NAME%@.tiff", systemVersions[0]];
    
    STAssertEqualObjects([self.group mostSpecificGTMUnitTestOutputPathInSet:paths name:@"NAME" extension:@"tiff"], expected, @"");
}

- (void)testMostSpecificPathReturnsNilWhenNoArchsMatch {        
    NSMutableSet *paths = [NSMutableSet set];
    
    for(NSInteger i=0; i<4; i++) {
        [paths addObject:[NSString stringWithFormat:@"path/to/NAME%@%@.tiff", @"abc", systemVersions[0]]];
        [paths addObject:[NSString stringWithFormat:@"path/to/NAME.abc.tiff"]];
    }
    
    STAssertNil([self.group mostSpecificGTMUnitTestOutputPathInSet:paths name:@"NAME" extension:@"tiff"], @"");
}
@end
