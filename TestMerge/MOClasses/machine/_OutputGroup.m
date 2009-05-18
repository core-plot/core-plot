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




- (NSString*)referencePath {
	[self willAccessValueForKey:@"referencePath"];
	NSString *result = [self primitiveValueForKey:@"referencePath"];
	[self didAccessValueForKey:@"referencePath"];
	return result;
}

- (void)setReferencePath:(NSString*)value_ {
	[self willChangeValueForKey:@"referencePath"];
	[self setPrimitiveValue:value_ forKey:@"referencePath"];
	[self didChangeValueForKey:@"referencePath"];
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






- (NSNumber*)type {
	[self willAccessValueForKey:@"type"];
	NSNumber *result = [self primitiveValueForKey:@"type"];
	[self didAccessValueForKey:@"type"];
	return result;
}

- (void)setType:(NSNumber*)value_ {
	[self willChangeValueForKey:@"type"];
	[self setPrimitiveValue:value_ forKey:@"type"];
	[self didChangeValueForKey:@"type"];
}



- (short)typeValue {
	NSNumber *result = [self type];
	return result ? [result shortValue] : 0;
}

- (void)setTypeValue:(short)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}






- (NSDate*)date {
	[self willAccessValueForKey:@"date"];
	NSDate *result = [self primitiveValueForKey:@"date"];
	[self didAccessValueForKey:@"date"];
	return result;
}

- (void)setDate:(NSDate*)value_ {
	[self willChangeValueForKey:@"date"];
	[self setPrimitiveValue:value_ forKey:@"date"];
	[self didChangeValueForKey:@"date"];
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






@end
