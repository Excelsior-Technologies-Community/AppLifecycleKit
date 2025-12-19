//
//  Created by Noman belim
//

import Foundation
 
import SwiftUI
import UIKit
import Combine

import SwiftUI
import Combine

import SwiftUI
import Combine

public final class AppLifecycleObserver: ObservableObject {
    
    // MARK: - Published States
    @Published public private(set) var isActive = false
    @Published public private(set) var isInactive = false
    @Published public private(set) var isInBackground = false
    @Published public private(set) var isPrivacyShieldActive = false
    
    // MARK: - Analytics
    @Published public private(set) var sessionCount = 0
    @Published public private(set) var activeDuration: TimeInterval = 0
    @Published public private(set) var lifecycleHistory: [String] = []
    
    // MARK: - Internal logic
    private var liveTimer: AnyCancellable?
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var isFirstLaunch = true
    
    // MARK: - Developer Hooks (Public Closures)
    public var onFirstLaunch: (() -> Void)?
    public var onActive: (() -> Void)?
    public var onInactive: (() -> Void)?
    public var onBackground: (() -> Void)?
    public var onSessionEnded: ((TimeInterval) -> Void)?

    public init() {}

    // MARK: - ScenePhase Update
    public func update(scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            startLiveTracking()
            handleActive()
        case .inactive:
            // We don't stop timer here so short interruptions
            // (like Control Center) don't break the count
            handleInactive()
        case .background:
            stopLiveTracking()
            handleBackground()
        @unknown default:
            break
        }
    }

    // MARK: - Live Timer Logic
    private func startLiveTracking() {
        if liveTimer != nil { return } // Already running
        
        liveTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.activeDuration += 1
            }
    }

    private func stopLiveTracking() {
        liveTimer?.cancel()
        liveTimer = nil
    }

    // MARK: - Handlers
    private func handleActive() {
        endBackgroundTask()
        isActive = true
        isInactive = false
        isInBackground = false
        isPrivacyShieldActive = false
        
        sessionCount += 1
        log("ACTIVE")

        if isFirstLaunch {
            isFirstLaunch = false
            onFirstLaunch?()
        }
        onActive?()
    }

    private func handleInactive() {
        isActive = false
        isInactive = true
        isPrivacyShieldActive = true // Blur the screen for privacy
        log("INACTIVE")
        onInactive?()
    }

    private func handleBackground() {
        isActive = false
        isInactive = false
        isInBackground = true
        
        log("BACKGROUND")
        startBackgroundTask()
        onBackground?()
    }

    // MARK: - Utilities
    private func startBackgroundTask() {
        backgroundTaskID = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }

    private func log(_ event: String) {
        let time = Date().formatted(date: .omitted, time: .standard)
        lifecycleHistory.insert("\(event) @ \(time)", at: 0)
        if lifecycleHistory.count > 15 { lifecycleHistory.removeLast() }
    }
}
struct RootWrapper<Content: View>: View {
    @EnvironmentObject var lifecycle: AppLifecycleObserver
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .blur(radius: lifecycle.isPrivacyShieldActive ? 20 : 0)
                .animation(.easeInOut, value: lifecycle.isPrivacyShieldActive)
            
            if lifecycle.isPrivacyShieldActive {
                // Show a logo or a clean color instead of blurred sensitive data
                Color.black.opacity(0.5).ignoresSafeArea()
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
            }
        }
    }
}
