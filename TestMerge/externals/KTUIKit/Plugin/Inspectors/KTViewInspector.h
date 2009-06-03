//
//  KTViewInspector.h
//  KTUIKit
//
//  Created by Cathy Shive on 11/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

@interface KTViewInspector : IBInspector 
{
	IBOutlet NSTextField *			oLabelTextField;
	IBOutlet NSColorWell *			oBackgroundColorWell;
}

- (IBAction)setLabel:(id)theSender;

@end
