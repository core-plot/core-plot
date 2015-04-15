Core Plot Coding Standards
==========================

Everyone has a their own preferred coding style, and no one way can be considered right. Nonetheless, in a project like Core Plot, with many developers contributing, it is worthwhile defining a set of basic coding standards, in order to prevent a mishmash of different styles arising, which can become frustrating when navigating the code base. This document defines the standards to which code in Core Plot should conform.

Naming
------
Standard naming conventions are used throughout Core Plot, with the 'CPT' prefix used to avoid conflicts with other frameworks.

As is typical in Cocoa, mixed case is used for identifiers, with classes beginning with a uppercase letter (e.g., `CPTPlot`, `CPTDecimalNumberValueTransformer`), and variables beginning with a lowercase letter (e.g., `plot`, `newTransformer`). Functions should begin with an uppercase letter (e.g., `CPTDecimalFromInt`), and constants should begin with the prefix 'kCPT' (e.g., `kCPTAxisExtent`).

Curly Brackets
--------------
There are many different ways to indent code in C. In Core Plot, two different styles are used, based on the context, in line with Apple's own coding conventions.

When declaring the interface of a class, curly brackets occur at the end of the first line, and on a separate line after all instance variables have been declared. All declarations inside the block are indented.

    @interface CPTGraph : CPTLayer {
        CPTAxisSet *axisSet;
        CPTPlotArea *plotArea;
        NSMutableArray *plots;
        NSMutableArray *plotSpaces;
    	CPTFill *fill;
    }
    
In defining a function or method, both curly brackets are isolated on a line.

    -(CPTPlot *)plotWithIdentifier:(id <NSCopying>)identifier 
    {
    	...
    }
    
In all other uses (e.g., `for` loops, `if` statements), the first bracket is at the end of the first line in the block.

    for (CPTPlot *plot in plots) {
        if ( [[plot identifier] isEqual:identifier] ) return plot;
    }
    
Whenever a block spans more than one line, curly brackets should be used to avoid potentially introducing scoping bugs. For example, this statement is a single line, and does not need brackets

    if ( [[plot identifier] isEqual:identifier] ) return plot;

but if the `return` statement were to be added to the next line, curly brackets should be included

    if ( [[plot identifier] isEqual:identifier] ) {
        return plot;
    }

Indentation
-----------
Indentation of blocks of code follows the default Xcode standard of 4 spaces. 

When a method call is very long, spanning several lines, no new line characters should be inserted, unless this is for the purpose of making data appear in tabular form. Instead, the Xcode editor can be configured to perform code wrapping, with appropriate indentation.

For example, this is acceptable

    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"one",     [NSNumber numberWithInt:1],
        @"two",     [NSNumber numberWithInt:2],
        @"three",   [NSNumber numberWithInt:3],
        nil];

but the following is not

    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"one"
        forKey:[NSNumber numberWithInt:1]];

because the developer has inserted a new line rather than letting Xcode do the wrapping.

Whitespace
----------
Whitespace is used sparingly in method naming. Rather than this

    - (id) initWithString:(NSString*)newString length:(NSUInteger)newLength;
    
in Core Plot, the following should be used

    -(id)initWithString:(NSString *)newString length:(NSUInteger)newLength;
    
The example above shows that a space *is* used before any pointer-delimiting asterisk.

Whitespace should be used to help delimit blocks of code, but not excessively. A single line should be used between methods in a class, and other code blocks, as demonstrated by the following sample

    #import "CPTXYAxisSet.h"
    #import "CPTXYAxis.h"
    #import "CPTDefinitions.h"

    @implementation CPTXYAxisSet

    -(id)init
    {
    	if ((self = [super init])) {
    		CPTXYAxis *xAxis = [[CPTXYAxis alloc] init];
    		xAxis.majorTickLength = 10.f;
    		CPTXYAxis *yAxis = [[CPTXYAxis alloc] init];
    		yAxis.majorTickLength = -10.f;
		
    		self.axes = [NSArray arrayWithObjects:xAxis, yAxis, nil];
    		[xAxis release];
    		[yAxis release];
    	}
    	return self;
    }

    -(CPTAxis *)xAxis 
    {
        return [self.axes objectAtIndex:CPTCoordinateX];
    }

Whitespace should be used inside expressions to make them more readable. Note, for example, that `self = [super init]` has been used in the initializer above, rather than the more compact but less readable `self=[super init]`. In the same way, a single space should be used after commas:

    CPTPlot *plotOne, *plotTwo, *plotThree = nil;

Asterisk
--------
The convention used in Core Plot to locate an asterisk representing the pointer operator is to pair it with the variable to which it applies. 

    NSString *string;
    CPTPlot *plotOne, *plotTwo;
    
The following variants *should not* be used

    NSString* string;
    CPTPlot * plotOne;

Instance Variables
------------------
Instance variables should be private or protected. No special naming convention should be used for instance variables, such as a standard letter prefix or underscore (e.g., `mString`, `_string`).

    @interface CPTGraph : CPTLayer {
        @protected
        CPTAxisSet *axisSet;
        CPTPlotArea *plotArea;
        NSMutableArray *plots;
        NSMutableArray *plotSpaces;
    	CPTFill *fill;
    }

    // property and method declarations
    
    @end

Beginning with Core Plot 2.0, the minimum deployment target requires the modern Objective-C runtime. Core Plot classes should no longer declare instance variables in the header file and should instead declare public or private properties and rely on auto-synthesized instance variables.

    @interface CPTGraph : CPTLayer
    
    // property and method declarations
    
    @end

Methods
-------
Methods are declared in a class header only if they have not already been declared in an ancestor class (e.g., `super`) or protocol. Methods such as `init` and `dealloc` thus need not be re-declared.

Method definitions *should not* include a semi-colon in the signature

    -(id)init;
    {
        ...
    }

Although this can occasionally simplify coding, it is confusing to some developers, so it is not used in Core Plot.

Private methods should be declared in a category in the class implementation (.m) file.

    @interface CPTXYAxis ()

    -(CGPoint)viewPointForCoordinateDecimalNumber:(NSDecimalNumber *)coordinateDecimal;

    @end

Abstract methods &mdash; those that have no implementation in the declaring class, but are defined in a descendent class &mdash; can be declared in the header file in a separate category. This documents to developers that the method is abstract, and prevents the compiler issuing warnings about the missing implementation.

    @interface CPTAxis (AbstractMethods)

    -(void)drawInContext:(CGContextRef)theContext;

    @end

Pragmas
-------
Pragmas are used in implementation (.m) files to split the file into easy to navigate sections. These sections also show up in the Xcode method popup.

    #pragma mark -
    #pragma mark Initialization

    -(id)init 
    {
        return [self initWithXScaleType:CPScaleTypeLinear yScaleType:CPTScaleTypeLinear];
    }

    #pragma mark -
    #pragma mark Drawing

    -(void)renderAsVectorInContext:(CGContextRef)theContext
    {
    	[super renderAsVectorInContext:theContext];	// draw background fill
    }

Pragmas appear in pairs; the single hyphen in the first pragma is an indication to Xcode that it should insert a horizontal rule between sections in the method popup.

Properties
----------
Core Plot is designed to run on Mac OS X 10.5 and later, and iOS 3.0 and later. Core Plot makes use of Objective-C 2.0 features, such as properties, and embraces the so-called 'dot notation'. Where possible, synthesized properties should be used in place of hand written accessor methods.

Properties are declared just under the instance variable block, like so

    @interface CPTGraph : CPTLayer {
        @protected
        CPTAxisSet *axisSet;
        CPTPlotArea *plotArea;
        NSMutableArray *plots;
        NSMutableArray *plotSpaces;
    	CPTFill *fill;
    }

    @property (nonatomic, readwrite, retain) CPTAxisSet *axisSet;
    @property (nonatomic, readwrite, retain) CPTPlotArea *plotArea;
    @property (nonatomic, readonly, retain) CPTPlotSpace *defaultPlotSpace;
    @property (nonatomic, readwrite, assign) CGRect plotAreaFrame;
    @property (nonatomic, readwrite, retain) CPTFill *fill;
    
The `@synthesize` and/or `@dynamic` keywords should appear in the main class implementation at the top, before any methods are defined.

    @implementation CPTGraph

    @synthesize axisSet;
    @synthesize plotArea;
    @synthesize defaultPlotSpace;
    @synthesize fill;

    #pragma mark -
    #pragma mark Init/Dealloc

    -(id)init
    {

Where possible, instance variables should not be accessed directly outside of the `init` and `dealloc` methods. Properties should be used everywhere else to provide support for KVO. Private read-write properties can be defined for those instance variables that should be read-only or inaccessible to other code. Simply include the `@property` declaration in a category in the implementation file as described above for private methods. For read-only properties, include the read-only `@property` declaration in the header file as always and redeclare the property in the implementation file using the `readwrite` attribute and keeping the other attributes the same.

Comments
--------
Comments should not be used excessively in code. No comment block should be added at the top of either the header or implementation files, as is common. No direct author attribution or copyright notice should be included in the files. 

Where code is already self documenting, no comments should be used, other than as a means of grouping sections of related code. In short, "don't state the bleedin' obvious".

The following is an example of good use of comments in Core Plot.

    -(void)drawInContext:(CGContextRef)theContext 
    {
        // Ticks
        for ( NSDecimalNumber *tickLocation in self.majorTickLocations ) {
            // Tick end points
            CGPoint baseViewPoint = [self viewPointForCoordinateDecimalNumber:tickLocation];
            CGPoint terminalViewPoint = baseViewPoint;
            if ( self.coordinate == CPCoordinateX ) 
                terminalViewPoint.y -= self.majorTickLength;
            else
                terminalViewPoint.x -= self.majorTickLength;

            // Stroke tick
            CGContextMoveToPoint(theContext, baseViewPoint.x, baseViewPoint.y);
            CGContextBeginPath(theContext);
            CGContextAddLineToPoint(theContext, terminalViewPoint.x, terminalViewPoint.y);
            CGContextStrokePath(theContext);
        }

        // Axis Line
        CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.location];
        CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.end];
    	CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
        CGContextBeginPath(theContext);
    	CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
    	CGContextStrokePath(theContext);
    }

The following is an example of bad usage.
    
    // Set view points
    CGPoint startViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.location];
    CGPoint endViewPoint = [self viewPointForCoordinateDecimalNumber:self.range.end];

    // Begin path
	CGContextMoveToPoint(theContext, startViewPoint.x, startViewPoint.y);
    CGContextBeginPath(theContext);

    // Add line and stroke path
	CGContextAddLineToPoint(theContext, endViewPoint.x, endViewPoint.y);
	CGContextStrokePath(theContext);
	
Here the comments are doing nothing more than describing what is already clear from the code itself. Comments should only be used to delineate higher abstractions, which may not be obvious from the code (e.g., drawing an axis), and should be very concise.

If a piece of code requires a lot of explanation, it is a good candidate for refactoring. In such cases, rather than adding long-winded comments, refactor the code so that it is obvious how it works and what it does.

Comments are used in Core Plot headers to group related methods, in much the same way that pragmas fill this role in implementation files.

    // Retrieving plots
    -(NSArray *)allPlots;
    -(CPTPlot *)plotAtIndex:(NSUInteger)index;
    -(CPTPlot *)plotWithIdentifier:(id <NSCopying>)identifier;

    // Organizing plots
    -(void)addPlot:(CPTPlot *)plot; 
    -(void)addPlot:(CPTPlot *)plot toPlotSpace:(CPTPlotSpace *)space;
    -(void)removePlot:(CPTPlot *)plot;
    -(void)insertPlot:(CPTPlot*)plot atIndex:(NSUInteger)index;
    -(void)insertPlot:(CPTPlot*)plot atIndex:(NSUInteger)index intoPlotSpace:(CPTPlotSpace *)space;

    // Retrieving plot spaces
    -(NSArray *)allPlotSpaces;
    -(CPTPlotSpace *)plotSpaceAtIndex:(NSUInteger)index;
    -(CPTPlotSpace *)plotSpaceWithIdentifier:(id <NSCopying>)identifier;

    // Adding and removing plot spaces
    -(void)addPlotSpace:(CPTPlotSpace *)space; 
    -(void)removePlotSpace:(CPTPlotSpace *)plotSpace;

In-Code Documentation
---------------------
Core Plot uses Doxygen to document the project. See <http://code.google.com/p/core-plot/wiki/DocumentationPolicy> for more information.

Constants
---------
Constant variables are often declared as preprocessor macros in Objective-C code.

    #define kNSSomeConstant (10.0f)
    
In Core Plot, where possible, such constants should be declared as true variables at the top file scope. This allows the compiler to do type checking, and is generally cleaner than relying on the preprocessor.

    const CPTFloat kCPTSomeConstant = 10.0f;
    
Where a variable may take a finite number of discrete values, an enum should be declared.

    typedef enum _CPTScaleType {
        CPTScaleTypeLinear,
        CPTScaleTypeLogN,
        CPTScaleTypeLog10,
        CPTScaleTypeAngular
    } CPTScaleType;
    
and any string constants should also be declared as variables, rather than hard coded as literals throughout the code (e.g., when declaring notifications). For example, a binding name would be declared in the header as

    extern NSString * const kCPTScatterPlotBindingXValues;

and defined in the implementation file as

    NSString * const kCPTScatterPlotBindingXValues = @"xValues";

Numeric Data Types
------------------
Internally, Core Plot has been designed to work with `NSDecimalNumber` and `NSDecimal`, so that user data can be handled with high precision. This does not mean `NSDecimal` should be used for all aspects of Core Plot. When drawing, there is no point using numbers with higher precision than `CGFloat`, the standard numeric type for Core Graphics.

In summary, when handling user data, work with `double`, `NSDecimal` or `NSDecimalNumber` &mdash; depending on the context &mdash; and when drawing or carrying out other standard Cocoa operations, use the native Cocoa numerical types (e.g., `CGFloat`, `NSUInteger`, `NSInteger`).

Memory Management
-----------------
Core Plot has been designed to work with apps utilizing garbage collected (GC), manual reference counting, and automatic reference counting (ARC). This means that internally, manual memory management techniques (e.g., `retain`/`release`/`autorelease`) must be utilized. And because Core Plot must also function on low memory devices like iPhone, care should be taken not to overuse autoreleased objects, and to avoid excessive use of memory.

Initialization and Deallocation
-------------------------------
The initializers in Core Plot assign values to the instance variables directly, like so

    -(id)init
    {
    	if ( (self = [super init]) ) {
    		lineCap = kCGLineCapButt;
    		lineJoin = kCGLineJoinMiter;
    		lineWidth = 1.f;
    		patternPhase = CGSizeMake(0.f, 0.f);
    		lineColor = [[CPTColor blackColor] retain];
    	}
    	return self;
    }
    
The `dealloc` method should release any object instance variables directly and not use accessor methods.

    -(void)dealloc
    {
    	[lineColor release];
    	[super dealloc];
    }
    
Invoking an accessor can cause unwanted side effects during deallocation, especially in classes derived from `CPTLayer` where the accessors may try to set properties on other objects that may also be in the process of being deallocated.

Accessors
---------
Wherever possible, Objective-C 2.0 properties should be used in place of handwritten accessor methods. When accessor methods are used they should take this form

    -(NSString *)name 
    {
        return [[name retain] autorelease];
    }
    
    -(void)setName:(NSString *)newName 
	{
        if ( newName != name ) {
            [name release];
            name = [newName copy];
        }
    }

Of course, `retain` may appear in place of `copy` depending on the context. 

The dummy argument passed to the setter method should begin with 'new', to prevent a naming conflict with the instance variable.

Platform Dependencies
---------------------
Core Plot is designed to run on both the Mac OS X and iOS. Even though many frameworks are very similar on the two platforms, the overlap is not 100%. Core Graphics on iOS is not exactly the same as on the Mac. The Mac uses AppKit classes like `NSColor` for drawing, where iOS uses `UIColor`. Image handling is also totally different on the two platforms.

Because of these differences, it is unavoidable that some platform specific code be introduced into Core Plot. One way to do this is to use branching in the preprocessor to modify the code used by each platform. For example,

    +(CGColorSpaceRef)createGenericRGBSpace;
    {
    #if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    	return CGColorSpaceCreateDeviceRGB();
    #else
    	return CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB); 
    #endif
    } 

Sometimes code like this cannot easily be avoided, but where possible, it should be. This type of platform dependent code should be concentrated as much as possible in just a few files in the framework, and not spread throughout.

When platform code is needed, it should be split off into a separate file, as a function, or a new class. A different copy of the file can then be used for each platform. This allows preprocessor branching to be completely removed from the code, and is much cleaner and easy to maintain.

One last aspect of platform dependency is frameworks. Many frameworks are only available on one platform. For example, you shouldn't use AppKit in Core Plot, other than in the Mac-specific code. Similarly, UIKit can only be imported into iOS-Specific code.

In general, you should test your changes in both the Mac and iOS projects, to make sure you haven't inadvertently introduced platform dependencies.

