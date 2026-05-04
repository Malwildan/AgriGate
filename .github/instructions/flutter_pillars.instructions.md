<flutter_mobile_development>
## Technology Stack
Your mobile applications should be built using the following technologies:
1. **Core**: Use the Flutter framework and the Dart programming language.
2. **Architecture**: Implement **Clean Architecture** combined with **MVVM**.
   - **Data Layer**: Repositories, Data Sources (Remote/Local), and Models (DTOs).
   - **Domain Layer**: Entities (Plain Dart objects), Repository Interfaces, and Use Cases. This layer must be independent of Flutter and all external libraries.
   - **Presentation Layer**: BLoCs, States, Events, and UI Widgets.
3. **Modularization**: Structure the app by **Feature-based Modules**. Each feature should be a self-contained package or folder containing its own Clean Architecture layers. Shared logic, core UI components, and network clients must reside in a `core` or `common` module.
4. **State Management**: Use the **BLoC** (Business Logic Component) library exclusively. Do NOT use Cubit. Ensure strict **Separation of Concerns**: the BLoC should only call **Use Cases** from the Domain layer to execute business logic.
5. **Networking & API**: Use **Dio** for all HTTP networking. Implement a centralized network client with Interceptors in the `core` module. Use `json_serializable` for type-safe mapping from JSON to Data Layer Models.
6. **Routing**: Use `go_router` for declarative routing. Define route constants and configurations within a dedicated navigation module or class.
7. **Local Data Persistence**: Use `shared_preferences` for simple key-value pairs and `isar` or `hive` for structured local storage (offline-first).
8. **Dependency Injection**: Use `get_it` and `injectable` to manage the lifecycle of BLoCs, Use Cases, and Repositories across different modules.

## Design Aesthetics
1. **Use Rich Aesthetics**: Leverage Flutter's pixel-perfect rendering for stunning UIs. Utilize Material Design 3 and Cupertino appropriately or a custom unified design system.
2. **Prioritize Visual Excellence**: 
   - Implement a comprehensive `ThemeData` with `ColorScheme.fromSeed`.
   - Support seamless Dark and Light modes.
   - Use `google_fonts` for premium typography.
3. **Dynamic Design**: Use implicit and explicit animations (`Hero`, `Lottie`, `AnimatedContainer`) for 60/120fps micro-interactions. Use `InkWell` or `GestureDetector` for responsive feedback.
4. **Native Feel**: Use adaptive widgets (e.g., `Switch.adaptive()`, `CircularProgressIndicator.adaptive()`) and platform-specific scrolling physics.

## Implementation Workflow
1. **Plan and Understand**: Map out the feature requirements, defining the Domain Entities and Use Cases first (Domain-Driven Design).
2. **Modular Setup**: Create the feature structure. Set up Dependency Injection for the new module.
3. **Build the Foundation**: 
   - Wrap the app in `ScreenUtilInit`.
   - Configure `GoRouter` and the core `ThemeData`.
4. **Layered Development**:
   - **Domain**: Define the "What" (Entities & Use Case interfaces).
   - **Data**: Implement the "How" (Repositories & API calls).
   - **Presentation**: Build the BLoC and the UI.
5. **UI Assembly**: Compose screens using `Scaffold` and `Slivers`. Wire the UI to the BLoC using `BlocProvider` and `BlocBuilder`.
6. **Polish**: Implement **Skeletonizer** for loading states to provide an "instant" feel.

## Mobile Best Practices
- **Performance**: Use `const` constructors and ensure BLoCs are closed/disposed properly.
- **Responsiveness**: Use **flutter_screenutil** (`.w`, `.h`, `.sp`) for all scaling. Use `SafeArea` and `LayoutBuilder` for adaptive layouts.
- **State Handling**: Never leave the user on a blank screen. Use **Skeletonizer** for data-heavy loads and provide clear error feedback via SnackBar or dedicated Error Widgets.
- **Separation of Concerns**: UI widgets should never contain business logic or direct API calls. They should only "dispatch Events" and "render States."

CRITICAL REMINDER: ARCHITECTURAL INTEGRITY IS PARAMOUNT. If the layers are tightly coupled, or logic leaks from the Data layer into the UI, you have FAILED!
</flutter_mobile_development>