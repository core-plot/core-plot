//
//  TMImageCompareController.m
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMImageCompareController.h"
#import "TMOutputGroup.h"

#import "GTMDefines.h"

@interface TMImageCompareController ()

- (void)unbindViews;
- (void)bindViews;

@end

@implementation TMImageCompareController
@synthesize refZoom;
@synthesize outputZoom;
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
    
    
    //set up IKImageView delegates and properties
    for(IKImageView *iv in [NSArray arrayWithObjects:self.refImageView,self.outputImageView,nil]) {
        iv.delegate = self;
        iv.hasHorizontalScroller = YES;
        iv.hasVerticalScroller = YES;
        iv.autohidesScrollers = YES;
    }
    
    if([[self representedObject] referencePath]) {
        [[self refImageView] setImageWithURL:[NSURL fileURLWithPath:[[self representedObject] referencePath]]];
    }
    
    if([[self representedObject] outputPath]) {
        [[self outputImageView] setImageWithURL:[NSURL fileURLWithPath:[[self representedObject] outputPath]]];
    }
    
    [self unbindViews];
    [self bindViews];
    
//    if(nil != [[self representedObject] failureDiffPath]) {
//        CALayer *diffLayer = [CALayer layer];
//        
//        CIImage *diffImage = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:[[self representedObject] failureDiffPath]]];
//        
//        NSBitmapImageRep *diffRep = [[[NSBitmapImageRep alloc] initWithCIImage:diffImage] autorelease];
//        
//        diffLayer.contents = (id)[diffRep CGImage];
//        diffLayer.bounds = NSRectToCGRect([[self outputImageView] bounds]);
//        diffLayer.anchorPoint = CGPointZero;
//        diffLayer.position = CGPointZero;
//        
//        [[self outputImageView] setOverlay:diffLayer forType:IKOverlayTypeImage];
//    }
    
}

- (void)unbindViews {
    for(NSView *view in [NSArray arrayWithObjects:self.refImageView, self.outputImageView, nil]) {
        [view unbind:@"selected"];
    }
}
    

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    [self unbindViews];
    [self bindViews];
}

- (void)bindViews {
    [[self refImageView] bind:@"selected"
                     toObject:self.representedObject
                  withKeyPath:@"replaceReference"
                      options:[NSDictionary dictionaryWithObject:NSNegateBooleanTransformerName forKey:NSValueTransformerNameBindingOption]];
    
    [[self outputImageView] bind:@"selected"
                        toObject:self.representedObject
                     withKeyPath:@"replaceReference"
                         options:nil];
}

- (void)mouseDownInImageView:(TMImageView*)view {
    _GTMDevLog(@"Mouse down in %@", view);
    if(view == self.refImageView) {
        [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:NO];
    } else if(view == self.outputImageView) {
        [(id<TMOutputGroup>)[self representedObject] setReplaceReferenceValue:YES];
    }
}
@end
