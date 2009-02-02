//
//  CPLineStyle.h
//  CorePlot
//
//  Created by Dirkjan Krijnders on 2/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CPLineStyle : NSObject {
	CGLineCap lineCap;
//	CGLineDash lineDash; // We should make a struct to keep this information
	CGLineJoin lineJoin;
	CGFloat lineWidth;
	CGSize patternPhase;
//	StrokePattern; // We should make a struct to keep this information
	CGColorRef lineColor;
}

+ (CPLineStyle*) defaultLineStyle;

@property (assign) CGLineCap lineCap;
@property (assign) CGLineJoin lineJoin;
@property (assign) CGFloat lineWidth;
@property (assign) CGSize patternPhase;
@property (assign) CGColorRef lineColor;

- (void) CPApplyLineStyleToContext:(CGContextRef)theContext;

@end
