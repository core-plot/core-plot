//
//  BWTransparentButton.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "BWTransparentButton.h"

@implementation BWTransparentButton

+ (Class)cellClass
{
	return [BWTransparentButtonCell class];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	// Fail gracefully on non-keyed coders
	if (![decoder isKindOfClass:[NSKeyedUnarchiver class]])
		return [super initWithCoder:decoder];
	
	NSKeyedUnarchiver *coder = (NSKeyedUnarchiver *)decoder;
	Class oldClass = [[self superclass] cellClass];
	Class newClass = [[self class] cellClass];
	
	[coder setClass:newClass forClassName:NSStringFromClass(oldClass)];
	self = [super initWithCoder:coder];
	[coder setClass:oldClass forClassName:NSStringFromClass(oldClass)];
	
	return self;
}

@end
