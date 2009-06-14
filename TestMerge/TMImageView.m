//
//  TMImageView.m
//  TestMerge
//
//  Created by Barry Wark on 5/28/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMImageView.h"
#import "GTMDefines.h"


@interface TMImageView ()


@end

@implementation TMImageView
@dynamic overlay;

+ (void)initialize {
    if(self == [TMImageView class]) {
        [self exposeBinding:@"selected"];
    }
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
