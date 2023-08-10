# GoodCoordinator
### 🧭 Programmatic navigation made simple, 100% SwiftUI

In just 3 lines of code
```swift
@Push(makeHome) var home
func makeHome(model: HomeModel) -> HomeView { HomeView(model: model) }

route(to: \.home, HomeModel(username: username, password: password))
```

## Usage

1. <details><summary>Implement a SwiftUI App</summary>
  
   ```swift
   @main struct NavigationApp: App {
       private let coordinator = AppCoordinator(())

       var body: some Scene {
           WindowGroup {
               coordinator.makeView()
           }
       }
   }
   ```

   This is a standard implementation for a 100% SwiftUI app.
   </details>

2. <details><summary>Implement your first coordinator</summary> 
  
   ```swift
   import GoodCoordinator
   
   final class AppCoordinator: NavigationCoordinator {
       typealias Input = Void
       typealias Output = Void
       var state: NavigationStack = .init(debugTitle: "AppCoordinator")

       @Root(makeRoot) var root

       func makeRoot() -> InitialView {
           InitialView() /// SwiftUI View!
       }
   }
   ```

   Don't worry about code you don't understand yet. Feel free to name the `makeRoot` function in any way you prefer. The function returns the view of your choice. However, to get this code to compile, you need to do one more thing:
   </details>

3. <details><summary>Modify your SwiftUI View a bit</summary>
  
   ```swift
   import GoodCoordinator
   
   struct InitialView: View, Screen { /// Extend from Screen as well
       ...
   ```
   </details>

4. <details><summary>Add a navigation step</summary>

   ```swift
   @Push(makeNewScreen) var openNewScreen

   func makeNewScreen() -> NewScreen {
       NewScreen(viewModel: NewScreenViewModel())
   }
   ```
   
   Add a step into your coordinator and specify, how the view will get constructed.
   </details>

5. <details><summary>Navigate!</summary>

   ```swift
   @EnvironmentObject var router: Router<AppCoordinator>

   // SwiftUI view code
   Button("Go to new screen") {
       router.coordinator.route(to: \.openNewScreen)
   }
   // More SwiftUI view code
   ```
   
   Launch the navigation step from your view.
   </details>

## Installation
You can use Swift Package Manager (SPM) to import this package. Use the following URL:

```
https://github.com/GoodRequest/GoodCoordinator-iOS.git
```

## Advanced examples

### A: Pushing data (forwards data flow)

1. <details><summary>Set your datatype as an Input</summary>

   Modify the navigation step that requires input data - add the data as a parameter.

   Note: navigation steps are limited to 1 input parameter only. This is due to practical reasons, as adding 2 or more input parameters would require disproportional amount of additional function overloads in the code base.
   If you require multiple input parameters, consider making a `struct` out of them and pass the struct.
   ```swift
   final class MyCoordinator: NavigationCoordinator {
       ...
       func makeRoot(someData: String) -> RootView {
           RootView(model: RootModel(data: someData))
       }
       ...
   }
   ```
   
   If your input view is the `@Root` step of a coordinator, change the whole coordinator Input typealias to reflect your datatype:
   ```swift
   typealias Input = String
   ```
   </details>

2. <details><summary>Navigate</summary>

   In a SwiftUI view:
   ```swift
   @State private var username: String = ""
   ...
   Button("Push with data") {
       router.coordinator.route(to: \.step, username)
   }
   ```
   
   Call the route function with additional parameter as an input. Xcode should automatically autocomplete this function with expected data type.
   </details>
