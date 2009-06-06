//
//  TMCompareController.h
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    ReferenceChoice = NO,
    OutputChoice = YES,
    NeitherChoice = -1,
} TMCompareControllerChoice;

@class TMSelectableView;

@interface TMCompareController : NSViewController {
    IBOutlet TMSelectableView *referenceSelectionView;
    IBOutlet TMSelectableView *outputSelectionView;
}

@property (retain,readwrite) IBOutlet TMSelectableView *referenceSelectionView;
@property (retain,readwrite) IBOutlet TMSelectableView *outputSelectionView;

- (void)setMergeChoice:(TMCompareControllerChoice)choice;

@end
