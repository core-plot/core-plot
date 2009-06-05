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
@synthesize referenceSelectionView;
@synthesize outputSelectionView;

- (void)setView:(NSView*)view {
    [super setView:view];
    
    [self.referenceSelectionView unbind:@"selected"];
    [self.outputSelectionView unbind:@"selected"];
    
    [[self referenceSelectionView] bind:@"selected"
                               toObject:self
                            withKeyPath:@"representedObject.replaceReference"
                                options:[NSDictionary dictionaryWithObject:NSNegateBooleanTransformerName forKey:NSValueTransformerNameBindingOption]];
    
    [[self outputSelectionView] bind:@"selected"
                            toObject:self
                         withKeyPath:@"representedObject.replaceReference"
                             options:nil];
    
}

- (void)setMergeChoice:(TMCompareControllerChoice)choice {
    [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:choice];
}
@end
