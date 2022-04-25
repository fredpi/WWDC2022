
import Combine
import SwiftUI

enum Page7Action {
    case present(numberOfParts: Int)
}

struct Page7View: View {
    let actionPublisher = PassthroughSubject<Page7Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("**Simpson's Rule** Integration 🍩").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page7ExplanationView(actionPublisher: actionPublisher),
            actionView: Page7ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page7ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page7Action, Never>
    @State private var numberOfParts: Double = 1

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("We now approximate each section of our function as a **parabola** (instead of just a constant or linear function), expecting better results while everything is still quite easy to compute. This is called **Simpson's Rule Integration**.\n\nTry it out:").multilineTextAlignment(.center)
            Slider(value: $numberOfParts, in: 1...10, step: 1, minimumValueLabel: Text("1"), maximumValueLabel: Text("10"), label: { })
            Button("**Draw with \(Int(numberOfParts)) section\(numberOfParts == 1 ? "" : "s")**") { actionPublisher.send(.present(numberOfParts: Int(numberOfParts))) }.buttonStyle(NonFilledCapsuleButtonStyle()).animation(.easeOut(duration: 0.3), value: numberOfParts)
            Text("As this is the same function as the \"other\" function on the last page, you can go back there to see how much better **Simpson's Rule** performs.\n\nThen proceed to the final page, where we'll wrap up this quick course! ➡️").multilineTextAlignment(.center)
        }
    }
}

struct Page7ActionView: View {
    let actionPublisher: AnyPublisher<Page7Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page7ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page7ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    static var functionIsDrawn: Bool = false
    static let definitionRange: FunctionRange = .fromZeroTo(max: 1)
    static let valueRange: FunctionRange = .fromZeroTo(max: 1)
    static var function1: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { x in
                let varianceSquare: Double = 0.01
                let mean: Double = 0.5
                return 0.75 * exp(-0.5 * pow(x-mean, 2)/varianceSquare) + 0.25
            }
        )
    }

    init(actionPublisher: AnyPublisher<Page7Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case .present(let numberOfParts):
                var delay: Double = 0
                if !Self.functionIsDrawn {
                    Self.functionIsDrawn = true
                    delay = 1
                    Self.functionViewController?.draw(function: Self.function1, animationDuration: 1)
                }

                Self.functionViewController?.draw(integral: .simpson(numberOfParts: numberOfParts), animationDuration: 1, delay: delay)
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
