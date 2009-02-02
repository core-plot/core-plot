//
//  CPGraphView.h
//  CorePlot
//
//  Created by Dirkjan Krijnders on 1/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CorePlot/CPGraph.h"

@interface CPGraphView : NSView {
	CPGraph* graphLayer;
	IBOutlet NSArrayController* dataSource;
}

@end
