import AVFoundation
import Foundation

@MainActor
final class SpeechCoach: NSObject {
    static let shared = SpeechCoach()

    private let synthesizer = AVSpeechSynthesizer()
    private var pendingSpeakWorkItem: DispatchWorkItem?
    private let celebrationPhrases = [
        "Great job!",
        "Awesome work!",
        "You solved it!",
        "Nice thinking!"
    ]
    private let encouragementPhrases = [
        "Let's try again together.",
        "Keep going, you can do this!",
        "Take another look.",
        "Almost there!"
    ]

    private override init() {
        super.init()
    }

    func presentPrompt(_ text: String) {
        speak(text, rate: 0.45, pitch: 1.05, preDelay: 0.2)
    }

    func celebrateSuccess() {
        if let phrase = celebrationPhrases.randomElement() {
            speak(phrase, rate: 0.48, pitch: 1.08, preDelay: 0.1)
        }
    }

    func encourageRetry() {
        if let phrase = encouragementPhrases.randomElement() {
            speak(phrase, rate: 0.46, pitch: 1.0, preDelay: 0.1)
        }
    }

    func speak(_ text: String, rate: Float = AVSpeechUtteranceDefaultSpeechRate, pitch: Float = 1.0, preDelay: TimeInterval = 0) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        pendingSpeakWorkItem?.cancel()
        synthesizer.stopSpeaking(at: .immediate)

        let utterance = AVSpeechUtterance(string: trimmed)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = rate
        utterance.pitchMultiplier = pitch

        if preDelay > 0 {
            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.pendingSpeakWorkItem = nil
                self.synthesizer.speak(utterance)
            }
            pendingSpeakWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + preDelay, execute: workItem)
        } else {
            pendingSpeakWorkItem = nil
            synthesizer.speak(utterance)
        }
    }

    func stop() {
        pendingSpeakWorkItem?.cancel()
        pendingSpeakWorkItem = nil
        synthesizer.stopSpeaking(at: .immediate)
    }
}
