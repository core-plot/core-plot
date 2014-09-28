//
//  Plot_Gallery_MacAppDelegate.h
//  CorePlotGallery
//
//  Created by Jeff Buck on 9/5/10.
//  Copyright 2010 Jeff Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Plot_Gallery_MacAppDelegate : NSObject<NSApplicationDelegate>
{
    @private
    NSWindow *window;
}

@property (strong) IBOutlet NSWindow *window;

@end
