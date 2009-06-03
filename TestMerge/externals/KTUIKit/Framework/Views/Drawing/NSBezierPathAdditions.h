//
//  NSBezierPathCategory.h
//
//  Created by Cathy Shive on 12/21/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

// http://developer.apple.com/samplecode/Reducer/listing20.html

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (RoundRect)
+ (NSBezierPath *)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;
- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius;

+ (NSBezierPath *)bezierPathWithLeftRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
+ (NSBezierPath *)bezierPathWithRightRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
+ (NSBezierPath *)bezierPathWithTopRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
+ (NSBezierPath *)bezierPathWithBottomRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
+ (NSBezierPath *)bezierPathWithTopRoundedRect:(NSRect)theRect cornerRadius:(float)theRadius;
+ (NSBezierPath *)bezierPathWithBottomRoundedRect:(NSRect)theRect cornerRadius:(float)theRadius;
- (void)appendBezierPathWithLeftRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
- (void)appendBezierPathWithRightRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
- (void)appendBezierPathWithTopRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
- (void)appendBezierPathWithBottomRoundedRect:(NSRect)theRect cornerRadius:(float)theCornerRadius;
@end
