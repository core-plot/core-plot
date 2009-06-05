// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputFile.m instead.

#import "_OutputFile.h"

@implementation OutputFileID
@end

@implementation _OutputFile

+ (id)newInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	return [NSEntityDescription insertNewObjectForEntityForName:@"OutputFile" inManagedObjectContext:moc_];									 
}

- (OutputFileID*)objectID {
	return (OutputFileID*)[super objectID];
}




- (NSString*)path {
	[self willAccessValueForKey:@"path"];
	NSString *result = [self primitiveValueForKey:@"path"];
	[self didAccessValueForKey:@"path"];
	return result;
}

- (void)setPath:(NSString*)value_ {
	[self willChangeValueForKey:@"path"];
	[self setPrimitiveValue:value_ forKey:@"path"];
	[self didChangeValueForKey:@"path"];
}






	

- (OutputGroup*)group {
	[self willAccessValueForKey:@"group"];
	OutputGroup *result = [self primitiveValueForKey:@"group"];
	[self didAccessValueForKey:@"group"];
	return result;
}

- (void)setGroup:(OutputGroup*)value_ {
	[self willChangeValueForKey:@"group"];
	[self setPrimitiveValue:value_ forKey:@"group"];
	[self didChangeValueForKey:@"group"];
}

	

@end
