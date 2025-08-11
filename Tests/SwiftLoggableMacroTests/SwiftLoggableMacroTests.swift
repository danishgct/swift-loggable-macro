import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import SwiftLoggableMacroMacros

let testMacros: [String: Macro.Type] = [
    "loggable": LoggableMacro.self,
]

final class SwiftLoggableMacroTests: XCTestCase {

    // Test case for a function with no return value
    func testMacroOnFunctionWithoutReturnValue() {
        assertMacroExpansion(
            """
            @loggable
            func greet(name: String) {
                print("Hello, \\(name)")
            }
            """,
            expandedSource: """
            func greet(name: String) {
                print("Entering function: greet")
                print("Parameter 1 Name: name = \\(name) : of type : String")
                defer {
                    print("Exiting function: greet")
                }
                print("Hello, \\(name)")
            }
            """,
            macros: testMacros
        )
    }

    // Test case for a function with a return value
    func testMacroOnFunctionWithReturnValue() {
        assertMacroExpansion(
            """
            @loggable
            func add(a: Int, b: Int) -> Int {
                return a + b
            }
            """,
            expandedSource: """
            func add(a: Int, b: Int) -> Int {
                print("Entering function: add")
                print("Parameter 1 Name: a = \\(a) : of type : Int")
                print("Parameter 2 Name: b = \\(b) : of type : Int")
                defer {
                    print("Exiting function: add")
                }
                let result = ({
                    return a + b
                })()
                print("Return value: \\(result)")
                return result
            }
            """,
            macros: testMacros
        )
    }

    // Test case for a function with a custom logger
    func testMacroWithCustomLogger() {
        assertMacroExpansion(
            """
            @loggable(logger: MyLogger.log)
            func subtract(a: Int, b: Int) -> Int {
                return a - b
            }
            """,
            expandedSource: """
            func subtract(a: Int, b: Int) -> Int {
                MyLogger.log("Entering function: subtract")
                MyLogger.log("Parameter 1 Name: a = \\(a) : of type : Int")
                MyLogger.log("Parameter 2 Name: b = \\(b) : of type : Int")
                defer {
                    MyLogger.log("Exiting function: subtract")
                }
                let result = ({
                    return a - b
                })()
                MyLogger.log("Return value: \\(result)")
                return result
            }
            """,
            macros: testMacros
        )
    }

    // Test case for a function with a closure logger
    func testMacroWithClosureLogger() {
        assertMacroExpansion(
            """
            @loggable(logger: { print("LOG: \\($0)") })
            func multiply(a: Int, b: Int) -> Int {
                return a * b
            }
            """,
            expandedSource: """
            func multiply(a: Int, b: Int) -> Int {
                ({ print("LOG: \\($0)") })("Entering function: multiply")
                ({ print("LOG: \\($0)") })("Parameter 1 Name: a = \\(a) : of type : Int")
                ({ print("LOG: \\($0)") })("Parameter 2 Name: b = \\(b) : of type : Int")
                defer {
                    ({ print("LOG: \\($0)") })("Exiting function: multiply")
                }
                let result = ({
                    return a * b
                })()
                ({ print("LOG: \\($0)") })("Return value: \\(result)")
                return result
            }
            """,
            macros: testMacros
        )
    }

    // Test case for a function with no parameters
    func testMacroOnFunctionWithNoParameters() {
        assertMacroExpansion(
            """
            @loggable
            func doSomething() -> String {
                return "Done"
            }
            """,
            expandedSource: """
            func doSomething() -> String {
                print("Entering function: doSomething")
                defer {
                    print("Exiting function: doSomething")
                }
                let result = ({
                    return "Done"
                })()
                print("Return value: \\(result)")
                return result
            }
            """,
            macros: testMacros
        )
    }
}
