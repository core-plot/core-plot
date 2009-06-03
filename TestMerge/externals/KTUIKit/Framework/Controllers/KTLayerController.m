//
//  KTOpenGLLayerController.m
//  KTUIKit
//
//  Created by Cathy on 27/02/2009.
//  Copyright 2009 Sofa. All rights reserved.
//

#import "KTLayerController.h"
#import "KTViewController.h"
#import "KTWindowController.h"

@implementation KTLayerController

//=========================================================== 
// synthesized properties
//===========================================================
@synthesize viewController = wViewController;
@synthesize subcontrollers = mSubcontrollers;
@synthesize representedObject = wRepresentedObject;
@synthesize layer = mLayer;


//=========================================================== 
// - layerControllerWithViewController
//===========================================================
+ (id)layerControllerWithViewController:(KTViewController*)theViewController
{
	return [[[self alloc] initWithViewController:theViewController] autorelease];
}


//=========================================================== 
// - initWithViewController
//===========================================================
- (id)initWithViewController:(KTViewController*)theViewController
{
	if(self = [super init])
	{
		wViewController = theViewController;
	}
	return self;
}

//=========================================================== 
// - dealloc
//===========================================================
- (void)dealloc
{
	[mSubcontrollers release];
	[mLayer release];
	[super dealloc];
}

//=========================================================== 
// - setRepresentedObject
//===========================================================
- (void)setRepresentedObject:(id)theRepresentedObject
{
	wRepresentedObject = theRepresentedObject;
}


//=========================================================== 
// - removeObservations
//===========================================================
- (void)removeObservations
{
	[mSubcontrollers makeObjectsPerformSelector:@selector(removeObservations)];
}


//=========================================================== 
// - addSubcontroller
//===========================================================
- (void)addSubcontroller:(KTLayerController*)theSubcontroller
{
	[mSubcontrollers addObject:theSubcontroller];
	[[[self viewController] windowController] patchResponderChain];
}

//=========================================================== 
// - removeSubcontroller
//===========================================================
- (void)removeSubcontroller:(KTLayerController*)theSubcontroller
{
	[mSubcontrollers removeObject:theSubcontroller];
	[[[self viewController] windowController] patchResponderChain];
}


#pragma mark Controller Responder Chain Protocol
//=========================================================== 
// - descendants
//===========================================================
- (NSArray *)descendants
{
	NSMutableArray * anArray = [NSMutableArray array];
	for(KTLayerController * aLayerController in mSubcontrollers)
	{
		[anArray addObject:aLayerController];
		if([[aLayerController subcontrollers] count] > 0)
			[anArray addObjectsFromArray:[aLayerController descendants]];
	}
	return [[anArray copy] autorelease]; // return an immutable array
}

@end


