 # AppLifecycleKit

AppLifecycleKit is a **SwiftUI-first app lifecycle observer** that helps you track:

- App launch & first activation
- Foreground ↔ Background transitions
- App becoming active / inactive

It uses **SwiftUI `scenePhase`**, not AppDelegate or SceneDelegate.

---

## Add Dependency (Swift Package Manager)

### Using Xcode

1. Open your project in Xcode
2. Go to **File → Add Packages…**
3. Paste the repository URL:

```

https://github.com/Excelsior-Technologies-Community/AppLifecycleKit

````

4. Click **Add Package**
5. Add **AppLifecycleKit** to your app target

---

## IMPORTANT: Setup in App File (Required)

You must inject `AppLifecycleObserver` at the **app root**.

### Example: `MyApp.swift`

```swift
import SwiftUI
import AppLifecycleKit   // IMPORTANT

@main
struct MyApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var lifecycleObserver = AppLifecycleObserver()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lifecycleObserver)
        }
        .onChange(of: scenePhase) { newPhase in
            lifecycleObserver.update(scenePhase: newPhase)
        }
    }
}
````

Why this is required:

* `scenePhase` tells SwiftUI when app state changes
* `AppLifecycleObserver` converts it into easy-to-use flags
* `environmentObject` makes it available everywhere

---

## Use in Any View

In any SwiftUI view, just add:

```swift
@EnvironmentObject private var lifecycle: AppLifecycleObserver
```

Now you can access lifecycle states using:

```swift
lifecycle.isFirstLaunch
lifecycle.isActive
lifecycle.isInactive
lifecycle.isInBackground
```

---

## Full Example

### `ContentView.swift`

```swift
import SwiftUI
import AppLifecycleKit

struct ContentView: View {

    @EnvironmentObject private var lifecycle: AppLifecycleObserver

    var body: some View {
        VStack(spacing: 16) {

            if lifecycle.isFirstLaunch {
                Text("First Launch")
            }

            if lifecycle.isActive {
                Text("App is Active")
            }

            if lifecycle.isInactive {
                Text("App is Inactive")
            }

            if lifecycle.isInBackground {
                Text("App is in Background")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppLifecycleObserver())
}
```

---

## Lifecycle States Explained

| Property         | Meaning                              |
| ---------------- | ------------------------------------ |
| `isFirstLaunch`  | App opened for the first time        |
| `isActive`       | App is in foreground and usable      |
| `isInactive`     | Temporary interruption (call, alert) |
| `isInBackground` | App moved to background              |

---

## Common Use Cases

* Show onboarding on first launch
* Pause tasks when app goes background
* Refresh data when app becomes active
* Track app sessions
* Analytics & logging
* Save app state safely

---

## Why AppLifecycleKit

* SwiftUI-native
* No AppDelegate required
* No NotificationCenter hacks
* Clean architecture
* Beginner friendly
* Production ready

---

## Summary

* Add `AppLifecycleObserver` in **App file**
* Inject using `.environmentObject`
* Read lifecycle state anywhere using `@EnvironmentObject`
* UI updates automatically when app state changes

---

Created by **Noman Belim**

```
 