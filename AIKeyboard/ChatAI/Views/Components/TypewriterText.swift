import SwiftUI
import UIKit

extension Notification.Name {
    static let typewriterProgress = Notification.Name("TypewriterProgress")
}

struct TypewriterText: View {
    let fullText: String
    var interval: Double = 0.02
    var hapticStride: Int = 6
    var lineLimit: Int? = nil
    var onFinished: (() -> Void)? = nil

    @State private var visibleText: String = ""
    @State private var animationTask: Task<Void, Never>? = nil

    var body: some View {
        Text(visibleText)
            .task(id: fullText) {
                // Cancel any in-progress animation to avoid duplication
                animationTask?.cancel()
                visibleText = ""
                animationTask = Task { await startAnimation() }
            }
            .lineLimit(lineLimit)
    }

    @MainActor
    private func startAnimation() async {
        guard !fullText.isEmpty else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        // Cap total duration to ~5 seconds using frame-sized steps
        let maxTotalDuration: Double = 5.0
        let frameInterval: Double = 1.0 / 60.0 // ~60 FPS
        let charArray = Array(fullText)
        let charCount = charArray.count
        let maxSteps = max(1, Int(maxTotalDuration / frameInterval)) // ~300
        let charsPerStep = max(1, Int(ceil(Double(charCount) / Double(maxSteps))))

        var index = 0
        while index < charCount {
            if Task.isCancelled { return }

            let nextIndex = min(charCount, index + charsPerStep)
            let slice = charArray[index..<nextIndex]
            visibleText.append(contentsOf: slice)

            // Haptics paced by visible characters, not frames
            if hapticStride > 0 && nextIndex % hapticStride == 0 {
                generator.impactOccurred(intensity: 0.5)
            }
            
            index = nextIndex
            NotificationCenter.default.post(name: .typewriterProgress, object: nil)
            try? await Task.sleep(nanoseconds: UInt64(frameInterval * 1_000_000_000))
        }

        if !Task.isCancelled {
            await MainActor.run {
                onFinished?()
            }
        }
    }
}
