//
//  TMSelectableView.h
//  TestMerge
//
//  Created by Barry Wark on 6/5/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TMSelectableView : NSView {
    BOOL selected;
    BOOL drawsBackground;
}

@property (readwrite,assign,nonatomic) BOOL selected;
@property (readwrite,assign,nonatomic) BOOL drawsBackground;

@end
