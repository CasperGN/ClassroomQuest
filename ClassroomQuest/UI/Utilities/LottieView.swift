import SwiftUI
#if canImport(UIKit)
import Lottie
import UIKit

struct LottieView: UIViewRepresentable {
    let animationName: String
    var loopMode: LottieLoopMode = .playOnce
    var play: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .clear

        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundColor = .clear
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFill
        animationView.backgroundBehavior = .pauseAndRestore

        if let animation = LottieAnimation.named(
            animationName,
            bundle: .main,
            subdirectory: "LottieAnimations"
        ) {
            animationView.animation = animation
        }

        containerView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        context.coordinator.animationView = animationView

        if play {
            animationView.play()
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = context.coordinator.animationView else { return }
        animationView.loopMode = loopMode

        if play {
            if !animationView.isAnimationPlaying {
                animationView.stop()
                animationView.currentProgress = 0
                animationView.play()
            }
        } else {
            animationView.stop()
        }
    }

    final class Coordinator {
        var animationView: LottieAnimationView?
    }
}
#endif
