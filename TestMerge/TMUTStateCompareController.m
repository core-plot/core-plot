//
//  TMUTStateCompareController.m
//  TestMerge
//
//  Created by Barry Wark on 6/4/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMUTStateCompareController.h"

#import "TMOutputGroup.h"

@implementation TMUTStateCompareController
@dynamic referenceText;
@dynamic outputText;

+ (NSSet*)keyPathsForValuesAffectingReferenceText {
    return [NSSet setWithObject:@"representedObject.referencePath"];
}

+ (NSSet*)keyPathsForValuesAffectingOutputText {
    return [NSSet setWithObject:@"representedObject.outputPath"];
}

- (NSString*)referenceText {
    return [NSString stringWithContentsOfFile:[(id<TMOutputGroup>)[self representedObject] referencePath]];
}

- (NSString*)outputText {
    return [NSString stringWithContentsOfFile:[(id<TMOutputGroup>)[self representedObject] outputPath]];
}
@end
