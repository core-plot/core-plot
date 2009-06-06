//
//  TMSelectableView.m
//  TestMerge
//
//  Created by Barry Wark on 6/5/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMSelectableView.h"

#import "GTMDefines.h"

static CGFloat SelectionLineWidth = 2.0;


@implementation TMSelectableView
@synthesize selected;
@synthesize drawsBackground;

+ (NSArray*)exposedBindings {
    return [NSArray arrayWithObjects:@"selected",@"drawsBackground",nil];
}

- (Class)valueClassForBinding:(NSString*)binding {
    if([binding isEqualToString:@"selected"] ||
        [binding isEqualToString:@"drawsBackground"]) {
        return [NSValue class];
    }
    
    return [super valueClassForBinding:binding];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        selected = NO;
        drawsBackground = YES;
    }
    return self;
}

- (void)awakeFromNib {
    NSRect subFrame = NSInsetRect(self.bounds, SelectionLineWidth, SelectionLineWidth);
    
    for(NSView *sub in [self subviews]) {
        [sub setFrame:NSOffsetRect(subFrame, -subFrame.origin.x + SelectionLineWidth, -subFrame.origin.y+SelectionLineWidth)];
    }
}

- (void)addSubview:(NSView*)subView {    
    NSRect bounds = NSInsetRect(self.bounds, SelectionLineWidth, SelectionLineWidth);
    [subView setFrame:NSOffsetRect(bounds, -bounds.origin.x + SelectionLineWidth, -bounds.origin.y+SelectionLineWidth)];
    
    [super addSubview:subView];
}

- (void)drawRect:(NSRect)rect {
    if(self.drawsBackground) {
        [[NSColor grayColor] set];
        [NSBezierPath fillRect:self.bounds];
    }
    
    if(self.selected) {
        NSRect strokeRect = NSInsetRect(self.bounds, SelectionLineWidth/2, SelectionLineWidth/2);
        NSBezierPath *strokePath = [NSBezierPath bezierPathWithRect:strokeRect];
        
        [strokePath setLineWidth:SelectionLineWidth];
        [strokePath setLineJoinStyle:NSMiterLineJoinStyle];
        [strokePath setLineCapStyle:NSRoundLineCapStyle];
        
        [[NSColor selectedControlColor] set];
        
        [strokePath stroke];
    }
}

- (void)setSelected:(BOOL)newSelected {
    if(newSelected != self.selected) {
        _GTMDevLog(@"%@ selected = %@", self, self.selected?@"YES":@"NO");
        selected = newSelected;
        [self setNeedsDisplay:YES];
    }
}

- (void)setDrawsBackground:(BOOL)draw {
    if(draw != self.drawsBackground) {
        drawsBackground = draw;
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseDown:(NSEvent*)theEvent {
    if(!self.selected) self.selected = YES;
    
    [super mouseDown:theEvent];
}
@end
