
import Foundation

enum Integral {
    case analytical
    case midpoint(numberOfParts: Int)
    case trapezoidal(numberOfParts: Int)
    case simpson(numberOfParts: Int)
}
