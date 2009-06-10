//
//  TMOutputSorter.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TMOutputGroupFactory.h"

extern NSString * const TMGTMUnitTestStateExtension;
extern NSString * const TMGTMUnitTestImageExtension;

@interface TMOutputSorter : NSObject {
    NSArray *referencePaths;
    NSArray *outputPaths;
}

@property (copy,readwrite) NSArray *referencePaths;
@property (copy,readwrite) NSArray *outputPaths;

- (id)initWithReferencePaths:(NSArray*)ref
                 outputPaths:(NSArray*)output;

- (NSSet*)sortedOutputWithGroupFactory:(id<TMOutputGroupFactory>)factory error:(NSError**)error;
@end
