//
//  TMOutputSorterTests.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMOutputSorterTests.h"
#import "TMOutputSorter.h"
#import "NSString+UUID.h"

#import "GTMNSObject+UnitTesting.h"
#import "GTMNSString+FindFolder.h"
#import "GTMSystemVersion.h"

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>

@interface TMOutputSorter (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder;

@end

@implementation TMOutputSorter (UnitTesting)

- (void)gtm_unitTestEncodeState:(NSCoder*)inCoder {
    [super gtm_unitTestEncodeState:inCoder];
    
    [inCoder encodeObject:self.outputPaths forKey:@"outputPath"];
    [inCoder encodeObject:self.referencePaths forKey:@"referencePath"];
}

@end


typedef enum _OutputType {
    Success,
    Failure,
    Diff
} OutputType;



@interface TMOutputSorterTests ()

- (void)failureTestsForExtension:(NSString*)extension;

@end

@implementation TMOutputSorterTests

- (NSString*)outputFileForName:(NSString*)name
                          arch:(NSString*)arch
                        system:(NSString*)systemVersion
                     extension:(NSString*)extension
                          type:(OutputType)outputType {
    
    NSString *suffix;
    switch(outputType) {
        case Success:
            suffix = @"";
            break;
        case Failure:
            suffix = @"_Failed";
            break;
        case Diff:
            suffix = @"_Failed_Diff";
            break;
    }
    
    return [NSString stringWithFormat:@"%@%@.%@.%@.%@", name, suffix, arch, systemVersion, extension];
    
}

- (void)testInitialState {
    NSArray *refPaths = [NSArray arrayWithObject:@"refPath1"];
    NSArray *outputPaths = [NSArray arrayWithObjects:@"outputPath1", @"outputPath2", nil];
    
    TMOutputSorter *sorter = [[TMOutputSorter alloc] initWithReferencePaths:refPaths
                                                                outputPaths:outputPaths];
    
    GTMAssertObjectStateEqualToStateNamed(sorter, @"TMOutputSorterTests-testInitialState", @"");
}

- (void)testSortedOutputWithGroupFactoryAddsRefPaths {
    //also tests group creation for successes
    
    SInt32 major, minor, bugFix;
    [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
    
    NSString *actualSystem = [NSString stringWithFormat:@"%d.%d.%d", 
                              major, minor, bugFix];
    
    NSString *prevSystem = [NSString stringWithFormat:@"%d.%d.%d", 
                            major, minor, bugFix-1];
    
    NSString *actualArch = [GTMSystemVersion runtimeArchitecture];
    NSString *otherArch = [actualArch isEqualToString:@"ppc"]?@"i386":@"ppc";
    
    NSArray *refPaths = [NSArray arrayWithObjects:
                         [self outputFileForName:@"testSortWithOutputGroupFactoryUsesCorrectSystemVersion"
                                            arch:actualArch 
                                          system:actualSystem
                                       extension:@"tiff"
                                            type:Success],
                         [self outputFileForName:@"testSortWithOutputGroupFactoryUsesCorrectSystemVersion"
                                            arch:otherArch 
                                          system:actualSystem
                                       extension:@"tiff"
                                            type:Success],
                         [self outputFileForName:@"testSortWithOutputGroupFactoryUsesCorrectSystemVersion"
                                            arch:actualArch 
                                          system:prevSystem
                                       extension:@"tiff"
                                            type:Success],
                         [self outputFileForName:@"testSortWithOutputGroupFactoryUsesCorrectSystemVersion"
                                            arch:otherArch 
                                          system:prevSystem
                                       extension:@"tiff"
                                            type:Success],
                         nil];
    
    NSArray *outputPaths = [NSArray array];
    
    //Mocks
    id factory = [OCMockObject mockForProtocol:@protocol(TMOutputGroupFactory)];
    id group = [OCMockObject mockForProtocol:@protocol(TMOutputGroup)];
    
    //expectation -- one group per output
    for(NSInteger i=0; i<refPaths.count; i++) {
        [[[factory expect] andReturn:group] groupWithName:@"testSortWithOutputGroupFactoryUsesCorrectSystemVersion" extension:@"tiff"];
        [[group expect] setReferencePath:[refPaths objectAtIndex:i]];
    }
    
    TMOutputSorter *sorter = [[TMOutputSorter alloc] initWithReferencePaths:refPaths
                                                                outputPaths:outputPaths];
    
    NSSet *groups = [sorter sortedOutputWithGroupFactory:factory error:NULL];
    
    STAssertNotNil(groups, @"");
    STAssertTrue(groups.count == refPaths.count, @"one group per path");
    
    [factory verify];
    [group verify];
    
}

- (void)testSortedOutputWithGroupFactoryBuildsGroupsForImageFailures {
    [self failureTestsForExtension:@"tiff"];
}

- (void)testSortedOutputWithGroupFactoryBuildsGroupsForStateFailures {
    [self failureTestsForExtension:@"gtmUTState"];
}

- (void)failureTestsForExtension:(NSString*)extension {
    SInt32 major, minor, bugFix;
    [GTMSystemVersion getMajor:&major minor:&minor bugFix:&bugFix];
    
    NSString *actualSystem = [NSString stringWithFormat:@"%d.%d.%d", 
                              major, minor, bugFix];
    
    
    NSString *actualArch = [GTMSystemVersion runtimeArchitecture];
    
    NSString *expectedRefPath = [self outputFileForName:@"failureTestsForExtension"
                                                   arch:actualArch 
                                                 system:actualSystem
                                              extension:extension
                                                   type:Success];
    
    NSArray *refPaths = [NSArray arrayWithObjects:
                         expectedRefPath,
                         nil];
    
    NSArray *outputPaths = [NSArray arrayWithObjects:
                            [self outputFileForName:@"failureTestsForExtension"
                                               arch:actualArch 
                                             system:actualSystem
                                          extension:extension
                                               type:Failure],
                            [self outputFileForName:@"failureTestsForExtension"
                                               arch:actualArch 
                                             system:actualSystem
                                          extension:extension
                                               type:Diff],
                            nil];
    
    //Mocks
    id factory = [OCMockObject mockForProtocol:@protocol(TMOutputGroupFactory)];
    id group = [OCMockObject mockForProtocol:@protocol(TMOutputGroup)];
    
    //expectation -- combined group
    [[[factory expect] andReturn:group] groupWithName:@"failureTestsForExtension" extension:extension];
    
    [[group expect] setReferencePath:expectedRefPath];
    
    for(NSInteger i=0; i<outputPaths.count; i++) {
        
        [[[factory expect] andReturn:group] groupWithName:@"failureTestsForExtension" extension:extension];
        [[group expect] setOutputPath:[self outputFileForName:@"failureTestsForExtension"
                                                         arch:actualArch 
                                                       system:actualSystem
                                                    extension:extension
                                                         type:Failure]];
        
        [[[factory expect] andReturn:group] groupWithName:@"failureTestsForExtension" extension:extension];
        [[group expect] setFailureDiffPath:[self outputFileForName:@"failureTestsForExtension"
                                                             arch:actualArch 
                                                           system:actualSystem
                                                        extension:extension
                                                             type:Diff]];
    }
    
    
    TMOutputSorter *sorter = [[TMOutputSorter alloc] initWithReferencePaths:refPaths
                                                                outputPaths:outputPaths];
    
    NSSet *groups = [sorter sortedOutputWithGroupFactory:factory error:NULL];
    
    STAssertNotNil(groups, @"");
    STAssertTrue(groups.count == 1, @"one group");
    
    [factory verify];
    [group verify];   
}
@end
