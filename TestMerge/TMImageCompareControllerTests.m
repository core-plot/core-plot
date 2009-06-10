//
//  TMImageCompareControllerTests.m
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "TMImageCompareControllerTests.h"
#import "TMImageCompareController.h"

#import "GTMNSObject+UnitTesting.h"
#import "GTMNSObject+BindingUnitTesting.h"

@implementation TMImageCompareControllerTests
@synthesize controller;

- (void)setUp {
    self.controller = [[[NSViewController alloc] initWithNibName:@"ImageCompareView" bundle:[NSBundle mainBundle]] autorelease];
}

- (void)tearDown {
    self.controller = nil;
}

- (void)testBindings {
    GTMDoExposedBindingsFunctionCorrectly(self.controller, NULL);
}

@end
