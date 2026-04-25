import UIKit

struct AppTextStyles {
    // MARK: Bold
    static let bold32 = UIFont.systemFont(ofSize: 32, weight: .bold)
    static let bold19 = UIFont.systemFont(ofSize: 19, weight: .bold)
    static let bold34 = UIFont.systemFont(ofSize: 34, weight: .bold)
    
    // MARK: Medium
    static let medium12 = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let medium16 = UIFont.systemFont(ofSize: 16, weight: .medium)
    static let medium10 = UIFont.systemFont(ofSize: 10, weight: .medium)
    
    // MARK: Regular
    static let regular17 = UIFont.systemFont(ofSize: 17, weight: .regular)
    
    static func attributed(_ text: String, style: UIFont, lineHeight: CGFloat? = nil, color: UIColor = .label) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        if let lineHeight = lineHeight {
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
        }
        
        return NSAttributedString(
            string: text,
            attributes: [
                .font: style,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
