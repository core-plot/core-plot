import UIKit

class ScatterPlotController : UIViewController, CPTScatterPlotDataSource, CPTAxisDelegate {
    private var scatterGraph : CPTXYGraph? = nil

    typealias plotDataType = [CPTScatterPlotField : Double]
    private var dataForPlot = [plotDataType]()

    // MARK: Initialization

    override func viewDidAppear(_ animated : Bool)
    {
        super.viewDidAppear(animated)

        // Create graph from theme
        let newGraph = CPTXYGraph(frame: .zero)
        newGraph.apply(CPTTheme(named: kCPTDarkGradientTheme))

        let hostingView = self.view as! CPTGraphHostingView
        hostingView.hostedGraph = newGraph

        // Paddings
        newGraph.paddingLeft   = 10.0
        newGraph.paddingRight  = 10.0
        newGraph.paddingTop    = 10.0
        newGraph.paddingBottom = 10.0

        // Plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.yRange = CPTPlotRange(location:1.0, length:2.0)
        plotSpace.xRange = CPTPlotRange(location:1.0, length:3.0)

        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 0.5
            x.orthogonalPosition    = 2.0
            x.minorTicksPerInterval = 2
            x.labelExclusionRanges  = [
                CPTPlotRange(location: 0.99, length: 0.02),
                CPTPlotRange(location: 1.99, length: 0.02),
                CPTPlotRange(location: 2.99, length: 0.02)
            ]
        }

        if let y = axisSet.xAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 2.0
            y.labelExclusionRanges  = [
                CPTPlotRange(location: 0.99, length: 0.02),
                CPTPlotRange(location: 1.99, length: 0.02),
                CPTPlotRange(location: 3.99, length: 0.02)
            ]
            y.delegate = self
        }

        // Create a blue plot area
        let boundLinePlot = CPTScatterPlot(frame: .zero)
        let blueLineStyle = CPTMutableLineStyle()
        blueLineStyle.miterLimit    = 1.0
        blueLineStyle.lineWidth     = 3.0
        blueLineStyle.lineColor     = .blue()
        boundLinePlot.dataLineStyle = blueLineStyle
        boundLinePlot.identifier    = "Blue Plot"
        boundLinePlot.dataSource    = self
        newGraph.add(boundLinePlot)

        let fillImage = CPTImage(named:"BlueTexture")
        fillImage.isTiled = true
        boundLinePlot.areaFill      = CPTFill(image: fillImage)
        boundLinePlot.areaBaseValue = 0.0

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = .black()
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill          = CPTFill(color: .blue())
        plotSymbol.lineStyle     = symbolLineStyle
        plotSymbol.size          = CGSize(width: 10.0, height: 10.0)
        boundLinePlot.plotSymbol = plotSymbol

        // Create a green plot area
        let dataSourceLinePlot = CPTScatterPlot(frame: .zero)
        let greenLineStyle               = CPTMutableLineStyle()
        greenLineStyle.lineWidth         = 3.0
        greenLineStyle.lineColor         = .green()
        greenLineStyle.dashPattern       = [5.0, 5.0]
        dataSourceLinePlot.dataLineStyle = greenLineStyle
        dataSourceLinePlot.identifier    = "Green Plot"
        dataSourceLinePlot.dataSource    = self

        // Put an area gradient under the plot above
        let areaColor    = CPTColor(componentRed: 0.3, green: 1.0, blue: 0.3, alpha: 0.8)
        let areaGradient = CPTGradient(beginning: areaColor, ending: .clear())
        areaGradient.angle = -90.0
        let areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill      = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 1.75

        // Animate in the new plot, as an example
        dataSourceLinePlot.opacity = 0.0
        newGraph.add(dataSourceLinePlot)

        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.duration            = 1.0
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.fillMode            = kCAFillModeForwards
        fadeInAnimation.toValue             = 1.0
        dataSourceLinePlot.add(fadeInAnimation, forKey: "animateOpacity")

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

    func numberOfRecords(for plot: CPTPlot) -> UInt
    {
        return UInt(self.dataForPlot.count)
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> AnyObject?
    {
        let plotField = CPTScatterPlotField(rawValue: Int(field))

        if let num = self.dataForPlot[Int(record)][plotField!] {
            let plotID = plot.identifier as! String
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

    private func axis(axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: NSSet!) -> Bool
    {
        if let formatter = axis.labelFormatter {
            let labelOffset = axis.labelOffset

            var newLabels = Set<CPTAxisLabel>()

            for tickLocation in locations {
                if let labelTextStyle = axis.labelTextStyle?.mutableCopy() as? CPTMutableTextStyle {

                    if tickLocation.doubleValue >= 0.0 {
                        labelTextStyle.color = .green()
                    }
                    else {
                        labelTextStyle.color = .red()
                    }

                    let labelString   = formatter.string(for:tickLocation)
                    let newLabelLayer = CPTTextLayer(text: labelString, style: labelTextStyle)

                    let newLabel = CPTAxisLabel(contentLayer: newLabelLayer)
                    newLabel.tickLocation = tickLocation as! NSNumber
                    newLabel.offset       = labelOffset
                    
                    newLabels.insert(newLabel)
                }
                
                axis.axisLabels = newLabels
            }
        }
        
        return false
    }
}
