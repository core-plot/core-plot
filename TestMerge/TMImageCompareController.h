//
//  TMImageCompareController.h
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#import "TMCompareController.h"
#import "TMImageView.h"

@interface TMImageCompareController : TMCompareController <TMImageViewDelegate> {
    CGFloat refZoom;
    CGFloat outputZoom;
    
    IBOutlet TMImageView *refImageView;
    IBOutlet TMImageView *outputImageView;
}

@property (assign,readwrite) CGFloat refZoom;
@property (assign,readwrite) CGFloat outputZoom;

@property (retain,readwrite) IBOutlet TMImageView *refImageView;
@property (retain,readwrite) IBOutlet TMImageView *outputImageView;


@end
