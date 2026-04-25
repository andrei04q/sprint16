import UIKit

final class NSAttributedStringBuilder {
    
    static func buildScheduleText(
        fullText: String,
        primaryFont: UIFont,
        primaryColor: UIColor,
        secondaryFont: UIFont,
        secondaryColor: UIColor
    ) -> NSAttributedString {
        let attrText = NSMutableAttributedString(string: fullText)
        
        guard fullText.contains("\n"),
              let newlineIndex = fullText.firstIndex(of: "\n") else {
            attrText.addAttribute(.font, value: primaryFont,
                                 range: NSRange(location: 0, length: fullText.count))
            attrText.addAttribute(.foregroundColor, value: primaryColor,
                                 range: NSRange(location: 0, length: fullText.count))
            return attrText
        }
        
        let lineBreakIndex = newlineIndex.utf16Offset(in: fullText)
        let secondaryLength = fullText.count - lineBreakIndex - 1
        
        attrText.addAttribute(.font, value: primaryFont,
                             range: NSRange(location: 0, length: lineBreakIndex))
        attrText.addAttribute(.foregroundColor, value: primaryColor,
                             range: NSRange(location: 0, length: lineBreakIndex))
        
        attrText.addAttribute(.font, value: secondaryFont,
                             range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        attrText.addAttribute(.foregroundColor, value: secondaryColor,
                             range: NSRange(location: lineBreakIndex + 1, length: secondaryLength))
        
        return attrText
    }
}
