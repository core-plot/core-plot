//
//  TMCompareController.h
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    OutputChoice = YES,
    ReferenceChoice = NO
} TMCompareControllerChoice;

@interface TMCompareController : NSViewController {

}

- (void)setMergeChoice:(TMCompareControllerChoice)choice;

@end
