//
//  KTGradientPickerIntegration.m
//  KTUIKit
//
//  Created by Cathy Shive on 11/3/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

// Import your framework view and your inspector 
 #import <KTUIKit/KTGradientPicker.h>
 #import "KTLayoutManagerInspector.h"
	
@implementation KTGradientPicker ( KTGradientPickerIntegration )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];

	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:/* @"MyFirstProperty", @"MySecondProperty",*/ nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes 
{
	[super ibPopulateAttributeInspectorClasses:classes];
}

- (NSSize)ibPreferredDesignSize
{
	return NSMakeSize(200, 36);
}

- (NSSize)ibMinimumSize
{
	return NSMakeSize(50, 36);
}

- (NSSize)ibMaximumSize
{
	return NSMakeSize(2000, 36);
}

@end
