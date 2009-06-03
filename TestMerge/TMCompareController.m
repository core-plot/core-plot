//
//  TMCompareController.m
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMCompareController.h"

#import "TMOutputGroup.h"

#import "GTMDefines.h"

typedef enum {
    OutputChoice = YES,
    ReferenceChoice = NO
} TMCompareControllerChoice;

@interface TMCompareController ()

- (void)setMergeChoice:(TMCompareControllerChoice)choice;

@end

@implementation TMCompareController
- (IBAction)selectReference:(id)sender {
    _GTMDevLog(@"User selected reference");
    [self setMergeChoice:ReferenceChoice];
}

- (IBAction)selectOutput:(id)sender {
    _GTMDevLog(@"User selected output");
    [self setMergeChoice:OutputChoice];
}

- (void)setMergeChoice:(TMCompareControllerChoice)choice {
    [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:choice];
}
@end
