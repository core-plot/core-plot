//
//  TMOutputFactory.h
//  TestMerge
//
//  Created by Barry Wark on 5/27/09.
//  Copyright 2009 Barry Wark. All rights reserved.
//


#import "TMOutputGroup.h"

@protocol TMOutputGroupFactory <NSObject>

/**
 id<TMOutputGroup> with given name and extension. If such a group already exists,
 it is returned. Otherwise a new group is created.
 
 @return Autoreleased id<TMOutputGroup> with given name and extension.
 */
- (id<TMOutputGroup>)groupWithName:(NSString*)name extension:(NSString*)extension;

@end
