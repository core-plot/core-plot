#import <Foundation/Foundation.h>
#include <vector>
#include <memory>
#include <iterator>
#include <algorithm>
#include <functional>

using namespace std;

namespace coreplot {
    typedef char byte;
    
    /*!
     @functiongroup Useful functions
     */
    
    
    /*!
	 @function
	 @abstract   Swap the byte order of each element in a numeric array
	 @discussion Swaps the endian byte order of each element. Obviously, the
     input should contain numeric data of the same type.
	 @param      in NSData* containing numeric data of uniform type.
	 @result     NSData* containing a copy of the input with all elements' endian
     order swapped.
	 @templatefield T Type of the numeric data (e.g. double)
     */
	
    template<typename T>
    NSData *swap_numeric_data_byte_order(NSData *in); // usage: swap_numeric_data_byte_order<type>(data)
    
    /*!
     @function
     @abstract   Swap the byte order of each element in a numeric array in place.
     @discussion Swaps the endian byte order of each element in place. Obviously, the
     input should contain numeric data of the same type.
     @param      in NSMutableData* containing numeric data of uniform type. The data
     will be swapped in-place.
     @templatefield T Type of the numeric data (e.g. double)
     */
    template<typename T>
    void swap_numeric_data_byte_order(NSMutableData *in); //inplace swap for NSMutableData. usage: swap_numeric_data_byte_order<type>(data)
    
    
    /*!
     @function
     @abstract   Convert the type of elements in a numeric data array.
     @discussion Each element in the input is converted (via C type-casting) to
     the desired output type. No warning is produced at run time if information
     will be lost by the type conversion (though a compiler warning is likely).
     @param in NSData* containing numeric data of uniform type.
     @param inByteOrder Endian order of the input data.
     @param outByteOrder Desired endian order of the output data.
     @result     NSData* containing a copy of the input with all elements' type
     converted to OutType and endian order swapped if required to outByteOrder.
     @templatefield InType Type of the numeric data (e.g. double)
     @templatefield OutType Type of the desired output data (e.g. float)
     */
    template<typename InType, typename OutType>
    NSData *convert_numeric_data_type(NSData *in, CFByteOrder inByteOrder=NSHostByteOrder(), CFByteOrder outByteOrder=NSHostByteOrder()); //usage: newData = convert_numeric_data_type<InType,OutType>(inData, inByteOrder, outByteOrder)
    
    template<typename InputOutputIterator>
    void swap_byte_order(InputOutputIterator begin, 
                         InputOutputIterator end);
    
    
    /*!
     @functiongruop Less useful functions
     */
    
    
    template<typename T, typename U>
    auto_ptr<vector<U> > convert_data_type(auto_ptr<vector<T> > in);
    
    template<typename T>
    auto_ptr<vector<T> > swap_vector_byte_order(auto_ptr<vector<T> > vptr);
    
    template<typename T>
    T __byteswap(T v);
    
    /*!
     @functiongroup Converting std::vector <-> NSData*
     */
    template<typename T>
    auto_ptr<vector<T> > numeric_data_to_vector(NSData *d);
    
    template<typename T>
    NSData *vector_to_numeric_data(auto_ptr<vector<T> > v);
}


template<typename InType, typename OutType>
NSData *coreplot::convert_numeric_data_type(NSData *in, CFByteOrder inByteOrder=NSHostByteOrder(), CFByteOrder outByteOrder=NSHostByteOrder()) {
    auto_ptr<vector<OutType> > outPtr(convert_data_type<InType,OutType>(numeric_data_to_vector<InType>(in)));
    if(inByteOrder != outByteOrder) {
        swap_byte_order(outPtr->begin(), outPtr->end());
    }
    
    return vector_to_numeric_data(outPtr);
}

template<typename T>
NSData *coreplot::swap_numeric_data_byte_order(NSData *in) {
    using namespace coreplot;
    return vector_to_numeric_data(swap_vector_byte_order(numeric_data_to_vector<T>(in)));
}


template<typename T>
void coreplot::swap_numeric_data_byte_order(NSMutableData *in) {
    T *inPtr = (T*)[in mutableBytes];
    swap_byte_order(inPtr, inPtr+([in length]/sizeof(T)));
}

template<typename T>
auto_ptr<vector<T> > coreplot::swap_vector_byte_order(auto_ptr<vector<T> > vptr) {
    swap_byte_order(vptr->begin(), vptr->end());
    return vptr;
}

template<typename T, typename U>
auto_ptr<vector<U> > coreplot::convert_data_type(auto_ptr<vector<T> > in) {
    return auto_ptr<vector<U> >(new vector<U>(in->begin(), in->end()));
}

template<typename InputOutputIterator>
void coreplot::swap_byte_order(InputOutputIterator begin, 
							   InputOutputIterator end) {
    transform(begin, end, begin, pointer_to_unary_function<typename iterator_traits<InputOutputIterator>::value_type,
              typename iterator_traits<InputOutputIterator>::value_type> (coreplot::__byteswap));
}

template<typename T>
T coreplot::__byteswap(T v) {
    assert(sizeof(coreplot::byte)==1);
    coreplot::byte *vbytes = (coreplot::byte*)&v;
    reverse(vbytes, vbytes+sizeof(T));
    return v;
}

template<typename T>
auto_ptr<vector<T> > coreplot::numeric_data_to_vector(NSData *d) {
    auto_ptr<vector<T> > vptr(new vector<T>((T*)[d bytes], (T*)((T*)[d bytes]+([d length]/sizeof(T)))));
    
    return vptr;
}

template<typename T>
NSData *coreplot::vector_to_numeric_data(auto_ptr<vector<T> > vptr) {
    vector<T>& v = *vptr;
    NSData *result = [[NSData alloc] initWithBytes:&v[0] length:v.size()*sizeof(T)];
    
    return [result autorelease];
}
