//
//  CPTPolarPlotSpaceAnnotation.h
//  CorePlot Mac
//
//  Created by Steve Wainwright on 10/12/2020.
//

#import "CPTAnnotation.h"

@class CPTPolarPlotSpace;

@interface CPTPolarPlotSpaceAnnotation : CPTAnnotation

@property (nonatomic, readwrite, copy, nullable) CPTNumberArray *anchorPlotPoint;
@property (nonatomic, readonly, nonnull) CPTPolarPlotSpace *plotSpace;

/// @name Initialization
/// @{
-(nonnull instancetype)initWithPlotSpace:(nonnull CPTPolarPlotSpace *)space anchorPlotPoint:(nullable CPTNumberArray *)plotPoint NS_DESIGNATED_INITIALIZER;
-(nullable instancetype)initWithCoder:(nonnull NSCoder *)coder NS_DESIGNATED_INITIALIZER;
/// @}

@end
