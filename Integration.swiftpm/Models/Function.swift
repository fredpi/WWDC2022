
import Foundation

// Make sure that the function only leaves the value range at the left and at the right or nowhere (not in between)
struct Function {
    var definitionRange: FunctionRange
    var valueRange: FunctionRange
    var valueForX: (Double) -> Double

    var yPercentageAtZero: Double { yPercentage(forY: 0) }

    func yPercentage(xPercentage: Double) -> Double? {
        let y = valueForX(xPercentage * definitionRange.maxValue + (1 - xPercentage) * definitionRange.minValue)
        return y > valueRange.maxValue || y < valueRange.minValue ? nil : yPercentage(forY: y)
    }

    private func yPercentage(forY y: Double) -> Double {
        (y - valueRange.minValue) / (valueRange.maxValue - valueRange.minValue)
    }
}
