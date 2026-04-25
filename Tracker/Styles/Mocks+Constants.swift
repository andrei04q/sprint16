import UIKit

enum UIConstants {
    static let actionButtonsBottomPadding: CGFloat = 24
    static let maxTitleLength = 38
}

enum MockData {
    static let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]

    static let colors: [UIColor] = {
        var colors: [UIColor] = []
        for i in 1 ... 18 {
            if let color = UIColor(named: "ColorSelection\(i)") {
                colors.append(color)
            }
        }
        return colors
    }()

    static let testTrackers: [TrackerModel] = [
        TrackerModel(
            id: UUID(),
            title: "Вода",
            color: "ColorSelection8",
            emoji: "💧",
            schedule: [.monday]
        ),
        TrackerModel(
            id: UUID(),
            title: "Спорт",
            color: "ColorSelection7",
            emoji: "🏃‍♂️",
            schedule: [.tuesday]
        ),
        TrackerModel(
            id: UUID(),
            title: "Медитация",
            color: "ColorSelection17",
            emoji: "🧘‍♀️",
            schedule: [.monday]
        )
    ]

    static func getColorName(for color: UIColor) -> String? {
        for (index, storedColor) in colors.enumerated() {
            if storedColor == color {
                return "ColorSelection\(index + 1)"
            }
        }
        return nil
    }
}
