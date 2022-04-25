
import UIKit

class DiagramView: UIView {
    // MARK: - Properties
    private var integral: Integral?
    private var function: Function
    private let relativeLineWidth: CGFloat = 0.006
    private var lineWidth: CGFloat { min(3.5, max(1.5, relativeLineWidth*frame.width)) }
    private let functionLayer = CAShapeLayer()
    private let integralLayer = CAShapeLayer()
    private let integralLayerMask = CAShapeLayer()

    private var functionRenderPlan: RenderPlan? { didSet { manageRenderingPlans() } }
    private var integralRenderPlan: RenderPlan? { didSet { manageRenderingPlans() } }

    private var firstFunctionPointX: CGFloat = 0
    private var lastFunctionPointX: CGFloat = 0

    var displayLink: CADisplayLink!

    // MARK: - Initializers
    init(function: Function) {
        self.function = function
        super.init(frame: .zero)
        displayLink = CADisplayLink(target: self, selector: #selector(manageRenderingPlans))
        displayLink.add(to: .current, forMode: .common)
        draw()
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        draw()
    }

    func draw(integral: Integral?, animationDuration: Double = 1, delay: Double = 0) {
        self.integral = integral
        integralRenderPlan = .init(start: CFAbsoluteTimeGetCurrent() + delay, end: CFAbsoluteTimeGetCurrent() + delay + animationDuration)
        draw()
    }

    func draw(function: Function, animationDuration: Double = 1, delay: Double = 0) {
        guard function.valueRange == self.function.valueRange && function.definitionRange == self.function.definitionRange else {
            fatalError("Changing the definition range and / or the value range retrospectively is illegal")
        }

        self.function = function
        functionRenderPlan = .init(start: CFAbsoluteTimeGetCurrent() + delay, end: CFAbsoluteTimeGetCurrent() + delay + animationDuration)
        draw()
    }

    private func draw() {
        let width = frame.width
        let height = frame.height
        guard width > 0, height > 0 else { return }

        let scale = UIScreen.main.scale
        let pixels = Int(frame.width * scale)

        let points: [CGPoint] = (0...pixels).compactMap { pixel -> CGPoint? in
            guard let yPercentage = function.yPercentage(xPercentage: Double(pixel) / Double(pixels)) else { return nil }

            return CGPoint(
                x: Double(pixel) / scale,
                y: height * (1 - yPercentage)
            )
        }

        firstFunctionPointX = points.first!.x
        lastFunctionPointX = points.last!.x

        let functionColor: UIColor = .systemRed
        let integralColor: UIColor = .systemIndigo

        switch integral {
        case .some(.analytical):
            renderIntegral(
                functionPoints: points,
                functionYPercentageAtZero: function.yPercentageAtZero,
                in: integralColor,
                on: integralLayer,
                withMask: integralLayerMask,
                pixels: pixels,
                scale: scale,
                width: width,
                height: height
            )

        case .some(.midpoint(let numberOfParts)):
            renderMidpointIntegral(
                numberOfParts: numberOfParts,
                functionPoints: points,
                functionYPercentageAtZero: function.yPercentageAtZero,
                in: integralColor,
                on: integralLayer,
                withFunctionLayer: functionLayer,
                withMask: integralLayerMask,
                pixels: pixels,
                scale: scale,
                width: width,
                height: height
            )

        case .some(.trapezoidal(let numberOfParts)):
            renderTrapezoidalIntegral(
                numberOfParts: numberOfParts,
                functionPoints: points,
                functionYPercentageAtZero: function.yPercentageAtZero,
                in: integralColor,
                on: integralLayer,
                withFunctionLayer: functionLayer,
                withMask: integralLayerMask,
                pixels: pixels,
                scale: scale,
                width: width,
                height: height
            )

        case .some(.simpson(let numberOfParts)):
            renderSimpsonIntegral(
                numberOfParts: numberOfParts,
                functionPoints: points,
                functionYPercentageAtZero: function.yPercentageAtZero,
                in: integralColor,
                on: integralLayer,
                withFunctionLayer: functionLayer,
                withMask: integralLayerMask,
                pixels: pixels,
                scale: scale,
                width: width,
                height: height
            )

        case .none:
            renderNoIntegral(on: integralLayer)
        }

        render(functionPoints: points, in: functionColor, on: functionLayer, pixels: pixels, scale: scale, width: width, height: height)

        manageRenderingPlans()
    }

    @objc func manageRenderingPlans() {
        let height = frame.height
        guard height > 0 else { return }
        let now = CFAbsoluteTimeGetCurrent()

        let functionRenderingProgress: Double
        if let functionRenderPlan = functionRenderPlan {
            functionRenderingProgress = min(max((now - functionRenderPlan.start) / (functionRenderPlan.end + 0.000001 - functionRenderPlan.start), 0), 1)
        } else {
            functionRenderingProgress = 0
        }

        let integralRenderingProgress: Double
        if let integralRenderPlan = integralRenderPlan {
            integralRenderingProgress = min(max((now - integralRenderPlan.start) / (integralRenderPlan.end + 0.000001 - integralRenderPlan.start), 0), 1)
        } else {
            integralRenderingProgress = 0
        }

        functionLayer.strokeEnd = functionRenderingProgress
        set(progress: integralRenderingProgress, on: integralLayerMask, height: height)

        let needsDisplayLink: Bool = functionRenderingProgress < 1 && functionRenderPlan != nil || integralRenderingProgress < 1 && integralRenderPlan != nil

        if needsDisplayLink && displayLink.isPaused {
            displayLink.isPaused = false
        } else if !needsDisplayLink && !displayLink.isPaused {
            displayLink.isPaused = true
        }
    }

    private func set(progress: Double, on maskLayer: CAShapeLayer, height: CGFloat) {
        let spacing: CGFloat = 10
        let rect = CGRect(
            x: firstFunctionPointX - spacing,
            y: -1000,
            width: (lastFunctionPointX - firstFunctionPointX + 2 * spacing) * progress,
            height: height + 2000
        )

        maskLayer.path = CGPath(rect: rect, transform: nil)
    }

    private func render(
        functionPoints: [CGPoint],
        in color: UIColor,
        on drawingLayer: CAShapeLayer,
        pixels: Int,
        scale: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {
        let path = CGMutablePath()
        path.move(to: functionPoints.first!)
        _ = functionPoints.dropFirst()
        functionPoints.forEach { path.addLine(to: $0) }

        drawingLayer.path = path
        drawingLayer.lineWidth = lineWidth

        if drawingLayer.superlayer == nil {
            drawingLayer.strokeColor = color.cgColor
            drawingLayer.fillColor = .none
            drawingLayer.zPosition = 10
            drawingLayer.disableAnimations()
            layer.addSublayer(drawingLayer)
        }
    }

    private func renderNoIntegral(on drawingLayer: CAShapeLayer) {
        // Integral
        let path = CGMutablePath()
        drawingLayer.path = path

        // Knob layer
        let knobLayer: CAShapeLayer
        if let firstSublayer = functionLayer.sublayers?.first as? CAShapeLayer {
            knobLayer = firstSublayer
        } else {
            knobLayer = CAShapeLayer()
            knobLayer.zPosition = 10
            functionLayer.addSublayer(knobLayer)
        }

        let knobPath = CGMutablePath()
        knobLayer.path = knobPath

        // Add to superlayer
        if drawingLayer.superlayer == nil {
            drawingLayer.disableAnimations()
            layer.addSublayer(drawingLayer)
        }
    }

    private func renderIntegral(
        functionPoints: [CGPoint],
        functionYPercentageAtZero: Double,
        in color: UIColor,
        on drawingLayer: CAShapeLayer,
        withMask maskLayer: CAShapeLayer,
        pixels: Int,
        scale: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {
        // Integral
        let path = CGMutablePath()
        let firstPoint = CGPoint(x: functionPoints.first!.x, y: height * (1 - functionYPercentageAtZero))
        path.move(to: firstPoint)
        functionPoints.forEach { path.addLine(to: $0) }
        path.addLine(to: CGPoint(x: functionPoints.last!.x, y: height * (1 - functionYPercentageAtZero)))
        path.addLine(to: firstPoint)

        drawingLayer.path = path
        drawingLayer.lineWidth = lineWidth / 2
        drawingLayer.mask = maskLayer

        // Knob layer
        let knobLayer: CAShapeLayer
        if let firstSublayer = functionLayer.sublayers?.first as? CAShapeLayer {
            knobLayer = firstSublayer
        } else {
            knobLayer = CAShapeLayer()
            knobLayer.zPosition = 10
            functionLayer.addSublayer(knobLayer)
        }

        let knobPath = CGMutablePath()
        knobLayer.path = knobPath

        // Add to superlayer
        if drawingLayer.superlayer == nil {
            drawingLayer.disableAnimations()
            layer.addSublayer(drawingLayer)
        }

        // Color
        knobLayer.fillColor = color.cgColor
        drawingLayer.strokeColor = color.cgColor
        drawingLayer.fillColor = color.withAlphaComponent(0.3).cgColor
    }

    private func renderMidpointIntegral(
        numberOfParts: Int,
        functionPoints: [CGPoint],
        functionYPercentageAtZero: Double,
        in color: UIColor,
        on drawingLayer: CAShapeLayer,
        withFunctionLayer functionLayer: CAShapeLayer,
        withMask maskLayer: CAShapeLayer,
        pixels: Int,
        scale: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {
        // Integral
        let midpointIntegrals = partition(functionPoints: functionPoints, intoParts: numberOfParts).map { points -> MidpointIntegral in
            let mid = points[points.count / 2]
            return MidpointIntegral(
                xStart: points.first!.x,
                xEnd: points.last!.x,
                xMid: mid.x,
                yMid: mid.y
            )
        }

        let path = CGMutablePath()
        let firstPoint = CGPoint(x: functionPoints.first!.x, y: height * (1 - functionYPercentageAtZero))
        path.move(to: firstPoint)

        for midpointIntegral in midpointIntegrals {
            path.addLine(to: CGPoint(x: midpointIntegral.xStart, y: height * (1 - functionYPercentageAtZero)))
            path.addLine(to: CGPoint(x: midpointIntegral.xStart, y: midpointIntegral.yMid))
            path.addLine(to: CGPoint(x: midpointIntegral.xEnd, y: midpointIntegral.yMid))
            path.addLine(to: CGPoint(x: midpointIntegral.xEnd, y: height * (1 - functionYPercentageAtZero)))
        }

        path.addLine(to: firstPoint)

        drawingLayer.path = path
        drawingLayer.lineWidth = lineWidth / 2
        drawingLayer.mask = maskLayer

        // Knob layer
        let knobLayer: CAShapeLayer
        if let firstSublayer = functionLayer.sublayers?.first as? CAShapeLayer {
            knobLayer = firstSublayer
        } else {
            knobLayer = CAShapeLayer()
            knobLayer.zPosition = 10
            functionLayer.addSublayer(knobLayer)
        }

        let knobPath = CGMutablePath()
        for midpointIntegral in midpointIntegrals {
            let widthAndHeight = lineWidth * 4
            knobPath.addEllipse(
                in: CGRect(
                    x: midpointIntegral.xMid - widthAndHeight / 2,
                    y: midpointIntegral.yMid - widthAndHeight / 2,
                    width: widthAndHeight,
                    height: widthAndHeight
                )
            )
        }

        knobLayer.path = knobPath

        // Add to superlayer
        if drawingLayer.superlayer == nil {
            drawingLayer.disableAnimations()
            layer.addSublayer(drawingLayer)
        }

        // Color
        knobLayer.fillColor = color.cgColor
        drawingLayer.strokeColor = color.cgColor
        drawingLayer.fillColor = color.withAlphaComponent(0.3).cgColor
    }

    private func renderTrapezoidalIntegral(
        numberOfParts: Int,
        functionPoints: [CGPoint],
        functionYPercentageAtZero: Double,
        in color: UIColor,
        on drawingLayer: CAShapeLayer,
        withFunctionLayer functionLayer: CAShapeLayer,
        withMask maskLayer: CAShapeLayer,
        pixels: Int,
        scale: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {
        // Integral
        let trapezoidalIntegrals = partition(functionPoints: functionPoints, intoParts: numberOfParts).map { points -> TrapezoidalIntegral in
            return TrapezoidalIntegral(
                xStart: points.first!.x,
                yStart: points.first!.y,
                xEnd: points.last!.x,
                yEnd: points.last!.y
            )
        }

        let path = CGMutablePath()
        let firstPoint = CGPoint(x: functionPoints.first!.x, y: height * (1 - functionYPercentageAtZero))
        path.move(to: firstPoint)

        for trapezoidalIntegral in trapezoidalIntegrals {
            path.addLine(to: CGPoint(x: trapezoidalIntegral.xStart, y: height * (1 - functionYPercentageAtZero)))
            path.addLine(to: CGPoint(x: trapezoidalIntegral.xStart, y: trapezoidalIntegral.yStart))
            path.addLine(to: CGPoint(x: trapezoidalIntegral.xEnd, y: trapezoidalIntegral.yEnd))
            path.addLine(to: CGPoint(x: trapezoidalIntegral.xEnd, y: height * (1 - functionYPercentageAtZero)))
        }

        path.addLine(to: firstPoint)

        drawingLayer.path = path
        drawingLayer.lineWidth = lineWidth / 2
        drawingLayer.mask = maskLayer

        // Knob layer
        let knobLayer: CAShapeLayer
        if let firstSublayer = functionLayer.sublayers?.first as? CAShapeLayer {
            knobLayer = firstSublayer
        } else {
            knobLayer = CAShapeLayer()
            knobLayer.zPosition = 10
            functionLayer.addSublayer(knobLayer)
        }

        let knobPath = CGMutablePath()
        for trapezoidalIntegral in trapezoidalIntegrals {
            let widthAndHeight = lineWidth * 4
            knobPath.addEllipse(
                in: CGRect(
                    x: trapezoidalIntegral.xStart - widthAndHeight / 2,
                    y: trapezoidalIntegral.yStart - widthAndHeight / 2,
                    width: widthAndHeight,
                    height: widthAndHeight
                )
            )

            knobPath.addEllipse(
                in: CGRect(
                    x: trapezoidalIntegral.xEnd - widthAndHeight / 2,
                    y: trapezoidalIntegral.yEnd - widthAndHeight / 2,
                    width: widthAndHeight,
                    height: widthAndHeight
                )
            )
        }

        knobLayer.path = knobPath

        // Add to superlayer
        if drawingLayer.superlayer == nil {
            drawingLayer.disableAnimations()
            layer.addSublayer(drawingLayer)
        }

        // Color
        knobLayer.fillColor = color.cgColor
        drawingLayer.strokeColor = color.cgColor
        drawingLayer.fillColor = color.withAlphaComponent(0.3).cgColor
    }

    private func renderSimpsonIntegral(
        numberOfParts: Int,
        functionPoints: [CGPoint],
        functionYPercentageAtZero: Double,
        in color: UIColor,
        on drawingLayer: CAShapeLayer,
        withFunctionLayer functionLayer: CAShapeLayer,
        withMask maskLayer: CAShapeLayer,
        pixels: Int,
        scale: CGFloat,
        width: CGFloat,
        height: CGFloat
    ) {
        let simpsonIntegrals = partition(functionPoints: functionPoints, intoParts: numberOfParts).map { points -> SimpsonIntegral in
            let mid = points[points.count / 2]
            return SimpsonIntegral(
                xStart: points.first!.x,
                yStart: points.first!.y,
                xMid: mid.x,
                yMid: mid.y,
                xEnd: points.last!.x,
                yEnd: points.last!.y
            )
        }

        let path = CGMutablePath()
        let firstPoint = CGPoint(x: functionPoints.first!.x, y: height * (1 - functionYPercentageAtZero))
        path.move(to: firstPoint)

        for simpsonIntegral in simpsonIntegrals {
            path.addLine(to: CGPoint(x: simpsonIntegral.xStart, y: height * (1 - functionYPercentageAtZero)))
            path.addLine(to: CGPoint(x: simpsonIntegral.xStart, y: simpsonIntegral.yStart))

            let controlPoint = CGPoint(
                x: 2 * simpsonIntegral.xMid - 0.5 * simpsonIntegral.xStart - 0.5 * simpsonIntegral.xEnd,
                y: 2 * simpsonIntegral.yMid - 0.5 * simpsonIntegral.yStart - 0.5 * simpsonIntegral.yEnd
            )

            path.addQuadCurve(
                to: CGPoint(x: simpsonIntegral.xEnd, y: simpsonIntegral.yEnd),
                control: controlPoint
            )
            path.addLine(to: CGPoint(x: simpsonIntegral.xEnd, y: height * (1 - functionYPercentageAtZero)))
        }

        path.addLine(to: firstPoint)

        drawingLayer.path = path
        drawingLayer.lineWidth = lineWidth / 2
        drawingLayer.mask = maskLayer

        // Knob layer
        let knobLayer: CAShapeLayer
        if let firstSublayer = functionLayer.sublayers?.first as? CAShapeLayer {
            knobLayer = firstSublayer
        } else {
            knobLayer = CAShapeLayer()
            knobLayer.zPosition = 10
            functionLayer.addSublayer(knobLayer)
        }

        let knobPath = CGMutablePath()
        for simpsonIntegral in simpsonIntegrals {
            let widthAndHeight = lineWidth * 4
            knobPath.addEllipse(
                in: CGRect(
                    x: simpsonIntegral.xStart - widthAndHeight / 2,
                    y: simpsonIntegral.yStart - widthAndHeight / 2,
                    width: widthAndHeight,
                    height: widthAndHeight
                )
            )

            let midPointWidthAndHeight = lineWidth * 2.5
            knobPath.addEllipse(
                in: CGRect(
                    x: simpsonIntegral.xMid - midPointWidthAndHeight / 2,
                    y: simpsonIntegral.yMid - midPointWidthAndHeight / 2,
                    width: midPointWidthAndHeight,
                    height: midPointWidthAndHeight
                )
            )

            knobPath.addEllipse(
                in: CGRect(
                    x: simpsonIntegral.xEnd - widthAndHeight / 2,
                    y: simpsonIntegral.yEnd - widthAndHeight / 2,
                    width: widthAndHeight,
                    height: widthAndHeight
                )
            )
        }

        knobLayer.path = knobPath

        // Add to superlayer
        if drawingLayer.superlayer == nil {
            drawingLayer.disableAnimations()
            layer.addSublayer(drawingLayer)
        }

        // Color
        knobLayer.fillColor = color.cgColor
        drawingLayer.strokeColor = color.cgColor
        drawingLayer.fillColor = color.withAlphaComponent(0.3).cgColor
    }

    private func partition(functionPoints: [CGPoint], intoParts numberOfParts: Int) -> [[CGPoint]] {
        // Edge points are part of the partition to the left and the right
        let edgePointsCount = numberOfParts - 1
        let totalPointCount = Double(functionPoints.count + edgePointsCount)

        var lastValue = 0.0
        let counts: [Int] = (1...numberOfParts).reduce([]) { counts, index in
            let value = totalPointCount * Double(index) / Double(numberOfParts)
            let count = Int(round(value - lastValue))
            lastValue = round(value)
            return counts + [count]
        }

        return counts.enumerated().map { index, count in
            let firstIndex = (0..<index).reduce(0) { $0 + counts[$1] - 1 }
            let lastIndex = firstIndex + count - 1
            return Array(functionPoints[firstIndex...lastIndex])
        }
    }
}
