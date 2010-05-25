//
//  TMOutputGroupCDFactoryTests.m
//  TestMerge
//
//  Created by Barry Wark on 6/3/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMOutputGroupCDFactoryTests.h"

#import "TMOutputGroup.h"
#import "TMOutputGroupCDFactory.h"
#import "OutputGroup.h"

@implementation TMOutputGroupCDFactoryTests
@synthesize moc;

- (void)setUp {
    NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:[NSBundle bundleForClass:[TMOutputGroupCDFactory class]]]];
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    STAssertNotNil([psc addPersistentStoreWithType:NSInMemoryStoreType configuration:nil URL:nil options:nil error:NULL], @"Unable to add in-memory store.");
    
    self.moc = [[NSManagedObjectContext alloc] init];
    self.moc.persistentStoreCoordinator = psc;
}

- (void)tearDown {
    self.moc = nil;
}

- (void)testGroupWithNameReturnsExistingGroup {
    id<TMOutputGroup> group1 = [OutputGroup insertInManagedObjectContext:self.moc];
    group1.name = @"test_name";
    group1.extension = @"test_ext";
    
    id<TMOutputGroup> group2 = [OutputGroup insertInManagedObjectContext:self.moc];
    
    group2.name = @"test_name2";
    group2.extension = @"test_ext";
    
    id<TMOutputGroup> group3 = [OutputGroup insertInManagedObjectContext:self.moc];
    
    group3.name = @"test_name";
    group3.extension = @"test_ext3";
    
    STAssertTrue([[self moc] save:NULL], @"unable to save");
    
    STAssertEqualObjects([[[TMOutputGroupCDFactory alloc] initWithManagedObjectContext:self.moc] groupWithName:@"test_name" extension:@"test_ext"], group1, @"");
}

- (void)testGroupWithnameRaisesForMultipleGroups {
    id<TMOutputGroup> group1 = [OutputGroup insertInManagedObjectContext:self.moc];
    group1.name = @"test_name";
    group1.extension = @"test_ext";
    
    id<TMOutputGroup> group2 = [OutputGroup insertInManagedObjectContext:self.moc];
    
    group2.name = @"test_name";
    group2.extension = @"test_ext";
    
    STAssertTrue([[self moc] save:NULL], @"unable to save");
    
    STAssertThrowsSpecificNamed([[[TMOutputGroupCDFactory alloc] initWithManagedObjectContext:self.moc] groupWithName:@"test_name" extension:@"test_ext"], NSException, TMOutputGroupCDFactoryTooManyGroupsException, @"");
}
@end
