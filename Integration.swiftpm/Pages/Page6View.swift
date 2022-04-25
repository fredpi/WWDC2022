
import Combine
import SwiftUI

enum Page6Action {
    case present(numberOfParts: Int)
    case presentProblematicFunction(numberOfParts: Int)
}

struct Page6View: View {
    let actionPublisher = PassthroughSubject<Page6Action, Never>()

    var body: some View {
        PageContainerView(
            titleView: Text("**Trapezoidal** Integration 📐").font(.system(size: 35, weight: .light, design: .rounded)),
            explanationView: Page6ExplanationView(actionPublisher: actionPublisher),
            actionView: Page6ActionView(actionPublisher: actionPublisher.eraseToAnyPublisher())
        )
    }
}

struct Page6ExplanationView: View {
    let actionPublisher: PassthroughSubject<Page6Action, Never>
    @State private var numberOfParts: Double = 1

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("As you have seen, we can conceptually minimize the error by dividing our function into sections.\n\nAnother method to minimize the error is **trapezoidal integration**. With it, each section of the function is **approximated as a linear** function. Try it out:").multilineTextAlignment(.center)
            Slider(value: $numberOfParts, in: 1...10, step: 1, minimumValueLabel: Text("1"), maximumValueLabel: Text("10"), label: { })
            Button("**Draw with \(Int(numberOfParts)) section\(numberOfParts == 1 ? "" : "s")**") { actionPublisher.send(.present(numberOfParts: Int(numberOfParts))) }.buttonStyle(NonFilledCapsuleButtonStyle())
            Text("You can go back to the last page to see **how much better it performs**. But keep in mind that it may not be as good for every function:").multilineTextAlignment(.center)
            Button("**Draw other with \(Int(numberOfParts)) section\(numberOfParts == 1 ? "" : "s")**") { actionPublisher.send(.presentProblematicFunction(numberOfParts: Int(numberOfParts))) }.buttonStyle(NonFilledCapsuleButtonStyle()).animation(.easeOut(duration: 0.3), value: numberOfParts)
            Text("On the next page, we'll have a look at one more improvement! ➡️").multilineTextAlignment(.center)
        }
    }
}

struct Page6ActionView: View {
    let actionPublisher: AnyPublisher<Page6Action, Never>

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Page6ActionViewUIKit(actionPublisher: actionPublisher)
                Spacer()
            }
            Spacer()
            Spacer()
        }

    }
}

struct Page6ActionViewUIKit: UIViewControllerRepresentable {
    static var functionViewController: FunctionViewController?
    let subscriber: AnyCancellable

    static var functionIsDrawn: Bool = false
    static var problematicFunctionIsDrawn: Bool = false
    static let definitionRange: FunctionRange = .fromZeroTo(max: 1)
    static let valueRange: FunctionRange = .fromZeroTo(max: 1)
    static var function1: Function {
        Function(
            definitionRange: definitionRange,
            valueRange: valueRange,
            valueForX: { sqrt($0) }
        )
    }

    static var function2: Function {
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

    init(actionPublisher: AnyPublisher<Page6Action, Never>) {
        subscriber = actionPublisher.sink { action in
            switch action {
            case .present(let numberOfParts):
                var delay: Double = 0
                if !Self.functionIsDrawn {
                    Self.functionIsDrawn = true
                    delay = 1
                    Self.functionViewController?.draw(function: Self.function1, animationDuration: 1)
                }

                Self.problematicFunctionIsDrawn = false

                Self.functionViewController?.draw(integral: .trapezoidal(numberOfParts: numberOfParts), animationDuration: 1, delay: delay)

            case .presentProblematicFunction(let numberOfParts):
                var delay: Double = 0
                if !Self.problematicFunctionIsDrawn {
                    Self.problematicFunctionIsDrawn = true
                    delay = 1
                    Self.functionViewController?.draw(function: Self.function2, animationDuration: 1)
                }

                Self.functionIsDrawn = false

                Self.functionViewController?.draw(integral: .trapezoidal(numberOfParts: numberOfParts), animationDuration: 1, delay: delay)
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
