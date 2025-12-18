 
import Foundation
import SwiftUI
import Combine

public final class AppLifecycleObserver: ObservableObject {

    // MARK: - Lifecycle States
    @Published public private(set) var isFirstLaunch: Bool = true
    @Published public private(set) var isActive: Bool = false
    @Published public private(set) var isInBackground: Bool = false
    @Published public private(set) var isInactive: Bool = false

    public init() {}

    // MARK: - Update from ScenePhase
    public func update(scenePhase: ScenePhase) {
        switch scenePhase {

        case .active:
            isActive = true
            isInBackground = false
            isInactive = false

            if isFirstLaunch {
                isFirstLaunch = false
                onFirstLaunch()
            }

            onBecomeActive()

        case .background:
            isActive = false
            isInBackground = true
            isInactive = false
            onEnterBackground()

        case .inactive:
            isActive = false
            isInBackground = false
            isInactive = true
            onBecomeInactive()

        @unknown default:
            break
        }
    }

    // MARK: - Hooks (override usage)
    private func onFirstLaunch() {
        print("App First Launch")
    }

    private func onBecomeActive() {
        print("App Became Active")
    }

    private func onEnterBackground() {
        print("App Entered Background")
    }

    private func onBecomeInactive() {
        print("App  Inactive")
    }
}
