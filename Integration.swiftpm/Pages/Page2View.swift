
import Combine
import SwiftUI

enum Page2Action {
    case showFunction1
    case showFunction2
    case showFunction3
    case showIntegral1
    case showIntegral2
    case showIntegral3
}

struct Page2View: View {
    let actionPublisher = PassthroughSubject<Page2Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("Fundamentals: **Functions and Integrals** 👨‍🏫").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page2ExplanationView(actionPublisher: actionPublisher),
            actionView: Page2ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page2ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page2Action, Never>

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("Let's start with some fundamentals: *What is a function? What is an integral?* 🤔\n\nIn simple terms, a function **assigns a certain value for each point for which it is defined**. Fortunately, we can understand 2D-functions via their visualizations. Try out some:").multilineTextAlignment(.center)
            HStack {
                Spacer()
                Button("**1**") { actionPublisher.send(.showFunction1) }.buttonStyle(NonFilledCircleButtonStyle())
                Button("**2**") { actionPublisher.send(.showFunction2) }.buttonStyle(NonFilledCircleButtonStyle())
                Button("**3**") { actionPublisher.send(.showFunction3) }.buttonStyle(NonFilledCircleButtonStyle())
                Spacer()
            }
            Text("And the integral? It's just the **area between the function and the horizontal axis** (areas below contributing negatively). Have a look at the integrals of our three functions:").multilineTextAlignment(.center)
            HStack {
                Spacer()
                Button("**1**") { actionPublisher.send(.showIntegral1) }.buttonStyle(NonFilledCircleButtonStyle())
                Button("**2**") { actionPublisher.send(.showIntegral2) }.buttonStyle(NonFilledCircleButtonStyle())
                Button("**3**") { actionPublisher.send(.showIntegral3) }.buttonStyle(NonFilledCircleButtonStyle())
                Spacer()
            }
            Text("When you're confident to have a basic understanding, proceed to the next page! ➡️").multilineTextAlignment(.center)
        }
    }
}

struct Page2ActionView: View {
    let actionPublisher: AnyPublisher<Page2Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page2ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page2ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    static let definitionRange: FunctionRange = .fromZeroTo(max: 2)
    static let valueRange: FunctionRange = .symmetric(max: 2)
    static var function1: Function { Function(definitionRange: definitionRange, valueRange: valueRange, valueForX: { 2 * pow($0 - 1, 3) } ) }
    static var function2: Function { Function(definitionRange: definitionRange, valueRange: valueRange, valueForX: { 1.5 * cos(2*Double.pi*$0) } ) }
    static var function3: Function { Function(definitionRange: definitionRange, valueRange: valueRange, valueForX: { 4 / (1 + pow(4, -5*($0-1))) - 2 } ) }

    init(actionPublisher: AnyPublisher<Page2Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case .showFunction1:
                Self.functionViewController?.draw(function: Self.function1, animationDuration: 1)
                Self.functionViewController?.draw(integral: .none, animationDuration: 0, delay: 0)

            case .showFunction2:
                Self.functionViewController?.draw(function: Self.function2, animationDuration: 1)
                Self.functionViewController?.draw(integral: .none, animationDuration: 0, delay: 0)

            case .showFunction3:
                Self.functionViewController?.draw(function: Self.function3, animationDuration: 1)
                Self.functionViewController?.draw(integral: .none, animationDuration: 0, delay: 0)

            case .showIntegral1:
                Self.functionViewController?.draw(function: Self.function1, animationDuration: 1)
                Self.functionViewController?.draw(integral: .analytical, animationDuration: 1, delay: 1)

            case .showIntegral2:
                Self.functionViewController?.draw(function: Self.function2, animationDuration: 1)
                Self.functionViewController?.draw(integral: .analytical, animationDuration: 1, delay: 1)

            case .showIntegral3:
                Self.functionViewController?.draw(function: Self.function3, animationDuration: 1)
                Self.functionViewController?.draw(integral: .analytical, animationDuration: 1, delay: 1)
            }
        }
    }

    func makeUIViewController(context: Context) -> FunctionViewController {
        Self.functionViewController = FunctionViewController(function: Self.function1)
        return Self.functionViewController!
    }

    func updateUIViewController(_ uiViewController: FunctionViewController, context: Context) { }
    static func dismantleUIViewController(_ uiViewController: FunctionViewController, coordinator: ()) { }
}
