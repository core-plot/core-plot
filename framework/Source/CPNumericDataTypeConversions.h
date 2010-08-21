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
