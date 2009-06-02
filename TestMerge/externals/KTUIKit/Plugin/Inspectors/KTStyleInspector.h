//
//  KTStyleInspector.h
//  KTUIKit
//
//  Created by Cathy Shive on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

@class KTGradientPicker;
@class KTColorWell;

@interface KTStyleInspector : IBInspector 
{
	// Background
	IBOutlet NSButton *				oDrawBackgroundCheckBox;
	IBOutlet NSMatrix *				oBackgroundOptionsRadioButton;
	IBOutlet NSColorWell *			oBackgroundColorWell;
	IBOutlet KTGradientPicker *		oBackgroundGradientPicker;
	
	// Borders
	IBOutlet NSButton *				oDrawBordersCheckBox;
	IBOutlet NSButton *				oEditAllBordersCheckBox;
	// top
	IBOutlet NSTextField *			oTopBorderWidthTextField;
	IBOutlet KTColorWell*			oTopBorderColorWell;
	// right
	IBOutlet NSTextField *			oRightBorderWidthTextField;
	IBOutlet KTColorWell*			oRightBorderColorWell;
	// bottom
	IBOutlet NSTextField *			oBottomBorderWidthTextField;
	IBOutlet KTColorWell*			oBottomBorderColorWell;
	// left
	IBOutlet NSTextField *			oLeftBorderWidthTextField;
	IBOutlet KTColorWell*			oLeftBorderColorWell;
}

- (IBAction)setDrawsBackground:(id)theSender;
- (IBAction)setBackgroundOption:(id)theSender;
- (IBAction)setBackgroundColor:(id)theSender;
- (IBAction)setBackgroundGradient:(id)theSender;

- (IBAction)setDrawsBorders:(id)theSender;
- (IBAction)setBorderWidth:(id)theSender;
- (IBAction)setBorderColor:(id)theSender;
- (IBAction)setEditAllBorders:(id)theSender;

@end
