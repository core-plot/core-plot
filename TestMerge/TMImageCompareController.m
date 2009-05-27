//
//  TMImageCompareController.m
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMImageCompareController.h"

@implementation TMImageCompareController
@synthesize refZoom;
@synthesize outputZoom;
@synthesize refImageView;
@synthesize outputImageView;

- (void)dealloc {
    [refImageView release];
    [outputImageView release];
    
    [super dealloc];
}

@end
