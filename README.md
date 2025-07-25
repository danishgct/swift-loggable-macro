# swift-loggable-macro
A Swift macro that auto-injects function entry, exit, and parameter logs at compile time using SwiftSyntax — perfect for debugging and observability.

---

## ✨ What It Does

The `@loggable` macro injects logging statements into your Swift functions. It works by:

- Logging when a function is entered and exited
- Logging all parameter names, values, and types
- Supporting a custom logger (defaults to `print`)

---

## 🧪 Example

Annotate any function with `@loggable`:

```swift
@loggable
func greet(name: String) {
    print("Hello, \(name)!")
}
```

Will expand to:

```swift
print("Entering function: greet")
print("Parameter 1 Name: name = \(name) : of type : String")
defer {
    print("Exiting function: greet")
}
print("Hello, \(name)!")
```

You can also use a custom logger:

```swift
@loggable(Logger.debug)
func calculate(a: Int, b: Int) -> Int {
    return a + b
}
```

---

## 🔧 Installation

### Requirements

- Swift 5.9+
- Xcode 15+
- SwiftSyntax & SwiftSyntaxMacros packages

---

## 🛠️ How It Works

The macro conforms to `BodyMacro` and rewrites function bodies at compile-time using SwiftSyntax. It performs:

1. Validation — Ensures macro is only applied to functions.
2. Parameter analysis — Builds string interpolations for each parameter.
3. Function body reconstruction — Injects entry/exit logs + original statements.

You can view the macro logic inside `LoggableMacro.swift`

---

## 💡 Potential Extensions

- Log return values
- Measure execution time
- Integrate `os_log` / `Logger`
- Toggle logging by build config
- Add trace IDs or timestamps

---

## 🧑‍💻 Author

Created by [Danish Phiroz](https://medium.com/@danishphiroz)  
👉 Follow for more Swift & macro-based development tutorials.

---

## 📜 License

MIT License
