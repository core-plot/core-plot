//  GTMFadeTruncatingTextFieldCell.m
//
//  Copyright 2009 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "GTMFadeTruncatingTextFieldCell.h"

#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_5

@implementation GTMFadeTruncatingTextFieldCell
- (void)awakeFromNib {
  // Force to clipping
  [self setLineBreakMode:NSLineBreakByClipping];
}

- (id)initTextCell:(NSString *)aString {
  self = [super initTextCell:aString];
  if (self) {
    // Force to clipping
    [self setLineBreakMode:NSLineBreakByClipping];
  }
  return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
  NSSize size = [[self attributedStringValue] size];

  // Don't complicate drawing unless we need to clip
  if (size.width <= NSWidth(cellFrame)) {
    [super drawInteriorWithFrame:cellFrame inView:controlView];
    return;
  }

  // Gradient is about twice our line height long
  CGFloat gradientWidth = MIN(size.height * 2, NSWidth(cellFrame) / 4);

  NSRect solidPart, gradientPart;
  NSDivideRect(cellFrame, &gradientPart, &solidPart, gradientWidth, NSMaxXEdge);
  
  // Draw non-gradient part without transparency layer, as light text on a dark 
  // background looks bad with a gradient layer.
  [[NSGraphicsContext currentContext] saveGraphicsState];
  [NSBezierPath clipRect:solidPart];
  [super drawInteriorWithFrame:cellFrame inView:controlView];
  [[NSGraphicsContext currentContext] restoreGraphicsState];

  // Draw the gradient part with a transparency layer. This makes the text look
  // suboptimal, but since it fades out, that's ok.
  [[NSGraphicsContext currentContext] saveGraphicsState];
  [NSBezierPath clipRect:gradientPart];
  CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
  CGContextBeginTransparencyLayerWithRect(context,
                                          NSRectToCGRect(gradientPart), 0);

  [super drawInteriorWithFrame:cellFrame inView:controlView];

  // TODO(alcor): switch this to GTMLinearRGBShading if we ever need on 10.4
  NSColor *color = [self textColor];
  NSColor *alphaColor = [color colorWithAlphaComponent:0.0];
  NSGradient *mask = [[NSGradient alloc] initWithStartingColor:color
                                                   endingColor:alphaColor];

  // Draw the gradient mask
  CGContextSetBlendMode(context, kCGBlendModeDestinationIn);
  [mask drawFromPoint:NSMakePoint(NSMaxX(cellFrame) - gradientWidth,
                                  NSMinY(cellFrame))
              toPoint:NSMakePoint(NSMaxX(cellFrame),
                                  NSMinY(cellFrame))
              options:NSGradientDrawsBeforeStartingLocation];
  [mask release];
  CGContextEndTransparencyLayer(context);
  [[NSGraphicsContext currentContext] restoreGraphicsState];
}

@end

#endif
