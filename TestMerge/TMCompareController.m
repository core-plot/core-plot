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
- (void)setupBindings;
@end

@implementation TMCompareController
@synthesize referenceSelectionView;
@synthesize outputSelectionView;

- (void)setView:(NSView*)view {  
    [super setView:view];
    
    [self performSelector:@selector(setupBindings) withObject:nil afterDelay:0.1];
    
}

- (void)setupBindings {
    _GTMDevLog(@"TMCompareController binding selection views (%@ & %@).", self.referenceSelectionView, self.outputSelectionView);
    
    [[self referenceSelectionView] bind:@"selected"
                               toObject:self
                            withKeyPath:@"representedObject.replaceReference"
                                options:[NSDictionary dictionaryWithObjectsAndKeys:
                                         NSNegateBooleanTransformerName, NSValueTransformerNameBindingOption,
                                         [NSNumber numberWithBool:NO], NSNullPlaceholderBindingOption,
                                         nil
                                         ]];
    
    [[self outputSelectionView] bind:@"selected"
                            toObject:self
                         withKeyPath:@"representedObject.replaceReference"
                             options:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:NO], NSNullPlaceholderBindingOption,
                                      nil
                                      ]];
}

- (void)setMergeChoice:(TMCompareControllerChoice)choice {
    switch (choice) {
        case OutputChoice:
        case ReferenceChoice:
            [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:choice];       
            break;
        case NeitherChoice:
            [(id<TMOutputGroup>)[self representedObject] setReplaceReference:nil];       
            break;
    }
}
@end
