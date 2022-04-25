
import Combine
import SwiftUI

enum Page5Action {
    case present(numberOfParts: Int)
}

struct Page5View: View {
    let actionPublisher = PassthroughSubject<Page5Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("**Midpoint** Integration 📊").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page5ExplanationView(actionPublisher: actionPublisher),
            actionView: Page5ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page5ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page5Action, Never>
    @State private var numberOfParts: Double = 2

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Text("The simplest method to do numerical integration is **midpoint integration**: With it, the function is **approximated as a constant** function. Try it out:").multilineTextAlignment(.center)
            Button("**Draw**") { actionPublisher.send(.present(numberOfParts: 1)) }.buttonStyle(NonFilledCapsuleButtonStyle())
            Text("As you see, we get quite a big error. One principle to improve on that is to **divide the function into different sections** that are approximated independently.").multilineTextAlignment(.center)
            Slider(value: $numberOfParts, in: 1...10, step: 1, minimumValueLabel: Text("1"), maximumValueLabel: Text("10"), label: { })
            Button("**Draw with \(Int(numberOfParts)) section\(numberOfParts == 1 ? "" : "s")**") { actionPublisher.send(.present(numberOfParts: Int(numberOfParts))) }.buttonStyle(NonFilledCapsuleButtonStyle()).animation(.easeOut(duration: 0.3), value: numberOfParts)
            Text("Keep this principle in mind and proceed to the next page! ➡️").multilineTextAlignment(.center)
        }
    }
}

struct Page5ActionView: View {
    let actionPublisher: AnyPublisher<Page5Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page5ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page5ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    static var functionIsDrawn: Bool = false
    static let definitionRange: FunctionRange = .fromZeroTo(max: 1)
    static let valueRange: FunctionRange = .fromZeroTo(max: 1)
    static var function1: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { sqrt($0) }
        )
    }

    init(actionPublisher: AnyPublisher<Page5Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case .present(let numberOfParts):
                var delay: Double = 0
                if !Self.functionIsDrawn {
                    Self.functionIsDrawn = true
                    delay = 1
                    Self.functionViewController?.draw(function: Self.function1, animationDuration: 1)
                }

                Self.functionViewController?.draw(integral: .midpoint(numberOfParts: numberOfParts), animationDuration: 1, delay: delay)
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
