
import Foundation

enum FunctionRange: Equatable {
    case fromZeroTo(max: Int)
    case symmetric(max: Int)

    var minValue: Double {
        switch self {
        case .fromZeroTo: return 0
        case let .symmetric(max): return Double(-max)
        }
    }

    var maxValue: Double {
        switch self {
        case let .fromZeroTo(max): return Double(max)
        case let .symmetric(max): return Double(max)
        }
    }
}
