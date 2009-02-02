//
//  CPLineStyle.m
//  CorePlot
//
//  Created by Dirkjan Krijnders on 2/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CPLineStyle.h"


@implementation CPLineStyle


@synthesize lineCap, lineJoin, lineWidth, patternPhase, lineColor;

#pragma mark init/dealloc

+ (CPLineStyle*) defaultLineStyle
{
	return [[[CPLineStyle alloc] init] autorelease];
};

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.lineCap = kCGLineCapButt;
		self.lineJoin = kCGLineJoinMiter;
		self.lineWidth = 1.f;
		self.patternPhase = CGSizeMake(0.f, 0.f);
		self.lineColor = CGColorGetConstantColor(kCGColorBlack);
	}
	return self;
}

- (void) dealloc
{
	CGColorRelease(lineColor);
	[super dealloc];
}


- (void) CPApplyLineStyleToContext:(CGContextRef)theContext
{
	CGContextSetLineCap(theContext, lineCap);
	CGContextSetLineJoin(theContext, lineJoin);
	CGContextSetLineWidth(theContext, lineWidth);
	CGContextSetPatternPhase(theContext, patternPhase);
	CGContextSetStrokeColorWithColor(theContext, lineColor);

}

#pragma mark Allocators

- (void) setLineColor:(CGColorRef)aLineColor
{
	if (aLineColor != lineColor)
	{
		CGColorRetain(aLineColor);
		CGColorRelease(lineColor);
		lineColor = aLineColor;
	}
}

@end
