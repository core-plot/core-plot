import UIKit

class BarChartController : UIViewController, CPTBarPlotDataSource {
    private var barGraph : CPTXYGraph? = nil

    // MARK: Initialization

    override func viewDidAppear(animated : Bool)
    {
        super.viewDidAppear(animated)

        // Create graph from theme
        let newGraph = CPTXYGraph(frame: CGRectZero)
        newGraph.applyTheme(CPTTheme(named: kCPTDarkGradientTheme))

        let hostingView = self.view as! CPTGraphHostingView
        hostingView.hostedGraph = newGraph

        if let frameLayer = newGraph.plotAreaFrame {
            // Border
            frameLayer.borderLineStyle = nil
            frameLayer.cornerRadius    = 0.0
            frameLayer.masksToBorder   = false

            // Paddings
            newGraph.paddingLeft   = 0.0
            newGraph.paddingRight  = 0.0
            newGraph.paddingTop    = 0.0
            newGraph.paddingBottom = 0.0

            frameLayer.paddingLeft   = 70.0
            frameLayer.paddingTop    = 20.0
            frameLayer.paddingRight  = 20.0
            frameLayer.paddingBottom = 80.0
        }

        // Graph title
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center

        let lineOne = "Graph Title"
        let lineTwo = "Line 2"

        let line1Font = UIFont(name: "Helvetica-Bold", size:16.0)
        let line2Font = UIFont(name: "Helvetica", size:12.0)

        let graphTitle = NSMutableAttributedString(string: lineOne + "\n" + lineTwo)

        let titleRange1 = NSRange(location: 0, length: count(lineOne.utf16))
        let titleRange2 = NSRange(location: count(lineOne.utf16) + 1, length: count(lineTwo.utf16))

        graphTitle.addAttribute(NSForegroundColorAttributeName, value:UIColor.whiteColor(), range:titleRange1)
        graphTitle.addAttribute(NSForegroundColorAttributeName, value:UIColor.grayColor(), range:titleRange2)
        graphTitle.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSRange(location: 0, length: graphTitle.length))
        graphTitle.addAttribute(NSFontAttributeName, value:line1Font!, range:titleRange1)
        graphTitle.addAttribute(NSFontAttributeName, value:line2Font!, range:titleRange2)

        newGraph.attributedTitle = graphTitle

        newGraph.titleDisplacement        = CGPoint(x: 0.0, y:-20.0)
        newGraph.titlePlotAreaFrameAnchor = .Top

        // Plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.yRange = CPTPlotRange(location:0.0, length:300.0)
        plotSpace.xRange = CPTPlotRange(location:0.0, length:16.0)

        let axisSet = newGraph.axisSet as! CPTXYAxisSet

        if let x = axisSet.xAxis {
            x.axisLineStyle       = nil
            x.majorTickLineStyle  = nil
            x.minorTickLineStyle  = nil
            x.majorIntervalLength = 5.0
            x.orthogonalPosition  = 0.0
            x.title               = "X Axis"
            x.titleLocation       = 7.5
            x.titleOffset         = 55.0

            // Custom labels
            x.labelRotation  = CGFloat(M_PI_4)
            x.labelingPolicy = .None

            let customTickLocations = [1, 5, 10, 15]
            let xAxisLabels         = ["Label A", "Label B", "Label C", "Label D"]

            var labelLocation = 0
            var customLabels = Set<CPTAxisLabel>()
            for tickLocation in customTickLocations {
                let newLabel = CPTAxisLabel(text:xAxisLabels[labelLocation++], textStyle:x.labelTextStyle)
                newLabel.tickLocation = tickLocation
                newLabel.offset       = x.labelOffset + x.majorTickLength
                newLabel.rotation     = CGFloat(M_PI_4)
                customLabels.insert(newLabel)
            }

            x.axisLabels = customLabels
        }

        if let y = axisSet.yAxis {
            y.axisLineStyle       = nil
            y.majorTickLineStyle  = nil
            y.minorTickLineStyle  = nil
            y.majorIntervalLength = 50.0
            y.orthogonalPosition  = 0.0
            y.title               = "Y Axis"
            y.titleOffset         = 45.0
            y.titleLocation       = 150.0
        }

        // First bar plot
        let barPlot1        = CPTBarPlot.tubularBarPlotWithColor(CPTColor.darkGrayColor(), horizontalBars:false)
        barPlot1.baseValue  = 0.0
        barPlot1.dataSource = self
        barPlot1.barOffset  = -0.2
        barPlot1.identifier = "Bar Plot 1"
        newGraph.addPlot(barPlot1, toPlotSpace:plotSpace)

        // Second bar plot
        let barPlot2             = CPTBarPlot.tubularBarPlotWithColor(CPTColor.blueColor(), horizontalBars:false)
        barPlot2.dataSource      = self
        barPlot2.baseValue       = 0.0
        barPlot2.barOffset       = 0.25
        barPlot2.barCornerRadius = 2.0
        barPlot2.identifier      = "Bar Plot 2"
        newGraph.addPlot(barPlot2, toPlotSpace:plotSpace)

        self.barGraph = newGraph
    }

    // MARK: - Plot Data Source Methods

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt
    {
        return 16
    }

    func numberForPlot(plot: CPTPlot, field: UInt, recordIndex: UInt) -> AnyObject?
    {
        switch CPTBarPlotField(rawValue: Int(field))! {
        case .BarLocation:
            return recordIndex as NSNumber
            
        case .BarTip:
            let plotID = plot.identifier as! String
            return (plotID == "Bar Plot 2" ? recordIndex : ((recordIndex + 1) * (recordIndex + 1)) ) as NSNumber
            
        default:
            return nil
        }
    }
}
