import SwiftUI
import GameKit

struct GameCenterDashboardView: View {
    enum Destination {
        case achievements
        case leaderboards
    }

    let destination: Destination

    var body: some View {
#if canImport(GameKitUI)
        GameCenterDashboardController(destination: destination)
#else
        VStack(spacing: 12) {
            Image(systemName: "gamecontroller")
                .font(.largeTitle)
                .foregroundStyle(CQTheme.bluePrimary)
            Text("Game Center isn't available on this platform.")
                .font(.cqBody2)
                .multilineTextAlignment(.center)
                .foregroundStyle(CQTheme.textSecondary)
        }
        .padding()
#endif
    }

    static var isAvailable: Bool {
#if canImport(GameKitUI)
        if #available(iOS 17.0, *) {
            return true
        }
#endif
        return false
    }
}

#if canImport(GameKitUI)
import GameKitUI

@available(iOS 17.0, *)
private struct GameCenterDashboardController: UIViewControllerRepresentable {
    let destination: GameCenterDashboardView.Destination

    func makeUIViewController(context: Context) -> GameCenterViewController {
        let controller = GameCenterViewController(initialState: destination.initialState)
        controller.dismissHandler = { viewController in
            viewController.dismiss(animated: true)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: GameCenterViewController, context: Context) { }
}

@available(iOS 17.0, *)
private extension GameCenterDashboardView.Destination {
    var initialState: GameCenterViewController.State {
        switch self {
        case .achievements:
            return .achievements
        case .leaderboards:
            return .leaderboards
        }
    }
}
#endif
