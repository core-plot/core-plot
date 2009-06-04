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

@interface TMCompareController ()

@end

@implementation TMCompareController

- (void)setMergeChoice:(TMCompareControllerChoice)choice {
    [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:choice];
}
@end
