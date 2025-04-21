import Foundation
import Cocoa
import CorePlot

@MainActor
class DateController : NSObject, CPTPlotDataSource {
    private let oneDay : Double = 24 * 60 * 60

    @IBOutlet var hostView : CPTGraphHostingView? = nil

    private var graph : CPTXYGraph? = nil

    private var plotData = [Double]()

    // MARK: - Initialization

    override func awakeFromNib()
    {
        MainActor.assumeIsolated {
            self.plotData = newPlotData()
        }

        // If you make sure your dates are calculated at noon, you shouldn't have to
        // worry about daylight savings. If you use midnight, you will have to adjust
        // for daylight savings time.
        let refDate = DateFormatter().date(from: "12:00 Oct 29, 2009")

        // Create graph
        let newGraph = CPTXYGraph(frame: .zero)

        let theme = CPTTheme(named: .darkGradientTheme)
        newGraph.apply(theme)

        // Setup scatter plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace

        plotSpace.xRange = CPTPlotRange(location: 0.0, length: (oneDay * 5.0) as NSNumber)
        plotSpace.yRange = CPTPlotRange(location: 1.0, length: 3.0)

        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        if let x = axisSet.xAxis {
            x.majorIntervalLength   = oneDay as NSNumber
            x.orthogonalPosition    = 2.0
            x.minorTicksPerInterval = 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let timeFormatter = CPTTimeFormatter(dateFormatter:dateFormatter)
            timeFormatter.referenceDate = refDate
            x.labelFormatter            = timeFormatter
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = oneDay as NSNumber

            y.labelingPolicy = .none
        }

        // Create a plot that uses the data source method
        let dataSourceLinePlot = CPTScatterPlot(frame: .zero)
        dataSourceLinePlot.identifier = "Date Plot" as NSString

        if let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as? CPTMutableLineStyle {
            lineStyle.lineWidth              = 3.0
            lineStyle.lineColor              = .green()
            dataSourceLinePlot.dataLineStyle = lineStyle
        }

        dataSourceLinePlot.dataSource = self
        newGraph.add(dataSourceLinePlot)

        MainActor.assumeIsolated {
            self.graph = newGraph

            if let host = self.hostView {
                host.hostedGraph = newGraph
            }
        }
    }

    nonisolated func newPlotData() -> [Double]
    {
        var newData = [Double]()

        for _ in 0 ..< 5 {
            newData.append(1.2 * Double(arc4random()) / Double(UInt32.max) + 1.2)
        }

        return newData
    }

    // MARK: - Plot Data Source Methods

    nonisolated func numberOfRecords(for plot: CPTPlot) -> UInt
    {
        MainActor.assumeIsolated {
            return UInt(self.plotData.count)
        }
    }

    nonisolated func number(for plot: CPTPlot, field: UInt, record: UInt) -> Any?
    {
        var result : NSNumber?

        switch CPTScatterPlotField(rawValue: Int(field))! {
        case .X:
            result = (oneDay * Double(record)) as NSNumber

        case .Y:
            MainActor.assumeIsolated {
                result = self.plotData[Int(record)] as NSNumber
            }

        @unknown default:
            result = nil
        }

        return result
    }
}
