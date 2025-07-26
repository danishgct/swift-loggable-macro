// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro that automatically adds logging to the body of a function or method.
///
/// When applied, this macro injects logging statements at the start and end of the function body.
/// You can optionally provide a custom logger closure. If not provided, a default logger is used.
///
/// - Parameter logger: An optional closure to handle log messages. Defaults to `nil` (uses the default logger).
///
/// Usage:
/// ```swift
/// @loggable
/// func myFunction() {
///     // function body
/// }
/// ```
///
/// or with a custom logger:
/// ```swift
/// @loggable(logger: { print("LOG: \($0)") })
/// func myFunction() {
///     // function body
/// }
/// ```
@attached(body)
public macro loggable(logger: ((String) -> Void)? = nil) = #externalMacro(module: "SwiftLoggableMacroMacros", type: "LoggableMacro")
