//
//  TMMergeController.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMMergeController.h"


@implementation TMMergeController
@synthesize referencePath;
@synthesize outputPath;

- (void)dealloc {
    [referencePath release];
    [outputPath release];
    
    [super dealloc];
}

@end
