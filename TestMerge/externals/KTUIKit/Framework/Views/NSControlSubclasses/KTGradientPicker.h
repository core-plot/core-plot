//
//  KTGradientPicker.h
//  KTUIKit
//
//  Created by Cathy Shive on 11/2/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KTViewControl.h"
typedef enum
{
	kKTGradientPickerMouseDragState_NoDrag = 0,
	kKTGradientPickerMouseDragState_DraggingColorStop
	
}KTGradientPickerMouseDragState;

@interface KTGradientPicker : KTViewControl 
{	
	NSGradient *						mGradientValue;
	NSInteger							mActiveColorStop;
	BOOL								mRemoveActiveColorStop;
	KTGradientPickerMouseDragState		mMouseDragState;
}

@property(readwrite,retain) NSGradient * gradientValue;

@end
