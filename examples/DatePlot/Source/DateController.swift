import Foundation
import Cocoa
import CorePlot

class DateController : NSObject, CPTPlotDataSource {
    private let oneDay : Double = 24 * 60 * 60;

    @IBOutlet var hostView : CPTGraphHostingView? = nil

    private var graph : CPTXYGraph? = nil

    private var plotData = [Double]()

    // MARK: - Initialization

    override func awakeFromNib()
    {
        self.plotData = newPlotData()

        // If you make sure your dates are calculated at noon, you shouldn't have to
        // worry about daylight savings. If you use midnight, you will have to adjust
        // for daylight savings time.
        let refDate = NSDateFormatter().dateFromString("12:00 Oct 29, 2009")

        // Create graph
        let newGraph = CPTXYGraph()

        let theme = CPTTheme(named: kCPTDarkGradientTheme)
        newGraph.applyTheme(theme)

        if let host = self.hostView {
            host.hostedGraph = newGraph;
        }

        // Setup scatter plot space
        let plotSpace = newGraph.defaultPlotSpace as CPTXYPlotSpace

        plotSpace.xRange = CPTPlotRange(location:0.0, length:oneDay * 5.0)
        plotSpace.yRange = CPTPlotRange(location:1.0, length:3.0)

        // Axes
        let axisSet = newGraph.axisSet as CPTXYAxisSet
        let x = axisSet.xAxis
        x.majorIntervalLength   = oneDay
        x.orthogonalPosition    = 2.0
        x.minorTicksPerInterval = 0;
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        let timeFormatter = CPTTimeFormatter(dateFormatter:dateFormatter)
        timeFormatter.referenceDate = refDate;
        x.labelFormatter            = timeFormatter;

        let y = axisSet.yAxis
        y.majorIntervalLength   = 0.5
        y.minorTicksPerInterval = 5
        y.orthogonalPosition    = oneDay

        // Create a plot that uses the data source method
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.identifier = "Date Plot"

        let lineStyle = dataSourceLinePlot.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        lineStyle.lineWidth              = 3.0
        lineStyle.lineColor              = CPTColor.greenColor()
        dataSourceLinePlot.dataLineStyle = lineStyle

        dataSourceLinePlot.dataSource = self
        newGraph.addPlot(dataSourceLinePlot)

        self.graph = newGraph
    }

    func newPlotData() -> [Double]
    {
        var newData = [Double]()

        for i in 0 ..< 5 {
            newData.append(1.2 * Double(arc4random()) / Double(UInt32.max) + 1.2)
        }

        return newData
    }

    // MARK: - Plot Data Source Methods

    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt
    {
        return UInt(self.plotData.count)
    }

    func numberForPlot(plot: CPTPlot!, field: UInt, recordIndex: UInt) -> AnyObject!
    {
        switch CPTScatterPlotField.fromRaw(Int(field))! {
        case .X:
            return (oneDay * Double(recordIndex)) as NSNumber
            
        case .Y:
            return self.plotData[Int(recordIndex)] as NSNumber
        }
    }
}
