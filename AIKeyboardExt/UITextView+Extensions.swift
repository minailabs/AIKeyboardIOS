import UIKit

extension UITextView {
    
    /// Sets the text of the UITextView with a typewriter-like animation.
    /// - Parameters:
    ///   - newText: The new text to display.
    ///   - interval: The time interval between each character being added.
    @MainActor
    func setTextAnimated(newText: String, interval: TimeInterval = 0.02) async {
        text = ""
        for character in newText {
            text.append(character)
            do {
                // The delay is converted from seconds to nanoseconds for Task.sleep
                try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            } catch {
                // If the task is cancelled, we'll just show the full text immediately.
                text = newText
                break
            }
        }
    }
}
