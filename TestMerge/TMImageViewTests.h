//
//  TMImageViewTests.h
//  TestMerge
//
//  Created by Barry Wark on 5/28/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "GTMSenTestCase.h"

#import "TMImageView.h"

@interface TMImageViewTests : GTMTestCase <TMImageViewDelegate> {
    TMImageView *imageView;
    
    BOOL flag;
}

@property (retain,readwrite) TMImageView *imageView;
@property (assign,readwrite) BOOL flag;

- (void)mouseDownInImageView:(TMImageView*)view;
@end
