// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OutputGroup.h instead.

#import <CoreData/CoreData.h>



@interface OutputGroupID : NSManagedObjectID {}
@end

@interface _OutputGroup : NSManagedObject {}
+ (id)newInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OutputGroupID*)objectID;



- (NSString*)referencePath;
- (void)setReferencePath:(NSString*)value_;
#if defined(MAC_OS_X_VERSION_10_5) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
@property (retain) NSString *referencePath;
#endif

//- (BOOL)validateReferencePath:(id*)value_ error:(NSError**)error_;



- (NSString*)outputPath;
- (void)setOutputPath:(NSString*)value_;
#if defined(MAC_OS_X_VERSION_10_5) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
@property (retain) NSString *outputPath;
#endif

//- (BOOL)validateOutputPath:(id*)value_ error:(NSError**)error_;



- (NSString*)name;
- (void)setName:(NSString*)value_;
#if defined(MAC_OS_X_VERSION_10_5) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
@property (retain) NSString *name;
#endif

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



- (NSString*)extension;
- (void)setExtension:(NSString*)value_;
#if defined(MAC_OS_X_VERSION_10_5) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
@property (retain) NSString *extension;
#endif

//- (BOOL)validateExtension:(id*)value_ error:(NSError**)error_;



- (NSString*)failureDiffPath;
- (void)setFailureDiffPath:(NSString*)value_;
#if defined(MAC_OS_X_VERSION_10_5) && MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
@property (retain) NSString *failureDiffPath;
#endif

//- (BOOL)validateFailureDiffPath:(id*)value_ error:(NSError**)error_;



@end
