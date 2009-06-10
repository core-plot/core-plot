//
//  TMImageCompareControllerTests.h
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import "GTMSenTestCase.h"

@class TMImageCompareController;

@interface TMImageCompareControllerTests : GTMTestCase {
    TMImageCompareController *controller;
}

@property (retain,readwrite) TMImageCompareController *controller;
@end
