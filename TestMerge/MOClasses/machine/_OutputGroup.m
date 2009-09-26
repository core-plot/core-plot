// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputGroup.m instead.

#import "_OutputGroup.h"

@implementation OutputGroupID
@end

@implementation _OutputGroup

+ (id)newInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	return [NSEntityDescription insertNewObjectForEntityForName:@"OutputGroup" inManagedObjectContext:moc_];									 
}

- (OutputGroupID*)objectID {
	return (OutputGroupID*)[super objectID];
}




- (NSString*)name {
	[self willAccessValueForKey:@"name"];
	NSString *result = [self primitiveValueForKey:@"name"];
	[self didAccessValueForKey:@"name"];
	return result;
}

- (void)setName:(NSString*)value_ {
	[self willChangeValueForKey:@"name"];
	[self setPrimitiveValue:value_ forKey:@"name"];
	[self didChangeValueForKey:@"name"];
}






- (NSNumber*)replaceReference {
	[self willAccessValueForKey:@"replaceReference"];
	NSNumber *result = [self primitiveValueForKey:@"replaceReference"];
	[self didAccessValueForKey:@"replaceReference"];
	return result;
}

- (void)setReplaceReference:(NSNumber*)value_ {
	[self willChangeValueForKey:@"replaceReference"];
	[self setPrimitiveValue:value_ forKey:@"replaceReference"];
	[self didChangeValueForKey:@"replaceReference"];
}



- (BOOL)replaceReferenceValue {
	NSNumber *result = [self replaceReference];
	return result ? [result boolValue] : 0;
}

- (void)setReplaceReferenceValue:(BOOL)value_ {
	[self setReplaceReference:[NSNumber numberWithBool:value_]];
}






- (NSString*)failureDiffPath {
	[self willAccessValueForKey:@"failureDiffPath"];
	NSString *result = [self primitiveValueForKey:@"failureDiffPath"];
	[self didAccessValueForKey:@"failureDiffPath"];
	return result;
}

- (void)setFailureDiffPath:(NSString*)value_ {
	[self willChangeValueForKey:@"failureDiffPath"];
	[self setPrimitiveValue:value_ forKey:@"failureDiffPath"];
	[self didChangeValueForKey:@"failureDiffPath"];
}






- (NSString*)outputPath {
	[self willAccessValueForKey:@"outputPath"];
	NSString *result = [self primitiveValueForKey:@"outputPath"];
	[self didAccessValueForKey:@"outputPath"];
	return result;
}

- (void)setOutputPath:(NSString*)value_ {
	[self willChangeValueForKey:@"outputPath"];
	[self setPrimitiveValue:value_ forKey:@"outputPath"];
	[self didChangeValueForKey:@"outputPath"];
}






- (NSString*)extension {
	[self willAccessValueForKey:@"extension"];
	NSString *result = [self primitiveValueForKey:@"extension"];
	[self didAccessValueForKey:@"extension"];
	return result;
}

- (void)setExtension:(NSString*)value_ {
	[self willChangeValueForKey:@"extension"];
	[self setPrimitiveValue:value_ forKey:@"extension"];
	[self didChangeValueForKey:@"extension"];
}






	

- (NSSet*)referenceFiles {
	[self willAccessValueForKey:@"referenceFiles"];
	NSSet *result = [self primitiveValueForKey:@"referenceFiles"];
	[self didAccessValueForKey:@"referenceFiles"];
	return result;
}

- (void)setReferenceFiles:(NSSet*)value_ {
	[self willChangeValueForKey:@"referenceFiles"];
	[self setPrimitiveValue:value_ forKey:@"referenceFiles"];
	[self didChangeValueForKey:@"referenceFiles"];
}

- (void)addReferenceFiles:(NSSet*)value_ {
	[self willChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value_];
	[[self primitiveValueForKey:@"referenceFiles"] unionSet:value_];
	[self didChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value_];
}

-(void)removeReferenceFiles:(NSSet*)value_ {
	[self willChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value_];
	[[self primitiveValueForKey:@"referenceFiles"] minusSet:value_];
	[self didChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value_];
}
	
- (void)addReferenceFilesObject:(OutputFile*)value_ {
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value_ count:1];
	[self willChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
	[[self primitiveValueForKey:@"referenceFiles"] addObject:value_];
	[self didChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
	[changedObjects release];
}

- (void)removeReferenceFilesObject:(OutputFile*)value_ {
	NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value_ count:1];
	[self willChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
	[[self primitiveValueForKey:@"referenceFiles"] removeObject:value_];
	[self didChangeValueForKey:@"referenceFiles" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
	[changedObjects release];
}

- (NSMutableSet*)referenceFilesSet {
	return [self mutableSetValueForKey:@"referenceFiles"];
}
	

@end
