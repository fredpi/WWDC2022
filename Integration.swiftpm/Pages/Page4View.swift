
import Combine
import SwiftUI

enum Page4Action {
    case present
}

struct Page4View: View {
    let actionPublisher = PassthroughSubject<Page4Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("**Numerical** Integration 🧮").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page4ExplanationView(actionPublisher: actionPublisher),
            actionView: Page4ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page4ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page4Action, Never>

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("Now that you have understood what an integral is, it's time to face the problem:\n\nFor some functions, a correct analytical calculation of the integral is **too computationally heavy or even not possible at all**.\n\nWhat to do? **Numerical integration** to the rescue! With it, the function to integrate is **approximated as a simple function**, the integral of which is easy to compute.\n\nCompare the correct integral of an example function with a *(very roughly)* approximated integral of triangular shape:").multilineTextAlignment(.center)
            Button("**Compare**") { actionPublisher.send(.present) }.buttonStyle(NonFilledCapsuleButtonStyle())
            Text("On the next pages you will learn more about numerical integration! ➡️").multilineTextAlignment(.center)
        }
    }
}

struct Page4ActionView: View {
    let actionPublisher: AnyPublisher<Page4Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page4ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page4ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    static let definitionRange: FunctionRange = .symmetric(max: 1)
    static let valueRange: FunctionRange = .fromZeroTo(max: 2)
    static var function1: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { $0 < 0 ? pow($0, 3) + 1 : pow($0, 9) + 1 }
        )
    }

    static var functionIsDrawn: Bool = false

    init(actionPublisher: AnyPublisher<Page4Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case .present:
                guard !Self.functionIsDrawn else { return } // Only allow to call once
                Self.functionIsDrawn = true
                Self.functionViewController?.draw(integral: nil)
                Self.functionViewController?.draw(function: Self.function1, animationDuration: 0.5)

                func loop(stopAfter: Int) {
                    Self.functionViewController?.draw(integral: .analytical, animationDuration: 0.5, delay: 0)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        Self.functionViewController?.draw(integral: .trapezoidal(numberOfParts: 1), animationDuration: 0.5, delay: 0)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                            if stopAfter == 1 {
                                Self.functionIsDrawn = false
                            } else {
                                loop(stopAfter: stopAfter - 1)
                            }
                        }
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { loop(stopAfter: 10) }
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
