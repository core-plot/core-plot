#import <Foundation/Foundation.h>
#include <vector>
#include <memory>
#include <iterator>
#include <algorithm>
#include <functional>

using namespace std;

/**	@namespace coreplot
 *	@brief CPNumericData data conversion utility functions.
 **/
namespace coreplot {
	/** @brief A one-byte data type.
	 **/
    typedef char byte;
    
	/// @name Useful functions
	/// @{
    
    template<typename T>
    NSData *swap_numeric_data_byte_order(NSData *in); // usage: swap_numeric_data_byte_order<type>(data)
    
    template<typename T>
    void swap_numeric_data_byte_order(NSMutableData *in); //inplace swap for NSMutableData. usage: swap_numeric_data_byte_order<type>(data)
    
    template<typename InType, typename OutType>
    NSData *convert_numeric_data_type(NSData *in, CFByteOrder inByteOrder=NSHostByteOrder(), CFByteOrder outByteOrder=NSHostByteOrder()); //usage: newData = convert_numeric_data_type<InType,OutType>(inData, inByteOrder, outByteOrder)
    
    template<typename InputOutputIterator>
    void swap_byte_order(InputOutputIterator begin, 
                         InputOutputIterator end);
    
    ///	@}
	
	/// @name Less useful functions
	/// @{
    
    template<typename T, typename U>
    auto_ptr<vector<U> > convert_data_type(auto_ptr<vector<T> > in);
    
    template<typename T>
    auto_ptr<vector<T> > swap_vector_byte_order(auto_ptr<vector<T> > vptr);
    
    template<typename T>
    T __byteswap(T v);
    
    ///	@}
	
	/// @name Converting std::vector <-> NSData*
	/// @{
	
    template<typename T>
    auto_ptr<vector<T> > numeric_data_to_vector(NSData *d);
    
    template<typename T>
    NSData *vector_to_numeric_data(auto_ptr<vector<T> > v);
	
    ///	@}
}

#pragma mark -

/**	@brief Convert the type of elements in a numeric data array.
 *
 *	Each element in the input is converted (via C type-casting) to
 *	the desired output type. No warning is produced at run time if information
 *	will be lost by the type conversion (though a compiler warning is likely).
 *
 *	@param in NSData instance containing numeric data of uniform type.
 *	@param inByteOrder Endian order of the input data.
 *	@param outByteOrder Desired endian order of the output data.
 *	@tparam InType Type of the numeric data (e.g., <code>double</code>).
 *	@tparam OutType Type of the desired output data (e.g., <code>float</code>).
 *	@return NSData instance containing a copy of the input with all elements' type converted to OutType and endian order swapped if required to outByteOrder.
 **/
template<typename InType, typename OutType>
NSData *coreplot::convert_numeric_data_type(NSData *in, CFByteOrder inByteOrder=NSHostByteOrder(), CFByteOrder outByteOrder=NSHostByteOrder()) {
	// TODO: may need to convert to/from host byte order during conversion
	auto_ptr<vector<OutType> > outPtr(convert_data_type<InType,OutType>(numeric_data_to_vector<InType>(in)));
	if ( inByteOrder != outByteOrder ) {
		swap_byte_order(outPtr->begin(), outPtr->end());
	}
	
	return vector_to_numeric_data(outPtr);
}

/** @brief Swap the byte order of each element in a numeric array.
 *
 *	Swaps the endian byte order of each element. Obviously, the
 *	input should contain numeric data of the same type.
 *
 *	@param in NSData instance containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return NSData instance containing a copy of the input with all elements' endian order swapped.
 **/
template<typename T>
NSData *coreplot::swap_numeric_data_byte_order(NSData *in) {
	using namespace coreplot;
	return vector_to_numeric_data(swap_vector_byte_order(numeric_data_to_vector<T>(in)));
}

/** @brief Swap the byte order of each element in a numeric array in place.
 *
 *	Swaps the endian byte order of each element in place. Obviously, the
 *	input should contain numeric data of the same type.
 *
 *	@param in NSMutableData* containing numeric data of uniform type. The data will be swapped in-place.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 **/
template<typename T>
void coreplot::swap_numeric_data_byte_order(NSMutableData *in) {
	T *inPtr = (T*)[in mutableBytes];
	swap_byte_order(inPtr, inPtr+([in length]/sizeof(T)));
}

/** @brief Swap the byte order of each element in a vector.
 *	@param vptr A vector containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return A vector containing a copy of the input with all elements' endian order swapped.
 **/
template<typename T>
auto_ptr<vector<T> > coreplot::swap_vector_byte_order(auto_ptr<vector<T> > vptr) {
	swap_byte_order(vptr->begin(), vptr->end());
	return vptr;
}

/** @brief Convert the data type of each element in a vector.
 *	@param in A vector containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@tparam U Type of the desired output data (e.g., <code>float</code>).
 *	@return A vector containing a copy of the input with all elements converted to the new type.
 **/
template<typename T, typename U>
auto_ptr<vector<U> > coreplot::convert_data_type(auto_ptr<vector<T> > in) {
	return auto_ptr<vector<U> >(new vector<U>(in->begin(), in->end()));
}

/** @brief Swap the byte order of each element in a vector.
 *	@param begin The input iterator.
 *	@param end The output iterator.
 *	@tparam InputOutputIterator Type of the iterators.
 **/
template<typename InputOutputIterator>
void coreplot::swap_byte_order(InputOutputIterator begin, 
							   InputOutputIterator end) {
	transform(begin, end, begin, pointer_to_unary_function<typename iterator_traits<InputOutputIterator>::value_type,
			  typename iterator_traits<InputOutputIterator>::value_type> (coreplot::__byteswap));
}

/** @brief Swap the byte order of a numeric value.
 *	@param v A numeric value.
 *	@tparam T Type of the numeric value (e.g., <code>double</code>).
 *	@return The numeric value with its byte order reversed.
 **/
template<typename T>
T coreplot::__byteswap(T v) {
	assert(sizeof(coreplot::byte)==1);
	coreplot::byte *vbytes = (coreplot::byte*)&v;
	reverse(vbytes, vbytes+sizeof(T));
	return v;
}

/** @brief Converts a data buffer containing numeric data of uniform type to a vector.
 *	@param d An NSData instance containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return A vector containing the numeric data from the data buffer.
 **/
template<typename T>
auto_ptr<vector<T> > coreplot::numeric_data_to_vector(NSData *d) {
	auto_ptr<vector<T> > vptr(new vector<T>((T*)[d bytes], (T*)((T*)[d bytes]+([d length]/sizeof(T)))));
	
	return vptr;
}

/** @brief Converts a vector containing numeric data of uniform type to a data buffer.
 *	@param vptr A vector containing numeric data of uniform type.
 *	@tparam T Type of the numeric data (e.g., <code>double</code>).
 *	@return An NSData instance containing the numeric data from the vector.
 **/
template<typename T>
NSData *coreplot::vector_to_numeric_data(auto_ptr<vector<T> > vptr) {
	vector<T>& v = *vptr;
	NSData *result = [[NSData alloc] initWithBytes:&v[0] length:v.size()*sizeof(T)];
	
	return [result autorelease];
}
