//
//  KTSplitViewInspector.h
//  KTUIKit
//
//  Created by Cathy on 15/05/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

@interface KTSplitViewInspector : IBInspector 
{
	IBOutlet NSColorWell *		oBackgroundColorWell;
	IBOutlet NSColorWell *		oFirstStrokeColorWell;
	IBOutlet NSColorWell *		oSecondStrokeColorWell;
	IBOutlet NSPopUpButton *	oOrientationPopUpButton;
	IBOutlet NSPopUpButton *	oResizeBehaviorPopUpButton;
	IBOutlet NSTextField *		oDividerThicknessTextField;
}

- (IBAction)setOrientation:(id)theSender;
- (IBAction)setDividerThickness:(id)theSender;
- (IBAction)setDividerBackgroundColor:(id)theSender;
- (IBAction)setDividerFirstBorderColor:(id)theSender;
- (IBAction)setDividerSecondBorderColor:(id)theSender;
- (IBAction)setResizeBehavior:(id)theSender;

@end
