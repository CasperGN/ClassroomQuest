import SwiftUI

struct StartupSplashView: View {
    var onFinished: () -> Void

    @State private var hasStarted = false
    @State private var showLogo = false
    @State private var bubbleExpanded = false
    @State private var bounce = false
    @State private var tilt = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(LinearGradient.cqSoftAdventure)
                    .frame(width: bubbleExpanded ? 260 : 40, height: bubbleExpanded ? 260 : 40)
                    .scaleEffect(bubbleExpanded ? 1 : 0.35)
                    .opacity(bubbleExpanded ? 0.9 : 0.0)
                    .animation(.spring(response: 0.65, dampingFraction: 0.75, blendDuration: 0.2).delay(0.05), value: bubbleExpanded)

                Circle()
                    .fill(Color(.systemBackground).opacity(0.65))
                    .frame(width: bubbleExpanded ? 220 : 20, height: bubbleExpanded ? 220 : 20)
                    .scaleEffect(bubbleExpanded ? 1 : 0.2)
                    .opacity(bubbleExpanded ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.8, blendDuration: 0.2).delay(0.08), value: bubbleExpanded)

                Image("classroomquest_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .scaleEffect(showLogo ? 1 : 0.4)
                    .opacity(showLogo ? 1 : 0)
                    .offset(y: bounce ? -18 : 20)
                    .rotationEffect(.degrees(tilt ? 6 : -6))
                    .shadow(color: Color(.systemGray3).opacity(0.6), radius: 18, x: 0, y: 14)
                    .animation(.spring(response: 0.7, dampingFraction: 0.68, blendDuration: 0.25), value: showLogo)
                    .animation(
                        .easeInOut(duration: 0.42)
                            .repeatCount(4, autoreverses: true)
                            .delay(0.8),
                        value: bounce
                    )
                    .animation(
                        .easeInOut(duration: 0.42)
                            .repeatCount(4, autoreverses: true)
                            .delay(0.8),
                        value: tilt
                    )
            }
        }
        .task {
            await runSequence()
        }
        .accessibilityLabel(Text("ClassroomQuest"))
    }

    private func runSequence() async {
        let shouldStart = await MainActor.run { () -> Bool in
            guard !hasStarted else { return false }
            hasStarted = true
            showLogo = true
            bubbleExpanded = true
            return true
        }

        guard shouldStart else { return }

        try? await Task.sleep(nanoseconds: 750_000_000)

        await MainActor.run {
            bounce = true
            tilt = true
        }

        try? await Task.sleep(nanoseconds: 1_250_000_000)

        await MainActor.run {
            bounce = false
            tilt = false
        }

        try? await Task.sleep(nanoseconds: 320_000_000)

        await MainActor.run {
            onFinished()
        }
    }
}

#if DEBUG
struct StartupSplashView_Previews: PreviewProvider {
    static var previews: some View {
        StartupSplashView(onFinished: {})
            .previewDisplayName("Startup Splash")
    }
}
#endif
