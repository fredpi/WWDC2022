
import Combine
import SwiftUI

enum Page8Function: Int, Identifiable, CaseIterable {
    case sine
    case sinc
    case cubic
    case arbitraryPolynomial
    case logistic
    case normalDist

    var id: String { "\(rawValue)" }

    var asString: String {
        switch self {
        case .sine:
            return "Sine Function"

        case .sinc:
            return "Sinc Function"

        case .logistic:
            return "Logistic Function"

        case .normalDist:
            return "Normal Distribution Function"

        case .cubic:
            return "Cubic Function"

        case .arbitraryPolynomial:
            return "Arbitrary Polynomial"
        }
    }
}

enum Page8Integral: Int, Identifiable, CaseIterable {
    case analytical
    case midpoint
    case trapezoidal
    case simpson
    case none

    var id: String { "\(rawValue)" }

    var asString: String {
        switch self {
        case .none:
            return "No Integration"

        case .analytical:
            return "Correct Integration"

        case .midpoint:
            return "Midpoint Integration"

        case .trapezoidal:
            return "Trapezoidal Integration"

        case .simpson:
            return "Simpson's Rule Integration"
        }
    }
}

enum Page8Action {
    case show(function: Page8Function, integral: Page8Integral, numberOfParts: Int)
}

struct Page8View: View {
    let actionPublisher = PassthroughSubject<Page8Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("Wrap up 🏁").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page8ExplanationView(actionPublisher: actionPublisher),
            actionView: Page8ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page8ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page8Action, Never>
    @State private var function: Page8Function = .sine
    @State private var integral: Page8Integral = .analytical
    @State private var numberOfParts: Double = 1

    var shouldShowPartSettings: Bool { integral != .analytical && integral != .none }

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack { Spacer() }
            Text("There's so much more to discover, but time is running out. I hope that this app has given you a good impression of what **(numerical) integration** is. 😃\n\nFeel free to select and try out some more functions and integrals:").multilineTextAlignment(.center)
            Menu {
                Picker(selection: $function) {
                    ForEach(Page8Function.allCases) { function in
                        Text(function.asString).tag(function)
                    }
                } label: {}
            } label: {
                Text("**\(function.asString)**").foregroundColor(.blue).padding().overlay(Capsule().stroke(.blue, lineWidth: 2))
            }
            Menu {
                Picker(selection: $integral) {
                    ForEach(Page8Integral.allCases) { integral in
                        Text(integral.asString).tag(integral)
                    }
                } label: {}
            } label: {
                Text("**\(integral.asString)**").foregroundColor(.blue).padding().overlay(Capsule().stroke(.blue, lineWidth: 2))
            }
            if shouldShowPartSettings {
                Slider(value: $numberOfParts, in: 1...10, step: 1, minimumValueLabel: Text("1"), maximumValueLabel: Text("10"), label: { })
            }
            Text("And don't forget to start the drawing. 🤓").multilineTextAlignment(.center)
            Button("**Draw\(shouldShowPartSettings ? " with \(Int(numberOfParts)) section\(numberOfParts == 1 ? "" : "s")" : "")**") { actionPublisher.send(.show(function: function, integral: integral, numberOfParts: Int(numberOfParts))) }.buttonStyle(NonFilledCapsuleButtonStyle()).animation(.easeOut(duration: 0.3), value: numberOfParts)
            Text("Goodbye! 👋").multilineTextAlignment(.center)
        }.transition(.slide).animation(.easeInOut, value: integral)
    }
}

struct Page8ActionView: View {
    let actionPublisher: AnyPublisher<Page8Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page8ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page8ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    static let definitionRange: FunctionRange = .symmetric(max: 1)
    static let valueRange: FunctionRange = .symmetric(max: 1)
    static var sineFunction: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { sin(Double.pi*2*$0) }
        )
    }

    static var sincFunction: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { $0 == 0 ? 1 : sin(Double.pi*5*$0)/(Double.pi*5*$0) }
        )
    }

    static var normalDistFunction: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { exp(-0.5 * pow($0-0, 2)/0.1) }
        )
    }

    static var logisticFunction: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { 2 / (1 + pow(4, -5*($0))) - 1 }
        )
    }

    static var cubicFunction: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { pow($0, 3) }
        )
    }

    static var arbitraryPolynomial: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { 3 * pow($0, 4) - 1.5 * pow($0, 3) - 2 * pow($0, 2) + $0 }
        )
    }

    init(actionPublisher: AnyPublisher<Page8Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case let .show(page8Function, page8Integral, numberOfParts):
                let function: Function
                switch page8Function {
                case .sine:
                    function = Self.sineFunction

                case .sinc:
                    function = Self.sincFunction

                case .logistic:
                    function = Self.logisticFunction

                case .normalDist:
                    function = Self.normalDistFunction

                case .cubic:
                    function = Self.cubicFunction

                case .arbitraryPolynomial:
                    function = Self.arbitraryPolynomial
                }

                let integral: Integral?
                switch page8Integral {
                case .none:
                    integral = nil

                case .analytical:
                    integral = .analytical

                case .midpoint:
                    integral = .midpoint(numberOfParts: numberOfParts)

                case .trapezoidal:
                    integral = .trapezoidal(numberOfParts: numberOfParts)

                case .simpson:
                    integral = .simpson(numberOfParts: numberOfParts)
                }

                Self.functionViewController?.draw(function: function, animationDuration: 1)
                Self.functionViewController?.draw(integral: integral, animationDuration: 1, delay: 1)
            }
        }
    }

    func makeUIViewController(context: Context) -> FunctionViewController {
        Self.functionViewController = FunctionViewController(function: Self.sineFunction)
        return Self.functionViewController!
    }

    func updateUIViewController(_ uiViewController: FunctionViewController, context: Context) { }
    static func dismantleUIViewController(_ uiViewController: FunctionViewController, coordinator: ()) { }
}
