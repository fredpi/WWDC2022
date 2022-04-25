
import UIKit

class FunctionViewController: UIViewController {
    // MARK: - Properties: UI
    private let diagramView: DiagramView
    private let coordinateView: CoordinateView

    // MARK: Constraints
    private var diagramViewLeftAnchorConstraint: NSLayoutConstraint!
    private var diagramViewTopAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewLeftAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewRightAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewTopAnchorConstraint: NSLayoutConstraint!
    private var coordinateViewBottomAnchorConstraint: NSLayoutConstraint!

    // MARK: Constants
    private let sizeFactor: CGFloat = 0.85
    private let leftMarginShare: CGFloat = 1 / 3
    private let relativeCoordinateViewLeftRightMargin: CGFloat = 0.0
    private let relativeCoordinateViewTopBottomMargin: CGFloat = 0.0
    private let relativeCornerRadius: CGFloat = 0.02
    private let containerViewRelativeMarging: CGFloat = 0.05
    private let relativeLineWidth: CGFloat = 0.002
    private var lineWidth: CGFloat { min(2, max(1.5, relativeLineWidth*view.frame.width)) }

    // MARK: - Initializers
    init(function: Function) {
        diagramView = DiagramView(function: function)
        coordinateView = CoordinateView(definitionRange: function.definitionRange, valueRange: function.valueRange, sizeFactor: sizeFactor, leftMarginShare: leftMarginShare)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Unavailable!")
    }

    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let width = view.frame.width

        coordinateViewLeftAnchorConstraint.constant = relativeCoordinateViewLeftRightMargin * width
        coordinateViewRightAnchorConstraint.constant = relativeCoordinateViewLeftRightMargin * width
        coordinateViewTopAnchorConstraint.constant = relativeCoordinateViewTopBottomMargin * width
        coordinateViewBottomAnchorConstraint.constant = relativeCoordinateViewTopBottomMargin * width

        diagramViewLeftAnchorConstraint.constant = (1 - sizeFactor) * leftMarginShare * coordinateView.frame.width
        diagramViewTopAnchorConstraint.constant = (1 - sizeFactor) * (1 - leftMarginShare) * coordinateView.frame.height
    }

    // MARK: Interface
    func draw(integral: Integral?, animationDuration: Double = 1, delay: Double = 0) {
        diagramView.draw(integral: integral, animationDuration: animationDuration, delay: delay)
    }

    func draw(function: Function, animationDuration: Double = 1, delay: Double = 0) {
        diagramView.draw(function: function, animationDuration: animationDuration, delay: delay)
    }

    // MARK: View Setup
    private func setupView() {
        // Only setup once
        guard view.subviews.isEmpty else { return }

        // Disable autoresizing mask
        coordinateView.translatesAutoresizingMaskIntoConstraints = false
        diagramView.translatesAutoresizingMaskIntoConstraints = false

        // Add views
        view.addSubview(coordinateView)
        view.addSubview(diagramView)

        // Define fixed constraints
        diagramViewLeftAnchorConstraint = diagramView.leftAnchor.constraint(equalTo: coordinateView.leftAnchor, constant: 0)
        diagramViewTopAnchorConstraint = diagramView.topAnchor.constraint(equalTo: coordinateView.topAnchor, constant: 0)

        coordinateViewLeftAnchorConstraint = coordinateView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        coordinateViewRightAnchorConstraint = view.rightAnchor.constraint(equalTo: coordinateView.rightAnchor, constant: 0)
        coordinateViewTopAnchorConstraint = coordinateView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        coordinateViewBottomAnchorConstraint = view.bottomAnchor.constraint(equalTo: coordinateView.bottomAnchor, constant: 0)

        let constraints = [
            // Container View
            coordinateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coordinateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coordinateViewLeftAnchorConstraint!,
            coordinateViewRightAnchorConstraint!,
            coordinateViewTopAnchorConstraint!,
            coordinateViewBottomAnchorConstraint!,

            // Constraint diagram view
            diagramViewLeftAnchorConstraint!,
            diagramViewTopAnchorConstraint!,
            diagramView.heightAnchor.constraint(equalTo: coordinateView.heightAnchor, multiplier: sizeFactor),
            diagramView.widthAnchor.constraint(equalTo: coordinateView.widthAnchor, multiplier: sizeFactor)
        ]

        NSLayoutConstraint.activate(constraints)
    }
}
