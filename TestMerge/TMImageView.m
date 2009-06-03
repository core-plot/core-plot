//
//  TMImageView.m
//  TestMerge
//
//  Created by Barry Wark on 5/28/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMImageView.h"
#import "GTMDefines.h"

//static CGFloat SelectionLineWidth = 4.0;

@interface TMImageView ()

@end

@implementation TMImageView
@synthesize selected;
@dynamic overlay;

+ (void)initialize {
    if(self == [TMImageView class]) {
        [self exposeBinding:@"selected"];
    }
}


- (Class)valueClassForBinding:(NSString*)binding {
    if([binding isEqualToString:@"selected"]) {
        return [NSValue class];
    }
    
    return [super valueClassForBinding:binding];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selected = NO;
        //_GTMDevLog(@"TMImageView initWithFrame:");
    }
    return self;
}
    

- (void)mouseDown:(NSEvent*)theEvent {
    if([[self delegate] conformsToProtocol:@protocol(TMImageViewDelegate)] &&
       [[self delegate] respondsToSelector:@selector(mouseDownInImageView:)]) {
        [[self delegate] mouseDownInImageView:self];
    }
    
    [super mouseDown:theEvent];
}

- (void)setOverlay:(CALayer*)overlay {
    [self setOverlay:overlay forType:IKOverlayTypeImage];
}

- (CALayer*)overlay {
    return [self overlayForType:IKOverlayTypeImage];
}
@end
