//
//  ILCompanyStatementsChartViewController.h
//  iLux2
//
//  Created by Oleksii Chopyk on 5/19/15.
//  Copyright (c) 2015 luxoft. All rights reserved.
//

#import "CPTFill.h"
#import "CPTPlatformSpecificDefines.h"

@interface CPTStretchableImageFill : CPTFill

@property (nonatomic, assign) CGFloat leftInset;
@property (nonatomic, assign) CGFloat topInset;
@property (nonatomic, assign) CGFloat rightInset;
@property (nonatomic, assign) CGFloat bottomInset;

- (id)initWithStretchableImage:(CPTNativeImage*)image;
@property (nonatomic, strong, readonly) CPTNativeImage* stretchableImage;

@end
