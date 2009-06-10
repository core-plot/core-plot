//
//  OutputGroupTests.h
//  TestMerge
//
//  Created by Barry Wark on 6/5/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "GTMSenTestCase.h"

@class OutputGroup;

@interface OutputGroupTests : GTMTestCase {
    OutputGroup *group;
    NSManagedObjectContext *moc;
    
    NSString *systemArch;
    NSString *systemVersions[4];
}

@property (retain) OutputGroup *group;
@property (retain) NSManagedObjectContext *moc;

@property (copy) NSString *systemArch;
@end
