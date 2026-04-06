import Foundation

enum EarnedMoneyFormatter {
    private static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static func string(from amount: Double) -> String {
        let value = Int64(max(0, amount.rounded(.down)))

        guard value >= 10_000 else {
            return "₩\(grouped(value))"
        }

        let units: [(Int64, String)] = [
            (1_000_000_000_000, "조"),
            (100_000_000, "억"),
            (10_000, "만")
        ]

        var remaining = value
        var components: [String] = []

        for (unitValue, suffix) in units {
            let unitAmount = remaining / unitValue

            guard unitAmount > 0 else {
                continue
            }

            components.append("\(grouped(unitAmount))\(suffix)")
            remaining %= unitValue

            if components.count == 2 {
                break
            }
        }

        if components.isEmpty {
            return "₩\(grouped(value))"
        }

        if components.count == 1, remaining > 0, value < 100_000_000 {
            components.append(grouped(remaining))
        }

        return "₩\(components.joined(separator: " "))"
    }

    private static func grouped(_ value: Int64) -> String {
        decimalFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
