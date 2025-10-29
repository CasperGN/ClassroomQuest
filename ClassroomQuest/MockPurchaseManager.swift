import Foundation
import Combine
import SwiftUI

final class MockPurchaseManager: ObservableObject {
    @Published private(set) var isUnlocked: Bool

    init() {
        self.isUnlocked = UserDefaults.standard.bool(forKey: "UnlimitedUnlocked")
    }

    private init(preview: Bool) {
        self.isUnlocked = preview
    }

    func unlock() {
        updateUnlocked(true)
    }

    func resetUnlock() {
        updateUnlocked(false)
    }

    private func updateUnlocked(_ unlocked: Bool) {
        if Thread.isMainThread {
            isUnlocked = unlocked
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.isUnlocked = unlocked
            }
        }
        UserDefaults.standard.set(unlocked, forKey: "UnlimitedUnlocked")
    }

    static let preview: MockPurchaseManager = {
        let manager = MockPurchaseManager(preview: true)
        return manager
    }()
}

