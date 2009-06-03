//
//  KTViewController.h
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

#import <Cocoa/Cocoa.h>
#import "KTViewProtocol.h"
#import "KTController.h"
#import "KTWindowController.h"

@class KTLayerController;

@interface KTViewController : NSViewController <KTController>
{
	@private
	KTWindowController *		wWindowController;
	NSMutableArray *			mSubcontrollers;
	NSMutableArray *			mTopLevelNibObjects;
	NSMutableArray *			mLayerControllers;
	BOOL						mHidden;
}

@property(nonatomic, assign) KTWindowController * windowController;
@property(nonatomic, readwrite, assign) BOOL hidden;

+ (id)viewControllerWithWindowController:(KTWindowController*)theWindowController;
- (id)initWithNibName:(NSString *)name bundle:(NSBundle *)bundle windowController:(KTWindowController *)windowController;
- (BOOL)loadNibNamed:(NSString*)theNibName bundle:(NSBundle*)theBundle;


#pragma mark View
//- (NSView<KTView>*)view;
//- (void)setView:(NSView<KTView>*)theView;

#pragma mark Subcontrollers
- (void)setSubcontrollers:(NSArray*)theSubcontrollers;
- (NSArray*)subcontrollers;
- (void)addSubcontroller:(KTViewController *)viewController;
- (void)removeSubcontroller:(KTViewController *)viewController;
- (void)removeAllSubcontrollers;

#pragma mark Layer Controllers
- (void)addLayerController:(KTLayerController*)theLayerController;
- (void)removeLayerController:(KTLayerController*)theLayerController;
- (NSArray*)layerControllers;

@end
