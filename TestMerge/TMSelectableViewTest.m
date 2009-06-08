//
//  TMSelectableViewTest.m
//  TestMerge
//
//  Created by Barry Wark on 6/5/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMSelectableViewTest.h"

#import "TMSelectableView.h"

#import "GTMNSObject+UnitTesting.h"

@implementation TMSelectableViewTest

- (void)testRendering {
    TMSelectableView *view = [[TMSelectableView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
    
    view.selected = NO;
    view.drawsBackground = YES;
    
    GTMAssertObjectImageEqualToImageNamed(view, @"TMSelectableViewTests-testRendering-unselected-background", @"");
    
    view.selected = YES;
    GTMAssertObjectImageEqualToImageNamed(view, @"TMSelectableViewTests-testRendering-selected-background", @"");
    
    view.drawsBackground = NO;
    GTMAssertObjectImageEqualToImageNamed(view, @"TMSelectableViewTests-testRendering-selected-nobackground", @"");
    
    view.selected = NO;
    GTMAssertObjectImageEqualToImageNamed(view, @"TMSelectableViewTests-testRendering-unselected-background", @"");
}
@end
