
import UIKit

class CoordinateView: UIView {
    // MARK: - Properties: UI
    private let xAxis = UIView(frame: .zero)
    private let yAxis = UIView(frame: .zero)
    private let xAxisArrow = UIView(frame: .zero)
    private let yAxisArrow = UIView(frame: .zero)

    private let xAxisMarks = CAShapeLayer()
    private let yAxisMarks = CAShapeLayer()
    private let verticalGrid = CAShapeLayer()
    private let horizontalGrid = CAShapeLayer()

    private var yAxisHeightConstraint: NSLayoutConstraint!
    private var yAxisWidthConstraint: NSLayoutConstraint!
    private var xAxisHeightConstraint: NSLayoutConstraint!
    private var xAxisWidthConstraint: NSLayoutConstraint!
    private var xAxisCenterYConstraint: NSLayoutConstraint!
    private var yAxisCenterXConstraint: NSLayoutConstraint!

    // MARK: Model
    private let xSymmetric: Bool
    private let ySymmetric: Bool
    private let xMaxAbs: Int
    private let yMaxAbs: Int

    private let sizeFactor: CGFloat
    private let leftMarginShare: CGFloat
    private let drawAxisMarks: Bool = true
    private let drawGrid: Bool = true

    // MARK: Constants
    private let relativeAxisMarksLength: CGFloat = 0.02
    private let relativeArrowWidth: CGFloat = 0.02
    private let relativeLineWidth: CGFloat = 0.002
    private var lineWidth: CGFloat { min(2, max(1.5, relativeLineWidth*frame.width)) }
    private var gridLineWidth: CGFloat { lineWidth / 2 }
    internal static let lineColor: UIColor = UIColor(red: 68/255, green: 58/255, blue: 65/255, alpha: 1)
    internal static let gridColor: UIColor = lineColor.withAlphaComponent(0.3)

    // MARK: Computed
    var xMin: CGFloat { (1 - sizeFactor) * leftMarginShare * frame.width }
    var xMax: CGFloat { (1 - (1 - sizeFactor) * (1 - leftMarginShare)) * frame.width }
    var yMin: CGFloat { (1 - sizeFactor) * (1 - leftMarginShare) * frame.height }
    var yMax: CGFloat { (1 - (1 - sizeFactor) * leftMarginShare) * frame.height }

    // MARK: - Initializers
    init(definitionRange: FunctionRange, valueRange: FunctionRange, sizeFactor: CGFloat, leftMarginShare: CGFloat) {
        self.sizeFactor = sizeFactor
        self.leftMarginShare = leftMarginShare

        xSymmetric = definitionRange.minValue == -definitionRange.maxValue
        ySymmetric = valueRange.minValue == -valueRange.maxValue
        xMaxAbs = Int(definitionRange.maxValue)
        yMaxAbs = Int(valueRange.maxValue)

        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()

        xAxisWidthConstraint.constant = frame.width
        xAxisHeightConstraint.constant = lineWidth
        yAxisWidthConstraint.constant = lineWidth
        yAxisHeightConstraint.constant = frame.height

        xAxisCenterYConstraint.constant = ySymmetric ? yMin + (yMax - yMin) / 2 : yMax
        yAxisCenterXConstraint.constant = xSymmetric ? xMin + (xMax - xMin) / 2 : xMin

        drawArrows()
        drawAxisMarksAndGrid()
    }

    private func drawArrows() {
        yAxisArrow.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        xAxisArrow.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let arrowWidth = relativeArrowWidth * frame.width
        let arrowOffset = arrowWidth / 15

        let yAxisArrowLayer = CAShapeLayer()
        let yAxisArrowPath = CGMutablePath()
        yAxisArrowPath.move(to: .init(x: 0, y: arrowWidth/sqrt(2)-arrowOffset))
        yAxisArrowPath.addLine(to: .init(x: arrowWidth/2, y: -arrowOffset))
        yAxisArrowPath.addLine(to: .init(x: arrowWidth, y: arrowWidth/sqrt(2)-arrowOffset))
        yAxisArrowLayer.path = yAxisArrowPath
        yAxisArrowLayer.fillColor = .none
        yAxisArrowLayer.strokeColor = Self.lineColor.cgColor
        yAxisArrowLayer.lineWidth = lineWidth
        yAxisArrow.layer.addSublayer(yAxisArrowLayer)

        let xAxisArrowLayer = CAShapeLayer()
        let xAxisArrowPath = CGMutablePath()
        xAxisArrowPath.move(to: .init(x: arrowOffset + arrowWidth*(1-1/sqrt(2)), y: 0))
        xAxisArrowPath.addLine(to: .init(x: arrowWidth + arrowOffset, y: arrowWidth/2))
        xAxisArrowPath.addLine(to: .init(x: arrowOffset + arrowWidth*(1-1/sqrt(2)), y: arrowWidth))
        xAxisArrowLayer.path = xAxisArrowPath
        xAxisArrowLayer.fillColor = .none
        xAxisArrowLayer.strokeColor = Self.lineColor.cgColor
        xAxisArrowLayer.lineWidth = lineWidth
        xAxisArrow.layer.addSublayer(xAxisArrowLayer)
    }

    private func drawAxisMarksAndGrid() {
        guard frame.width > 0, frame.height > 0, drawAxisMarks || drawGrid else { return }

        // Position calculations
        let yPositionOfXMarks = ySymmetric ? yMin + (yMax - yMin) / 2 : yMax
        let xMarksCount: CGFloat = 5 // must be uneven
        let xDistance = (xMax - xMin) / (xMarksCount - 1)
        let yAxisMarkIndex: CGFloat = xSymmetric ? (xMarksCount - 1) / 2 : 0
        let xPoints = stride(from: xMin, to: xMax+0.001, by: xDistance).enumerated().filter { CGFloat($0.offset) != yAxisMarkIndex }.map { $0.element }

        let xPositionOfYMarks = xSymmetric ? xMin + (xMax - xMin) / 2 : xMin
        let yMarksCount: CGFloat = 5 // must be uneven
        let yDistance = (yMax - yMin) / (yMarksCount - 1)
        let xAxisMarkIndex: CGFloat = ySymmetric ? (yMarksCount - 1) / 2 : (yMarksCount - 1)
        let yPoints = stride(from: yMin, to: yMax+0.001, by: yDistance).enumerated().filter { CGFloat($0.offset) != xAxisMarkIndex }.map { $0.element }

        // Grid
        if drawGrid {
            // Vertical grid lines
            let verticalGridPath = CGMutablePath()
            for x in xPoints {
                verticalGridPath.move(to: .init(x: x, y: yMin))
                verticalGridPath.addLine(to: .init(x: x, y: yMax))
            }

            verticalGrid.path = verticalGridPath
            verticalGrid.fillColor = .none
            verticalGrid.strokeColor = Self.gridColor.cgColor
            verticalGrid.lineWidth = gridLineWidth

            if verticalGrid.superlayer == nil { layer.addSublayer(verticalGrid) }

            // Horizontal grid lines
            let horizontalGridPath = CGMutablePath()
            for y in yPoints {
                horizontalGridPath.move(to: .init(x: xMin, y: y))
                horizontalGridPath.addLine(to: .init(x: xMax, y: y))
            }

            horizontalGrid.path = horizontalGridPath
            horizontalGrid.fillColor = .none
            horizontalGrid.strokeColor = Self.gridColor.cgColor
            horizontalGrid.lineWidth = gridLineWidth

            if horizontalGrid.superlayer == nil { layer.addSublayer(horizontalGrid) }
        }

        // Marks
        if drawAxisMarks {
            let markLength = relativeAxisMarksLength * frame.width

            // X axis marks
            let xAxisPath = CGMutablePath()
            for x in xPoints {
                xAxisPath.move(to: .init(x: x, y: yPositionOfXMarks-markLength/2))
                xAxisPath.addLine(to: .init(x: x, y: yPositionOfXMarks+markLength/2))
            }

            xAxisMarks.path = xAxisPath
            xAxisMarks.fillColor = .none
            xAxisMarks.strokeColor = Self.lineColor.cgColor
            xAxisMarks.lineWidth = lineWidth
            if xAxisMarks.superlayer == nil { layer.addSublayer(xAxisMarks) }

            // Y axis marks
            let yAxisPath = CGMutablePath()
            for y in yPoints {
                yAxisPath.move(to: .init(x: xPositionOfYMarks-markLength/2, y: y))
                yAxisPath.addLine(to: .init(x: xPositionOfYMarks+markLength/2, y: y))
            }

            yAxisMarks.path = yAxisPath
            yAxisMarks.fillColor = .none
            yAxisMarks.strokeColor = Self.lineColor.cgColor
            yAxisMarks.lineWidth = lineWidth
            if yAxisMarks.superlayer == nil { layer.addSublayer(yAxisMarks) }
        }
    }

    private func setupView() {
        xAxis.translatesAutoresizingMaskIntoConstraints = false
        yAxis.translatesAutoresizingMaskIntoConstraints = false
        xAxisArrow.translatesAutoresizingMaskIntoConstraints = false
        yAxisArrow.translatesAutoresizingMaskIntoConstraints = false

        xAxisWidthConstraint = xAxis.widthAnchor.constraint(equalToConstant: frame.width)
        xAxisHeightConstraint = xAxis.heightAnchor.constraint(equalToConstant: lineWidth)
        yAxisWidthConstraint = yAxis.widthAnchor.constraint(equalToConstant: lineWidth)
        yAxisHeightConstraint = yAxis.heightAnchor.constraint(equalToConstant: frame.height)

        xAxisCenterYConstraint = xAxis.centerYAnchor.constraint(equalTo: topAnchor, constant: 0)
        yAxisCenterXConstraint = yAxis.centerXAnchor.constraint(equalTo: leftAnchor, constant: 0)

        xAxis.backgroundColor = Self.lineColor
        yAxis.backgroundColor = Self.lineColor
        xAxisArrow.backgroundColor = .clear
        yAxisArrow.backgroundColor = .clear

        drawArrows()
        drawAxisMarksAndGrid()

        addSubview(xAxis)
        addSubview(yAxis)
        addSubview(xAxisArrow)
        addSubview(yAxisArrow)

        let constraints = [
            xAxisHeightConstraint!,
            yAxisWidthConstraint!,
            yAxisHeightConstraint!,
            xAxisWidthConstraint!,
            xAxisCenterYConstraint!,
            yAxisCenterXConstraint!,
            yAxisArrow.widthAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            yAxisArrow.heightAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            xAxisArrow.widthAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            xAxisArrow.heightAnchor.constraint(equalTo: widthAnchor, multiplier: relativeArrowWidth),
            yAxisArrow.centerXAnchor.constraint(equalTo: yAxis.centerXAnchor),
            yAxisArrow.topAnchor.constraint(equalTo: topAnchor),
            xAxisArrow.rightAnchor.constraint(equalTo: rightAnchor),
            xAxisArrow.centerYAnchor.constraint(equalTo: xAxis.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
