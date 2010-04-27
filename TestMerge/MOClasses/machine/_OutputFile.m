// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputFile.m instead.

#import "_OutputFile.h"

@implementation OutputFileID
@end

@implementation _OutputFile

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OutputFile" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OutputFile";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OutputFile" inManagedObjectContext:moc_];
}

- (OutputFileID*)objectID {
	return (OutputFileID*)[super objectID];
}




@dynamic path;






@dynamic group;

	



@end
