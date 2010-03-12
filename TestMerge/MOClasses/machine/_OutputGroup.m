// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputGroup.m instead.

#import "_OutputGroup.h"

@implementation OutputGroupID
@end

@implementation _OutputGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OutputGroup" inManagedObjectContext:moc_];
}

- (OutputGroupID*)objectID {
	return (OutputGroupID*)[super objectID];
}




@dynamic name;






@dynamic replaceReference;



- (BOOL)replaceReferenceValue {
	NSNumber *result = [self replaceReference];
	return result ? [result boolValue] : 0;
}

- (void)setReplaceReferenceValue:(BOOL)value_ {
	[self setReplaceReference:[NSNumber numberWithBool:value_]];
}






@dynamic failureDiffPath;






@dynamic outputPath;






@dynamic extension;






@dynamic referenceFiles;

	
- (NSMutableSet*)referenceFilesSet {
	[self willAccessValueForKey:@"referenceFiles"];
	NSMutableSet *result = [self mutableSetValueForKey:@"referenceFiles"];
	[self didAccessValueForKey:@"referenceFiles"];
	return result;
}
	




+ (NSArray*)fetchNamedGroup:(NSManagedObjectContext*)moc_ NAME:(NSString*)NAME_ EXTENSION:(NSString*)EXTENSION_ {
	NSError *error = nil;
	NSArray *result = [self fetchNamedGroup:moc_ NAME:NAME_ EXTENSION:EXTENSION_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchNamedGroup:(NSManagedObjectContext*)moc_ NAME:(NSString*)NAME_ EXTENSION:(NSString*)EXTENSION_ error:(NSError**)error_ {
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"namedGroup"
													 substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
														
														NAME_, @"NAME",
														
														EXTENSION_, @"EXTENSION",
														
														nil]
													 ];
	NSAssert(fetchRequest, @"Can't find fetch request named \"namedGroup\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchGroupsWithSelectedMerge:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *result = [self fetchGroupsWithSelectedMerge:moc_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchGroupsWithSelectedMerge:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"groupsWithSelectedMerge"
													 substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
														
														nil]
													 ];
	NSAssert(fetchRequest, @"Can't find fetch request named \"groupsWithSelectedMerge\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}



+ (NSArray*)fetchAllGroups:(NSManagedObjectContext*)moc_ {
	NSError *error = nil;
	NSArray *result = [self fetchAllGroups:moc_ error:&error];
	if (error) {
#if TARGET_OS_IPHONE
		NSLog(@"error: %@", error);
#else
		[NSApp presentError:error];
#endif
	}
	return result;
}
+ (NSArray*)fetchAllGroups:(NSManagedObjectContext*)moc_ error:(NSError**)error_ {
	NSError *error = nil;
	
	NSManagedObjectModel *model = [[moc_ persistentStoreCoordinator] managedObjectModel];
	NSFetchRequest *fetchRequest = [model fetchRequestFromTemplateWithName:@"allGroups"
													 substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
														
														nil]
													 ];
	NSAssert(fetchRequest, @"Can't find fetch request named \"allGroups\".");
	
	NSArray *result = [moc_ executeFetchRequest:fetchRequest error:&error];
	if (error_) *error_ = error;
	return result;
}


@end
