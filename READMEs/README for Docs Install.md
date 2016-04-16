# To Install Documentation From a Release Package

1. Quit Xcode.

2. Copy the **com.CorePlot.Framework.docset** and/or **com.CorePlotTouch.Framework.docset** bundles from the release Documentation folder into **~/Library/Developer/Shared/Documentation/DocSets/**.

3. Launch Xcode and browse the Core Plot documentation in the Documentation browser.

# To Build the Documentation From Source

1. Install [Doxygen]([http://www.stack.nl/~dimitri/doxygen/download.html#latestsrc) in **/Applications**. Core Plot requires Doxygen 1.8.11 or later.

2. Install [Graphviz](http://www.graphviz.org/Download_macos.php). Core Plot requires Graphviz 2.36.0 or later.

3. Open the **CorePlot** project in Xcode.

4. Build the "Documentation-Mac" and/or "Documentation-iOS" targets.