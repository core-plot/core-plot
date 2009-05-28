//
//  TMImageView.h
//  TestMerge
//
//  Created by Barry Wark on 5/28/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@class TMImageView;

@protocol TMImageViewDelegate

- (void)mouseDownInImageView:(TMImageView*)view;

@end


@interface TMImageView : IKImageView {
    BOOL selected;
}

@property (assign,readwrite) BOOL selected;

@end
