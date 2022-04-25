
import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
    var disabledStyle: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(disabledStyle ? .blue.opacity(0.7) : .blue)
            .foregroundColor(disabledStyle ? .white.opacity(0.7) : .white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
