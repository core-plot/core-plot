//
//  CPCartesianPlotSpaceTemp.m
//  CorePlot
//
//  Created by Daniel Farrell on 02/02/2009.
//  Copyright 2009 Daniel J Farrell. All rights reserved.
//

#import "CPCartesianPlotSpaceTemp.h"
#import "CPPlotArea.h"
#import "CPPlotSpace.h"
#import "CPDefinitions.h"

@implementation CPCartesianPlotSpaceTemp

@synthesize XRange, YRange;

- (void) setPlotArea: (CPPlotArea*) newPlotArea
{
  plotArea = newPlotArea;
  
  //Need to update the transform as it relied on the min and max x,y points
  transformToView = [self calculateTransformToView];
  transformToPlot = CGAffineTransformInvert(transformToView);
}

-(CGPoint)viewPointForPlotPoint:(NSArray *)decimalNumbers
{
  CGFloat x = (CGFloat) [[decimalNumbers objectAtIndex:0] doubleValue];
  CGFloat y = (CGFloat) [[decimalNumbers objectAtIndex:1] doubleValue];
  CGPoint point = CGPointMake(x, y);
  return CGPointApplyAffineTransform (point, transformToView);
}

-(NSArray *)plotPointForViewPoint:(CGPoint)point
{
  CGPoint plotPoint = CGPointApplyAffineTransform(point, transformToPlot);
  NSDecimalNumber *x = [NSDecimalNumber decimalNumberWithMantissa:plotPoint.x exponent:0 isNegative:NO];
  NSDecimalNumber *y = [NSDecimalNumber decimalNumberWithMantissa:plotPoint.x exponent:0 isNegative:NO];
  return [NSArray arrayWithObjects: x, y, nil];
}

- (CGAffineTransform) calculateTransformToView
{
  CGRect plotRect = self.plotArea.bounds;
  
  /* NB Could code this without the temport variables...
    but then it's hard to see what's going on */
   
  //original coordinate system (data)
  CGFloat Xr = [[NSDecimalNumber decimalNumberWithDecimal:XRange.length] floatValue];
  CGFloat Yr = [[NSDecimalNumber decimalNumberWithDecimal:YRange.length] floatValue];
  CGFloat Xmin = [[NSDecimalNumber decimalNumberWithDecimal:XRange.location] floatValue];
  CGFloat Ymin = [[NSDecimalNumber decimalNumberWithDecimal:YRange.location] floatValue];
  
  //dashed system coordinate system (view)
  CGFloat xr = plotRect.size.width;
  CGFloat yr = plotRect.size.height;
  CGFloat xmin = plotRect.origin.x;
  CGFloat ymin = plotRect.origin.y;
  
  //scale and translation matrix coefficients
  CGFloat Sx = xr/Xr;
  CGFloat Sy = yr/Yr;
  CGFloat Tx = xmin - Xmin*Sx;
  CGFloat Ty = ymin - Ymin*Sy;
  
  return CGAffineTransformMake(Sx, 0.0, 0.0, Sy, Tx, Ty);
  
}



@end
