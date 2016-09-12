import UIKit

class BarChartController : UIViewController, CPTBarPlotDataSource {
    private var barGraph : CPTXYGraph? = nil

    // MARK: Initialization

    override func viewDidAppear(_ animated : Bool)
    {
        super.viewDidAppear(animated)

        // Create graph from theme
        let newGraph = CPTXYGraph(frame: .zero)
        newGraph.apply(CPTTheme(named: .darkGradientTheme))

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
        paragraphStyle.alignment = .center

        let lineOne = "Graph Title"
        let lineTwo = "Line 2"

        let line1Font = UIFont(name: "Helvetica-Bold", size:16.0)
        let line2Font = UIFont(name: "Helvetica", size:12.0)

        let graphTitle = NSMutableAttributedString(string: lineOne + "\n" + lineTwo)

        let titleRange1 = NSRange(location: 0, length: lineOne.utf16.count)
        let titleRange2 = NSRange(location: lineOne.utf16.count + 1, length: lineTwo.utf16.count)

        graphTitle.addAttribute(NSForegroundColorAttributeName, value:UIColor.white, range:titleRange1)
        graphTitle.addAttribute(NSForegroundColorAttributeName, value:UIColor.gray, range:titleRange2)
        graphTitle.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSRange(location: 0, length: graphTitle.length))
        graphTitle.addAttribute(NSFontAttributeName, value:line1Font!, range:titleRange1)
        graphTitle.addAttribute(NSFontAttributeName, value:line2Font!, range:titleRange2)

        newGraph.attributedTitle = graphTitle

        newGraph.titleDisplacement        = CGPoint(x: 0.0, y:-20.0)
        newGraph.titlePlotAreaFrameAnchor = .top

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
            x.labelingPolicy = .none

            let customTickLocations = [1, 5, 10, 15]
            let xAxisLabels         = ["Label A", "Label B", "Label C", "Label D"]

            var labelLocation = 0
            var customLabels = Set<CPTAxisLabel>()
            for tickLocation in customTickLocations {
                let newLabel = CPTAxisLabel(text:xAxisLabels[labelLocation], textStyle:x.labelTextStyle)
                labelLocation += 1
                newLabel.tickLocation = NSNumber.init(value: tickLocation)
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
        let barPlot1        = CPTBarPlot.tubularBarPlot(with: .darkGray(), horizontalBars:false)
        barPlot1.baseValue  = 0.0
        barPlot1.dataSource = self
        barPlot1.barOffset  = -0.2
        barPlot1.identifier = NSString.init(string: "Bar Plot 1")
        newGraph.add(barPlot1, to:plotSpace)

        // Second bar plot
        let barPlot2             = CPTBarPlot.tubularBarPlot(with: .blue(), horizontalBars:false)
        barPlot2.dataSource      = self
        barPlot2.baseValue       = 0.0
        barPlot2.barOffset       = 0.25
        barPlot2.barCornerRadius = 2.0
        barPlot2.identifier      = NSString.init(string: "Bar Plot 2")
        newGraph.add(barPlot2, to:plotSpace)

        self.barGraph = newGraph
    }

    // MARK: - Plot Data Source Methods

    func numberOfRecords(for plot: CPTPlot) -> UInt
    {
        return 16
    }

    func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any?
    {
        switch CPTBarPlotField(rawValue: Int(field))! {
        case .barLocation:
            return record as NSNumber
            
        case .barTip:
            let plotID = plot.identifier as! String
            return (plotID == "Bar Plot 2" ? record : ((record + 1) * (record + 1)) ) as NSNumber
            
        default:
            return nil
        }
    }
}
