import UIKit

class ScatterPlotController : UIViewController, CPTScatterPlotDataSource {
    private var scatterGraph : CPTXYGraph? = nil

    typealias plotDataType = [CPTScatterPlotField : Double]
    private var dataForPlot = [plotDataType]()

    // MARK: Initialization

    override func viewDidAppear(animated : Bool)
    {
        super.viewDidAppear(animated)

        // Create graph from theme
        let newGraph = CPTXYGraph()
        newGraph.applyTheme(CPTTheme(named: kCPTDarkGradientTheme))

        let hostingView = self.view as CPTGraphHostingView
        hostingView.hostedGraph = newGraph

        // Paddings
        newGraph.paddingLeft   = 10.0
        newGraph.paddingRight  = 10.0
        newGraph.paddingTop    = 10.0
        newGraph.paddingBottom = 10.0

        // Plot space
        let plotSpace = newGraph.defaultPlotSpace as CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.yRange = CPTPlotRange(location:1.0, length:2.0)
        plotSpace.xRange = CPTPlotRange(location:1.0, length:3.0)

        // Axes
        let axisSet = newGraph.axisSet as CPTXYAxisSet

        let x = axisSet.xAxis
        x.majorIntervalLength   = 0.5
        x.orthogonalPosition    = 2.0
        x.minorTicksPerInterval = 2
        x.labelExclusionRanges  = [
            CPTPlotRange(location: 0.99, length: 0.02),
            CPTPlotRange(location: 1.99, length: 0.02),
            CPTPlotRange(location: 2.99, length: 0.02)
        ]

        let y = axisSet.xAxis
        y.majorIntervalLength   = 0.5
        y.minorTicksPerInterval = 5
        y.orthogonalPosition    = 2.0
        y.labelExclusionRanges  = [
            CPTPlotRange(location: 0.99, length: 0.02),
            CPTPlotRange(location: 1.99, length: 0.02),
            CPTPlotRange(location: 3.99, length: 0.02)
        ]
        y.delegate             = self

        // Create a blue plot area
        let boundLinePlot = CPTScatterPlot()
        let blueLineStyle = CPTMutableLineStyle()
        blueLineStyle.miterLimit    = 1.0
        blueLineStyle.lineWidth     = 3.0
        blueLineStyle.lineColor     = CPTColor.blueColor()
        boundLinePlot.dataLineStyle = blueLineStyle
        boundLinePlot.identifier    = "Blue Plot"
        boundLinePlot.dataSource    = self
        newGraph.addPlot(boundLinePlot)

        let fillImage = CPTImage(named:"BlueTexture")
        fillImage.tiled = true
        boundLinePlot.areaFill      = CPTFill(image: fillImage)
        boundLinePlot.areaBaseValue = 0.0

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = CPTColor.blackColor()
        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill          = CPTFill(color: CPTColor.blueColor())
        plotSymbol.lineStyle     = symbolLineStyle
        plotSymbol.size          = CGSize(width: 10.0, height: 10.0)
        boundLinePlot.plotSymbol = plotSymbol

        // Create a green plot area
        let dataSourceLinePlot = CPTScatterPlot()
        let greenLineStyle               = CPTMutableLineStyle()
        greenLineStyle.lineWidth         = 3.0
        greenLineStyle.lineColor         = CPTColor.greenColor()
        greenLineStyle.dashPattern       = [5.0, 5.0]
        dataSourceLinePlot.dataLineStyle = greenLineStyle
        dataSourceLinePlot.identifier    = "Green Plot"
        dataSourceLinePlot.dataSource    = self

        // Put an area gradient under the plot above
        let areaColor    = CPTColor(componentRed: 0.3, green: 1.0, blue: 0.3, alpha: 0.8)
        let areaGradient = CPTGradient(beginningColor: areaColor, endingColor: CPTColor.clearColor())
        areaGradient.angle = -90.0
        let areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill      = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 1.75

        // Animate in the new plot, as an example
        dataSourceLinePlot.opacity = 0.0
        newGraph.addPlot(dataSourceLinePlot)

        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.duration            = 1.0
        fadeInAnimation.removedOnCompletion = false
        fadeInAnimation.fillMode            = kCAFillModeForwards
        fadeInAnimation.toValue             = 1.0
        dataSourceLinePlot.addAnimation(fadeInAnimation, forKey: "animateOpacity")

        // Add some initial data
        var contentArray = [plotDataType]()
        for i in 0 ..< 60 {
            let x = 1.0 + Double(i) * 0.05
            let y = 1.2 * Double(arc4random()) / Double(UInt32.max) + 1.2
            let dataPoint: plotDataType = [.X: x, .Y: y]
            contentArray.append(dataPoint)
        }
        self.dataForPlot = contentArray

        self.scatterGraph = newGraph
    }

    // MARK: - Plot Data Source Methods

    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt
    {
        return UInt(self.dataForPlot.count)
    }

    func numberForPlot(plot: CPTPlot!, field: UInt, recordIndex: UInt) -> AnyObject!
    {
        let plotField = CPTScatterPlotField(rawValue: Int(field))

        if let num = self.dataForPlot[Int(recordIndex)][plotField!] {
            let plotID = plot.identifier as String
            if (plotField! == .Y) && (plotID == "Green Plot") {
                return (num + 1.0) as NSNumber
            }
            else {
                return num as NSNumber
            }
        }
        else {
            return nil
        }
    }

    // MARK: - Axis Delegate Methods

    func axis(axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: NSSet!) -> Bool
    {
        let formatter   = axis.labelFormatter
        let labelOffset = axis.labelOffset

        let newLabels = NSMutableSet()

        for tickLocation in locations {
            var labelTextStyle = axis.labelTextStyle.mutableCopy() as CPTMutableTextStyle

            if tickLocation.doubleValue >= 0.0 {
                labelTextStyle.color = CPTColor.greenColor()
            }
            else {
                labelTextStyle.color = CPTColor.redColor()
            }

            let labelString   = formatter.stringForObjectValue(tickLocation)
            let newLabelLayer = CPTTextLayer(text: labelString, style: labelTextStyle)

            let newLabel = CPTAxisLabel(contentLayer: newLabelLayer)
            newLabel.tickLocation = tickLocation as NSNumber
            newLabel.offset       = labelOffset
            
            newLabels.addObject(newLabel)
        }
        
        axis.axisLabels = newLabels
        
        return false
    }
}
