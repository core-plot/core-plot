//
//  TMImageView.m
//  TestMerge
//
//  Created by Barry Wark on 5/28/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMImageView.h"
#import "GTMDefines.h"

static CGFloat SelectionLineWidth = 4.0;

@implementation TMImageView
@synthesize selected;

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
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    if(self.selected) {
        NSRect selectionRect = self.bounds;
        NSInsetRect(selectionRect, SelectionLineWidth/2, SelectionLineWidth/2);
        NSBezierPath *outlinePath = [NSBezierPath bezierPathWithRect:self.bounds];
        
        [[NSColor selectedControlColor] set];
        
        [outlinePath setLineWidth:SelectionLineWidth];
        [outlinePath stroke];
    }
}

- (void)mouseDown:(NSEvent*)theEvent {
    _GTMDevLog(@"TMImageView <%@> recieved mouseDown event: %@", self, theEvent);
    
    if([[self delegate] conformsToProtocol:@protocol(TMImageViewDelegate)] &&
       [[self delegate] respondsToSelector:@selector(mouseDownInImageView:)]) {
        [[self delegate] mouseDownInImageView:self];
    }
    
    [super mouseDown:theEvent];
}
@end
