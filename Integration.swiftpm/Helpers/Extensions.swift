
import UIKit

public extension CALayer {
    func disableAnimations() {
        actions = [
            "onOrderIn": NSNull(),
            "onOrderOut": NSNull(),
            "sublayers": NSNull(),
            "contents": NSNull(),
            "bounds": NSNull(),
            "strokeEnd": NSNull(),
            "position": NSNull(),
            "transform": NSNull()
        ]
    }
}
