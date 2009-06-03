//
//  TMImageCompareController.m
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMImageCompareController.h"
#import "TMOutputGroup.h"

#import "GTMDefines.h"

@interface TMImageCompareController ()

- (void)unbindViews;
- (void)bindViews;
- (void)updateImageViews;

@end

@implementation TMImageCompareController
@synthesize refImageView;
@synthesize outputImageView;

- (void)dealloc {
    [refImageView release];
    [outputImageView release];
    [self unbindViews];
    
    [super dealloc];
}

- (void)setView:(NSView*)view {
    [super setView:view];
    
    [[IKImageEditPanel sharedImageEditPanel] setHidesOnDeactivate:YES];
    
    [self updateImageViews];
}
    

- (void)updateImageViews {
    
    [self unbindViews];
    
    if([[self representedObject] referencePath] != nil) {
        [[self refImageView] setImageWithURL:[NSURL fileURLWithPath:[[self representedObject] referencePath]]];
    } else {
        [[self refImageView] setImageWithURL:nil];
    }
    
    if([[self representedObject] outputPath] != nil) {
        [[self outputImageView] setImageWithURL:[NSURL fileURLWithPath:[[self representedObject] outputPath]]];
    } else {
        [[self outputImageView] setImageWithURL:nil];
    }
    
    if([[self representedObject] failureDiffPath] != nil) {
        CALayer *diffLayer = [CALayer layer];
        
        CIImage *diffImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:[[self representedObject] failureDiffPath]]];
        
        NSBitmapImageRep *diffRep = [[NSBitmapImageRep alloc] initWithCIImage:diffImage];
        
        diffLayer.contents = (id)[diffRep CGImage];
        
        [[self outputImageView] setOverlay:diffLayer];
    }
    
    [self bindViews];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    [self updateImageViews];
}



- (void)unbindViews {
    [[self refImageView] unbind:@"selected"];
    [[self outputImageView] unbind:@"selected"];
}

- (void)bindViews {
    if([self representedObject] != nil) {
        [[self refImageView] bind:@"selected"
                         toObject:self.representedObject
                      withKeyPath:@"replaceReference"
                          options:[NSDictionary dictionaryWithObjectsAndKeys:
                                   NSNegateBooleanTransformerName, NSValueTransformerNameBindingOption,
                                   [NSNumber numberWithBool:NO], NSNullPlaceholderBindingOption,
                                   nil]];
        
        [[self outputImageView] bind:@"selected"
                            toObject:self.representedObject
                         withKeyPath:@"replaceReference"
                             options:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithBool:NO], NSNullPlaceholderBindingOption,
                                      nil]];
    }
}

- (void)mouseDownInImageView:(TMImageView*)view {
    //_GTMDevLog(@"Mouse down in %@", view);
    if(view == self.refImageView) {
        [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:NO];
    } else if(view == self.outputImageView) {
        [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:YES];
    }
    
    //_GTMDevLog(@"OutputGroup: %@", [self representedObject]);
}
@end
