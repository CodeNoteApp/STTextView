//  Created by Marcin Krzyzanowski
//  https://github.com/krzyzanowskim/STTextView/blob/main/LICENSE.md

import Foundation
import Cocoa

extension STTextView {

    /// Updates the insertion point’s location and optionally restarts the blinking cursor timer.
    open func updateInsertionPointStateAndRestartTimer() {

        selectionView.subviews.removeAll(where: {
            type(of: $0) == Self.insertionPointClass
        })

        if shouldDrawInsertionPoint {
            for textRange in textLayoutManager.textSelections.flatMap(\.textRanges) {
                textLayoutManager.enumerateTextSegments(in: textRange, type: .selection, options: .rangeNotRequired) { ( _, textSegmentFrame, baselinePosition, textContainer) in
                    var selectionFrame = textSegmentFrame.intersection(frame)
                    guard !selectionFrame.isNull, !selectionFrame.isEmpty, !selectionFrame.isInfinite else {
                        return true
                    }

                    // because `textLayoutManager.enumerateTextLayoutFragments(from: nil, options: [.ensuresExtraLineFragment, .ensuresLayout, .estimatesSize])`
                    // returns unexpected value for extra line fragment height (return 14) that is not correct in the context,
                    // therefore for empty override height with value manually calculated from font + paragraph style
                    if textRange == documentRange {
                        if let font = typingAttributes[.font] as? NSFont {
                            let paragraphStyle = typingAttributes[.paragraphStyle] as? NSParagraphStyle ?? NSParagraphStyle.default
                            let lineHeight = NSLayoutManager().defaultLineHeight(for: font) * paragraphStyle.lineHeightMultiple
                            selectionFrame = NSRect(origin: selectionFrame.origin, size: CGSize(width: selectionFrame.width, height: lineHeight))
                        }
                    }

                    let insertionView = (Self.insertionPointClass as STInsertionPoint.Type).init(frame: selectionFrame)
                    assert(insertionView.isFlipped)
                    insertionView.insertionPointColor = insertionPointColor

                    if isFirstResponder {
                        insertionView.enable()
                    } else {
                        insertionView.disable()
                    }

                    selectionView.addSubview(insertionView)

                    return true
                }
            }
        }
    }

}
