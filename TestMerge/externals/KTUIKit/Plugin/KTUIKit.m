//
//  KTUIKit.m
//  KTUIKit
//
//  Created by Cathy Shive on 5/25/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KTUIKit.h"

@implementation KTUIKit
- (NSString *)label
{
	return @"KATI";
}

- (NSArray *)libraryNibNames 
{
    return [NSArray arrayWithObject:@"KTUIKitLibrary"];
}

- (NSArray *)requiredFrameworks
{
	return [NSArray arrayWithObjects:[NSBundle bundleWithIdentifier:@"com.katidev.KTUIKit"], nil];
}

@end
