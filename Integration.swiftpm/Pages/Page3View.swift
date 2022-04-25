
import Combine
import SwiftUI

enum Page3Action {
    case showFunctionAndIntegral
}

struct Page3View: View {
    let actionPublisher = PassthroughSubject<Page3Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("But **why** exactly do we need integrals? 🤔").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page3ExplanationView(actionPublisher: actionPublisher),
            actionView: Page3ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page3ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page3Action, Never>

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("It would take an entire lecture series to answer the question, **for which practical (and theoretical) applications integrals are needed**.\n\nBut to give an intuition, here's just one simple application: Consider you want to **build a church window** whose shape is described by a function.\n\nNow, the integral **gives the amount of glass** you will need to build it. Try it out:").multilineTextAlignment(.center)
            Button("**Draw**") { actionPublisher.send(.showFunctionAndIntegral) }.buttonStyle(NonFilledCapsuleButtonStyle())
            Text("Now, back to the main story: Proceed to the next page! ➡️").multilineTextAlignment(.center)
        }
    }
}

struct Page3ActionView: View {
    let actionPublisher: AnyPublisher<Page3Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page3ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page3ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    static let definitionRange: FunctionRange = .fromZeroTo(max: 1)
    static let valueRange: FunctionRange = .fromZeroTo(max: 1)
    static var function1: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { x in
                let x = x > 0.5 ? (1 - x) : x
                if x < 0.25 {
                    return 0
                } else {
                    return 0.625 + 1.5 * sqrt(0.0625 - pow((0.5-x), 2))
                }
            }
        )
    }

    init(actionPublisher: AnyPublisher<Page3Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case .showFunctionAndIntegral:
                Self.functionViewController?.draw(function: Self.function1, animationDuration: 1)
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
