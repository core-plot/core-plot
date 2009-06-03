//
//  KTWindowController.m
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

#import "KTWindowController.h"
#import "KTViewController.h"

@implementation KTWindowController

//=========================================================== 
// - initWithWindowNibName:
//=========================================================== 
- (id)initWithWindowNibName:(NSString *)theNibName;
{
	if (![super initWithWindowNibName:theNibName])
		return nil;
	
	mViewControllers = [[NSMutableArray alloc] init];
	return self;
}



//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{
	[mViewControllers release];
	[super dealloc];
}



//=========================================================== 
// - setViewControllers
//=========================================================== 
- (void)windowWillClose:(NSNotification *)theNotification
{
	/*CS: I don't know if we want to actually do this in the framework
	it only really truely works if the view controllers are actually released when the window closes
	and they are re-initialized when the window is created.  You might have a window that you want
	to open and close without releasing the controllers/views.  In this case, we would have the
	controllers remove all their observations or bindings when the window closes and we don't have a way or hook to re-establish
	the observations/bindings when the window opens again - needs to be balanced*/
	//[[self viewControllers] makeObjectsPerformSelector:@selector(removeObservations)];
}


//=========================================================== 
// - setViewControllers
//=========================================================== 
- (void)setViewControllers:(NSArray *)theViewControllers
{
	if(mViewControllers != theViewControllers)
	{
		NSMutableArray * aNewViewControllers = [theViewControllers mutableCopy];
		[mViewControllers release];
		mViewControllers = aNewViewControllers;
	}
}



//=========================================================== 
// - viewControllers
//=========================================================== 
- (NSArray*)viewControllers
{
	return mViewControllers;
}



//=========================================================== 
// - addViewController:
//=========================================================== 
- (void)addViewController:(KTViewController *)theViewController
{
	[mViewControllers addObject:theViewController];
	[self patchResponderChain];
}



//=========================================================== 
// - removeViewController:
//=========================================================== 
- (void)removeViewController:(KTViewController *)theViewController
{
	[mViewControllers removeObject:theViewController];
	[self patchResponderChain];
}



//=========================================================== 
// - removeAllViewControllers
//=========================================================== 
- (void)removeAllViewControllers
{
	[mViewControllers removeAllObjects];
}



//=========================================================== 
// - patchResponderChain
//=========================================================== 
- (void)patchResponderChain
{

	NSMutableArray * aFlatViewControllersList = [NSMutableArray array];
	for (KTViewController * aViewController in mViewControllers) { // flatten the view controllers into an array
		if([aViewController hidden]==NO)
		{
			[aFlatViewControllersList addObject:aViewController];
			[aFlatViewControllersList addObjectsFromArray:[aViewController descendants]];
		}
	}
	
	if([aFlatViewControllersList count]>0)
	{
		[self setNextResponder:[aFlatViewControllersList objectAtIndex:0]];
		NSUInteger i = 0;
		NSUInteger viewControllerCount = [aFlatViewControllersList count] - 1;
		for (i = 0; i < viewControllerCount ; i++) 
		{ 
			// set the next responder of each controller to the next, the last in the array has no next responder.
			[[aFlatViewControllersList objectAtIndex:i] setNextResponder:[aFlatViewControllersList objectAtIndex:i + 1]];
		}
		[[aFlatViewControllersList lastObject] setNextResponder:nil];
	}
}


@end