//
//  KTScrollViewIntegration.m
//  KTUIKit
//
//  Created by Cathy Shive on 11/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>

// Import your framework view and your inspector 
 #import <KTUIKit/KTScrollView.h>
 #import "KTLayoutManagerInspector.h"

@implementation KTScrollView ( KTScrollViewIntegration )

- (void)ibPopulateKeyPaths:(NSMutableDictionary *)keyPaths {
    [super ibPopulateKeyPaths:keyPaths];

	// Remove the comments and replace "MyFirstProperty" and "MySecondProperty" 
	// in the following line with a list of your view's KVC-compliant properties.
    [[keyPaths objectForKey:IBAttributeKeyPaths] addObjectsFromArray:[NSArray arrayWithObjects:/* @"MyFirstProperty", @"MySecondProperty",*/ nil]];
}

- (void)ibPopulateAttributeInspectorClasses:(NSMutableArray *)classes {
    [super ibPopulateAttributeInspectorClasses:classes];
	// Replace "KTScrollViewIntegrationInspector" with the name of your inspector class.
    [classes addObject:[KTLayoutManagerInspector class]];
}

@end
