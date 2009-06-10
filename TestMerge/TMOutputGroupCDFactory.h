//
//  TMOutputGroupCDFactory.h
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Physion Consulting LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TMOutputGroupFactory.h"

extern NSString * const TMOutputGroupCDFactoryTooManyGroupsException;

/**
 Implementation of the TMOutputGroupFactory protocol that builds output groups
 as Core Data OutputGroup instances.
 */

@interface TMOutputGroupCDFactory : NSObject <TMOutputGroupFactory> {
    NSManagedObjectContext *context;
}

@property (retain,readwrite) NSManagedObjectContext *context;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)moc;

@end
