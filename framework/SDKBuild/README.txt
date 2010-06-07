Five Steps to CorePlot

1. Copy the CorePlotSDK directory to ~/Library/SDKs/

2. Add to your project's .PCH file:

#import <CorePlot/CorePlot.h>

3. Open Project -> Edit Project Settings and for All Configurations:

	3a. Add to Additional SDKS: 

$HOME/Library/SDKs/CorePlotSDK/${PLATFORM_NAME}.sdk

	3b. Add to Other Linker Flags:

-ObjC -all_load -lCorePlot 

4. Add the QuartzCore framework to the project.

5. Add a CPGraph to your application.