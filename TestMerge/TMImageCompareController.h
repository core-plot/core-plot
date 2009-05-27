//
//  TMImageCompareController.h
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface TMImageCompareController : NSViewController {
    CGFloat refZoom;
    CGFloat outputZoom;
    
    IBOutlet IKImageView *refImageView;
    IBOutlet IKImageView *outputImageView;
}

@property (assign,readwrite) CGFloat refZoom;
@property (assign,readwrite) CGFloat outputZoom;

@property (retain,readwrite) IBOutlet IKImageView *refImageView;
@property (retain,readwrite) IBOutlet IKImageView *outputImageView;


@end
