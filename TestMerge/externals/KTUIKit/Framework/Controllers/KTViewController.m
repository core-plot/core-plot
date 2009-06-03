//
//  KTViewController.m
//  View Controllers
//
//  Created by Jonathan Dann and Cathy Shive on 14/04/2008.
//
// Copyright (c) 2008 Jonathan Dann and Cathy Shive
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// If you use it, acknowledgement in an About Page or other appropriate place would be nice.
// For example, "Contains "View Controllers" by Jonathan Dann and Cathy Shive" will do.


/*
	(Cathy 11/10/08) NOTE:
	I've made the following changes that need to be documented:
	• When a child is removed, its view is removed from its superview and it is sent a "removeObservations" message
	• Added 'removeChild:(KTViewController*)theChild' method to remove specific subcontrollers
	• Added 'loadNibNamed' and 'releaseNibObjects' to support loading more than one nib per view controller.  These take care
	of releasing the top level nib objects for those nib files. Users have to unbind any bindings in those nibs in the view
	controller's removeObservations method.
	• Added class method, 'viewControllerWithWindowController'
	• I'm considering overriding 'view' and 'setView:' so that the view controller only deals with KTViews.
*/


#import "KTViewController.h"
#import "KTWindowController.h"
#import "KTLayerController.h"


@interface KTViewController (Private)
- (void)releaseNibObjects;
@end

@implementation KTViewController
//=========================================================== 
// - @synthesize
//=========================================================== 
@synthesize windowController = wWindowController;
@synthesize hidden = mHidden;


//=========================================================== 
// - viewControllerWithWindowController
//=========================================================== 
+ (id)viewControllerWithWindowController:(KTWindowController*)theWindowController
{
	return [[[self alloc] initWithNibName:nil bundle:nil windowController:theWindowController] autorelease];
}


//=========================================================== 
// - initWithNibName
//=========================================================== 
- (id)initWithNibName:(NSString *)theNibName bundle:(NSBundle *)theBundle windowController:(KTWindowController *)theWindowController;
{
	if (![super initWithNibName:theNibName bundle:theBundle])
		return nil;
	wWindowController = theWindowController;
	mSubcontrollers = [[NSMutableArray alloc] init];
	mTopLevelNibObjects = [[NSMutableArray alloc] init];
	mLayerControllers = [[NSMutableArray alloc] init];
	return self;
}

//=========================================================== 
// - initWithNibName
//=========================================================== 
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle
{
	[NSException raise:@"KTViewControllerException" format:[NSString stringWithFormat:@"An instance of an KTViewController concrete subclass was initialized using the NSViewController method -initWithNibName:bundle: all view controllers in the enusing tree will have no reference to an KTWindowController object and cannot be automatically added to the responder chain"]];
	return nil;
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{
	//NSLog(@"%@ dealloc", self);
	[self releaseNibObjects];
	[mSubcontrollers makeObjectsPerformSelector:@selector(removeObservations)];
	[mSubcontrollers release];
	[mLayerControllers makeObjectsPerformSelector:@selector(removeObservations)];
	[mLayerControllers release];
	[super dealloc];
}

//=========================================================== 
// - releaseNibObjects
//=========================================================== 
- (void)releaseNibObjects
{
	NSInteger i;
	for(i = 0; i < [mTopLevelNibObjects count]; i++)
	{
		[[mTopLevelNibObjects objectAtIndex:i] release];
	}
	[mTopLevelNibObjects release];
}


// CS: I wonder about this situation
// if the window controller changes, say a view controller is moved from one window to another
// it is important that the view controller has been removed from the old window controller
// and that that window controller has re-patched its responder chain
// otherwise it is possible that actions from the other window will get handled by a view controller
// that is no longer a part of that window
//=========================================================== 
// - setWindowController
//=========================================================== 
- (void)setWindowController:(KTWindowController*)theWindowController
{
	wWindowController = theWindowController;
	[[self subcontrollers] makeObjectsPerformSelector:@selector(setWindowController:) withObject:theWindowController];
	[[self windowController] patchResponderChain];
}


//=========================================================== 
// - setHidden
//=========================================================== 
- (void)setHidden:(BOOL)theBool
{
	mHidden = theBool;
	[[self windowController] patchResponderChain];
}



//#pragma mark -
//#pragma mark View
//- (NSView<KTView>*)view
//{
//	return (NSView<KTView>*)[super view];
//}
//
//- (void)setView:(NSView<KTView>*)theView
//{
//	[super setView:theView];
//}


#pragma mark Subcontrollers
//=========================================================== 
// - setSubcontrollers
//=========================================================== 
- (void)setSubcontrollers:(NSArray *)theSubcontrollers;
{
	if(mSubcontrollers != theSubcontrollers)
	{
		NSMutableArray * aNewSubcontrollers = [theSubcontrollers mutableCopy];
		[mSubcontrollers release];
		mSubcontrollers = aNewSubcontrollers;
		[[self windowController] patchResponderChain];
	}
}

//=========================================================== 
// - subcontrollers
//=========================================================== 
- (NSArray*)subcontrollers
{
	return mSubcontrollers;
}



//=========================================================== 
// - addSubcontroller
//=========================================================== 
- (void)addSubcontroller:(KTViewController *)theViewController;
{
	[mSubcontrollers addObject:theViewController];
	[[self windowController] patchResponderChain];
}



//=========================================================== 
// - removeSubcontroller
//=========================================================== 
- (void)removeSubcontroller:(KTViewController *)theViewController;
{
	[theViewController removeObservations];
	[mSubcontrollers removeObject:theViewController];
	[[self windowController] patchResponderChain];
}



//=========================================================== 
// - removeAllSubcontrollers
//=========================================================== 
- (void)removeAllSubcontrollers
{
	[self setSubcontrollers:[NSArray array]];
	[[self windowController] patchResponderChain];
}


#pragma mark Layer Controllers
//=========================================================== 
// - addLayerController
//=========================================================== 
- (void)addLayerController:(KTLayerController*)theLayerController
{
	[mLayerControllers addObject:theLayerController];
	[[self windowController] patchResponderChain];
}



//=========================================================== 
// - removeLayerController
//=========================================================== 
- (void)removeLayerController:(KTLayerController*)theLayerController
{
	[mLayerControllers removeObject:theLayerController];
	[[self windowController] patchResponderChain];
}



//=========================================================== 
// - layerControllers
//=========================================================== 
- (NSArray*)layerControllers
{
	return mLayerControllers;
}


//=========================================================== 
// - descendants
//=========================================================== 
- (NSArray *)descendants
{
	NSMutableArray *aDescendantsList = [[[NSMutableArray alloc] init] autorelease];
	
	for (KTViewController * aSubViewController in mSubcontrollers) 
	{
		if([aSubViewController hidden]==NO)
		{
			[aDescendantsList addObject:aSubViewController];
			if ([[aSubViewController subcontrollers] count] > 0)
				[aDescendantsList addObjectsFromArray:[aSubViewController descendants]];
		}
	}
	for(KTLayerController * aLayerController in mLayerControllers)
	{
		[aDescendantsList addObject:aLayerController];
		if([[aLayerController subcontrollers] count] > 0)
			[aDescendantsList addObjectsFromArray:[aLayerController descendants]];
	}
	return aDescendantsList;
}


//=========================================================== 
// - removeAllViewControllers
//=========================================================== 
- (void)removeObservations
{
	// subcontrollers
	[mSubcontrollers makeObjectsPerformSelector:@selector(removeObservations)];
	// layer controllers
	[mLayerControllers makeObjectsPerformSelector:@selector(removeObservations)];
}


//=========================================================== 
// - loadNibNamed:
//=========================================================== 
- (BOOL)loadNibNamed:(NSString*)theNibName bundle:(NSBundle*)theBundle
{
	BOOL		aSuccess;
	NSArray *	anObjectList = nil;
	NSNib *		aNib = [[[NSNib alloc] initWithNibNamed:theNibName bundle:theBundle] autorelease];
	aSuccess = [aNib instantiateNibWithOwner:self topLevelObjects:&anObjectList];
	if(aSuccess)
	{
		int i;
		for(i = 0; i < [anObjectList count]; i++)
			[mTopLevelNibObjects addObject:[anObjectList objectAtIndex:i]];
	}
	return aSuccess;
}

@end
