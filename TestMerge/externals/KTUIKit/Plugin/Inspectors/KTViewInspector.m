//
//  KTViewInspector.m
//  KTUIKit
//
//  Created by Cathy Shive on 11/1/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KTViewInspector.h"
#import <KTUIKit/KTView.h>

@implementation KTViewInspector

- (NSString *)viewNibName 
{
    return @"KTViewInspector";
}

+ (BOOL)supportsMultipleObjectInspection
{
	return NO;
}

- (void)refresh 
{
	NSArray *	anInspectedObjectsList = [self inspectedObjects];
	KTView *    anInspectedView = [anInspectedObjectsList objectAtIndex:0];
	[oLabelTextField setStringValue:[anInspectedView label]];
	[super refresh];
}

- (IBAction)setLabel:(id)theSender
{
	NSString *	aLabel = [theSender stringValue];
	NSArray *	anInspectedObjectsList = [self inspectedObjects];
	KTView *	anInspectedView = [anInspectedObjectsList objectAtIndex:0];
	[anInspectedView setLabel:aLabel];

}

@end
