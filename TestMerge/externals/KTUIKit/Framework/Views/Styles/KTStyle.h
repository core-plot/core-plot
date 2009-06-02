/*
 *  KTStyledView.h
 *  KTUIKit
 *
 *  Created by Cathy Shive on 11/2/08.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */

@class KTStyleManager;
@class NSWindow;

@protocol KTStyle<NSObject>
- (KTStyleManager*)styleManager;
- (void)setStyleManager:(KTStyleManager*)theStyleManager;
- (void)setNeedsDisplay:(BOOL)theBool;
- (NSWindow *)window;
@end