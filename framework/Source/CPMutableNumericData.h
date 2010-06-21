#import <Foundation/Foundation.h>
#import "CPNumericDataType.h"
#import "CPNumericData.h"

@interface CPMutableNumericData : CPNumericData {
	
}

/// @name Data Buffer
/// @{
@property (readonly) void *mutableBytes;
///	@}

/// @name Dimensions
/// @{
@property (copy, readwrite) NSArray *shape;
///	@}

/// @name Factory Methods
/// @{
+(CPMutableNumericData *)numericDataWithData:(NSData *)newData
									dataType:(CPNumericDataType)newDataType
									   shape:(NSArray *)shapeArray;

+(CPMutableNumericData *)numericDataWithData:(NSData *)newData
							  dataTypeString:(NSString *)newDataTypeString
									   shape:(NSArray *)shapeArray;
///	@}

/// @name Initialization
/// @{
-(id)initWithData:(NSData *)newData
		 dataType:(CPNumericDataType)newDataType
            shape:(NSArray *)shapeArray;
///	@}

@end
