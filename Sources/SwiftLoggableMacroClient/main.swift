import SwiftLoggableMacro

// Example usage of the @loggable macro without a custom logger.
// This will use the default logging behavior injected by the macro.
@loggable
func greet(name: String) -> String {
    return "Hello, \(name)!"
}

// Example usage of the @loggable macro with a custom logger closure.
// The logger parameter allows you to define how log messages are handled.
@loggable(logger: { message in
    print("[CUSTOM LOG]", message)
})
func farewell(name: String) -> String {
    return "Goodbye, \(name)!"
}

let _ = greet(name: "Custom Loggable Macro")
// Output
// Entering greet(name:)
// Exiting greet(name:)

let _ = farewell(name: "Custom Loggable Macro")
// Output
// [CUSTOM LOG] Entering farewell(name:)
// [CUSTOM LOG] Exiting farewell(name:)
