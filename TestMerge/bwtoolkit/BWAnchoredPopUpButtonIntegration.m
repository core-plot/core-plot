//
//  BWAnchoredPopUpButtonIntegration.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import <InterfaceBuilderKit/InterfaceBuilderKit.h>
#import "BWAnchoredPopUpButton.h"

@implementation BWAnchoredPopUpButton ( BWAnchoredPopUpButtonIntegration )

- (NSSize)ibMinimumSize
{
	return NSMakeSize(0,24);
}

- (NSSize)ibMaximumSize
{
	return NSMakeSize(100000,24);
}

- (IBInset)ibLayoutInset
{
	IBInset inset;
	inset.bottom = 0;
	inset.right = 0;
	inset.top = topAndLeftInset.x;
	inset.left = topAndLeftInset.y;
	
	return inset;
}

- (int)ibBaselineCount
{
	return 1;
}

- (float)ibBaselineAtIndex:(int)index
{
	return 16;
}

@end
