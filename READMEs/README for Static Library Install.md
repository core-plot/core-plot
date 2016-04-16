# Install Binaries for iOS

1. Copy the **CorePlotHeaders** to your Xcode project

2. Copy **libCorePlotCocoaTouch.a** to your Xcode project

3. Add the following flags to "Other Linker Flags" in your target build settings:
   `-ObjC`

4. Add the **QuartzCore** and **Accelerate** frameworks to the project.

5. Add a `CPTGraph` to your application. See the example apps in Source Code to see how, or read the documentation.