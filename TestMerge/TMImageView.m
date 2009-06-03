//
//  TMImageView.m
//  TestMerge
//
//  Created by Barry Wark on 5/28/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMImageView.h"
#import "GTMDefines.h"

static CGFloat SelectionLineWidth = 4.0;


static CGColorRef CGColorCreateFromNSColor(CGColorSpaceRef colorSpace, NSColor *color) {
    
    NSColor *deviceColor = [color colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    
    float components[4];
    [deviceColor getRed:&components[0] 
                  green:&components[1] 
                   blue:&components[2] 
                  alpha:&components[3]];
    
    return CGColorCreate (colorSpace, components);
}

@interface TMImageView ()

@property (retain,readwrite) CALayer *selectionLayer;

@end

@implementation TMImageView
@synthesize selected;
@dynamic overlay;
@synthesize selectionLayer;

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

- (void)awakeFromNib {
    _GTMDevLog(@"awakeFromNib");
    
    self.selectionLayer = [CALayer layer];
    self.selectionLayer.delegate = self;
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

- (void)setSelected:(BOOL)isSelected {
    if(self.selected != isSelected) {
        selected = isSelected;
        
        _GTMDevLog(@"Setting %@.selectionLayer.hidden = %d", self, !self.selected);
        self.selectionLayer.hidden = !self.selected;
    }
}

- (void)displayLayer:(CALayer*)layer {
    if(layer == self.selectionLayer) {
        _GTMDevLog(@"Displaying %@.selectionLayer", self);
        
        if(self.selected) {
            NSColor *selectionColor = [NSColor selectedControlColor];
            
            CGContextRef context = CGBitmapContextCreate(NULL, 
                                                         layer.bounds.size.width, 
                                                         layer.bounds.size.height, 
                                                         sizeof(CGFloat)*8, //bits per component
                                                         layer.bounds.size.width*sizeof(CGFloat)*[selectionColor numberOfComponents],
                                                         [[selectionColor colorSpace] CGColorSpace],
                                                         kCGImageAlphaPremultipliedLast);
            
            CGRect selectionRect = CGContextGetClipBoundingBox(context);
            selectionRect = CGRectInset(selectionRect, SelectionLineWidth/2., SelectionLineWidth/2.);
            
            
            CGColorRef strokeColor = CGColorCreateFromNSColor([[selectionColor colorSpace] CGColorSpace], selectionColor);
            CGContextSetStrokeColorWithColor(context, strokeColor);
            
            CFRelease(strokeColor);
            
            CGContextSetLineWidth(context, SelectionLineWidth);
            CGContextStrokeRect(context, selectionRect);
            
            CGImageRef selectionImage = CGBitmapContextCreateImage(context);
            
            CFRelease(context);
            
            layer.contents = (id)selectionImage;
            
            CFRelease(selectionImage);
        }
    }
}
@end
