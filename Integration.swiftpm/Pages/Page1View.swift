
import Combine
import SwiftUI

enum Page1Action {
    case firstButtonPressed
    case secondButtonPressed
    case thirdButtonPressed
}

struct Page1View: View {
    let actionPublisher = PassthroughSubject<Page1Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("Welcome to a quick course on **integration** 🚀").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page1ExplanationView(actionPublisher: actionPublisher),
            actionView: Page1ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page1ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page1Action, Never>

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("Welcome to this educational app! 👋\n\nOn the following pages, you will learn about the concept of **mathematical integration** and especially how it is realized in computers: with **numerical integration**.\n\nOn the left side of the screen, you will always find explanations and controls, while the right side shows some visualizations.\n\nTo get a **sneak peak** of what visualizations will await you in the next minutes, try out the three buttons:").multilineTextAlignment(.center)
            HStack {
                Spacer()
                Button("**1**") { actionPublisher.send(.firstButtonPressed) }.buttonStyle(NonFilledCircleButtonStyle())
                Button("**2**") { actionPublisher.send(.secondButtonPressed) }.buttonStyle(NonFilledCircleButtonStyle())
                Button("**3**") { actionPublisher.send(.thirdButtonPressed) }.buttonStyle(NonFilledCircleButtonStyle())
                Spacer()
            }
            Text("When you're ready to embark the adventure, proceed to the next page! ➡️").multilineTextAlignment(.center)
        }
    }
}

struct Page1ActionView: View {
    let actionPublisher: AnyPublisher<Page1Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page1ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page1ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    init(actionPublisher: AnyPublisher<Page1Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case .firstButtonPressed:
                let function = Function(
                    definitionRange: .symmetric(max: 1),
                    valueRange: .symmetric(max: 2),
                    valueForX: { 2 * $0 - 0.5 }
                )

                Self.functionViewController?.draw(function: function, animationDuration: 1)
                Self.functionViewController?.draw(integral: .midpoint(numberOfParts: 3), animationDuration: 1, delay: 1)

            case .secondButtonPressed:
                let function = Function(
                    definitionRange: .symmetric(max: 1),
                    valueRange: .symmetric(max: 2),
                    valueForX: { 2 * sin(Double.pi*2*$0) }
                )

                Self.functionViewController?.draw(function: function, animationDuration: 1)
                Self.functionViewController?.draw(integral: .analytical, animationDuration: 1, delay: 1)

            case .thirdButtonPressed:
                let function = Function(
                    definitionRange: .symmetric(max: 1),
                    valueRange: .symmetric(max: 2),
                    valueForX: { 2 * pow($0, 3) }
                )

                Self.functionViewController?.draw(function: function, animationDuration: 1)
                Self.functionViewController?.draw(integral: .trapezoidal(numberOfParts: 6), animationDuration: 1, delay: 1)
            }
        }
    }

    func makeUIViewController(context: Context) -> FunctionViewController {
        let function = Function(
            definitionRange: .symmetric(max: 1),
            valueRange: .symmetric(max: 2),
            valueForX: { 2 * pow($0, 3) }
        )
        Self.functionViewController = FunctionViewController(function: function)

        return Self.functionViewController!
    }

    func updateUIViewController(_ uiViewController: FunctionViewController, context: Context) { }
    static func dismantleUIViewController(_ uiViewController: FunctionViewController, coordinator: ()) { }
}
