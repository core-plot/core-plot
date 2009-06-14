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

- (void)updateImageViews;

@end

@implementation TMImageCompareController
@synthesize refImageView;
@synthesize outputImageView;

- (void)dealloc {
    [refImageView release];
    [outputImageView release];
    
    [super dealloc];
}

- (void)setView:(NSView*)view {
    [super setView:view];
    
    [[IKImageEditPanel sharedImageEditPanel] setHidesOnDeactivate:YES];
    
    [self updateImageViews];
}
    

- (void)updateImageViews {
    
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
        
        diffLayer.contents = (id)[[NSBitmapImageRep imageRepWithData:[NSData dataWithContentsOfFile:[[self representedObject] failureDiffPath]]] CGImage];
        
        [[self outputImageView] setOverlay:diffLayer];
    }
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    [self updateImageViews];
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
