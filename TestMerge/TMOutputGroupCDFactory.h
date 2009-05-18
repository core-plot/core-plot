//
//  TMOutputGroupCDFactory.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMOutputSorter.h"

@interface TMOutputGroupCDFactory : NSObject <TMOutputGroupFactory> {
    NSManagedObjectContext *context;
}

@property (retain,readwrite) NSManagedObjectContext *context;

@end
