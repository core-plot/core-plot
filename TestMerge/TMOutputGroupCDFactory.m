//
//  TMOutputGroupCDFactory.m
//  TestMerge
//
//  Created by Barry Wark on 5/18/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//

#import "TMOutputGroupCDFactory.h"
#import "GTMDefines.h"

@implementation TMOutputGroupCDFactory
@synthesize context;

- (void)dealloc {
    [context release];
    
    [super dealloc];
}


- (id)initWithManagedObjectContext:(NSManagedObjectContext*)moc {
    if((self = [super init])) {
        context = [moc retain];
    }
    
    return self;
}

- (id<TMOutputGroup>)groupWithName:(NSString*)name extension:(NSString*)extension {
    NSManagedObject<TMOutputGroup> *result;
    
    NSFetchRequest *fetch = [self.context.persistentStoreCoordinator.managedObjectModel fetchRequestFromTemplateWithName:@"namedGroup"
                             substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                                    name, @"NAME",
                                                    extension, @"EXTENSION",
                                                    nil]];
    
    NSError *err;
    
    NSArray *existingGroups = [[self context] executeFetchRequest:fetch error:&err];
    _GTMDevAssert(existingGroups.count <= 1, @"More than one group with given name");
    
    if(existingGroups.count > 0) {
        result = [existingGroups lastObject];
    } else {
        result = [NSEntityDescription insertNewObjectForEntityForName:@"OutputGroup"
                                               inManagedObjectContext:[self context]];
        
        result.name = name;
        result.extension = extension;
        
        if(![[self context] save:&err]) {
            [NSApp presentError:err];
        }
    }
    
    
    return result;
}
@end
