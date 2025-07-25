import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// A macro that automatically adds entry, exit, and parameter logging to functions or methods.
///
/// When applied, this macro injects logging statements at the start and end of the function body, as well as for each parameter.
/// You can optionally provide a custom logger function or closure. If not provided, the default logger is `print`.
///
/// Usage:
/// ```swift
/// @loggable
/// func foo(bar: Int) { ... }
///
/// @loggable(logger: { message in print("[CUSTOM]", message) })
/// func bar(baz: String) { ... }
/// ```
///
/// Error types thrown by the LoggableMacro for invalid usage.
public enum LoggableMacroError: Error, CustomStringConvertible {
    case notAFunction
    
    public var description: String {
        switch self {
        case .notAFunction:
            return "#loggable can only be applied to functions"
        }
    }
}

/// A body macro that injects logging statements into function bodies
public struct LoggableMacro: BodyMacro {
    
    /// Expands the macro by injecting logging statements for entry, exit, and parameters.
    /// - Parameters:
    ///   - node: The attribute syntax node containing macro arguments.
    ///   - declaration: The function declaration being modified.
    ///   - context: The macro expansion context.
    /// - Returns: Array of code block items representing the new function body
    public static func expansion(
        of node: AttributeSyntax,
        providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
        in context: some MacroExpansionContext
    ) throws -> [CodeBlockItemSyntax] {
        
        // Ensure this macro is only applied to functions
        guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw LoggableMacroError.notAFunction
        }
        
        let functionName = funcDecl.name.text
        
        // Extract logger function from macro arguments (defaults to "print")
        let loggerCall = extractLoggerName(from: node)
        
        // Get the original function body statements
        let originalStatements = funcDecl.body?.statements ?? CodeBlockItemListSyntax([])
        
        // Build the new function body with logging
        return [
            createEntryLogStatement(functionName: functionName, logger: loggerCall),
            createExitLogStatement(functionName: functionName, logger: loggerCall)
        ] + createParameterPrintStatements(funcDecl: funcDecl, logger: loggerCall) + Array(originalStatements)
    }
    
    // MARK: - Helper Methods
    
    /// Extracts the logger function or closure name from macro arguments.
    /// - Parameter node: The attribute syntax node.
    /// - Returns: The logger function or closure name (defaults to "print")
    private static func extractLoggerName(from node: AttributeSyntax) -> String {
        guard case let .argumentList(arguments) = node.arguments,
              let firstArg = arguments.first else {
            return "print"
        }
        
        return firstArg.expression.description.trimmingCharacters(in: .whitespaces)
    }
    
    /// Creates the function entry logging statement.
    /// - Parameters:
    ///   - functionName: Name of the function being logged.
    ///   - logger: Logger function or closure to use.
    /// - Returns: Code block item for entry logging
    private static func createEntryLogStatement(functionName: String, logger: String) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: .expr(ExprSyntax(
                FunctionCallExprSyntax(
                    calledExpression: DeclReferenceExprSyntax(baseName: .identifier(logger)),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax([
                        LabeledExprSyntax(
                            expression: StringLiteralExprSyntax(content: "Entering function: \(functionName)")
                        )
                    ]),
                    rightParen: .rightParenToken()
                )
            ))
        )
    }
    
    /// Creates the function exit logging statement using defer.
    /// - Parameters:
    ///   - functionName: Name of the function being logged.
    ///   - logger: Logger function or closure to use.
    /// - Returns: Code block item for exit logging
    private static func createExitLogStatement(functionName: String, logger: String) -> CodeBlockItemSyntax {
        return CodeBlockItemSyntax(
            item: .stmt(StmtSyntax(
                DeferStmtSyntax(
                    deferKeyword: .keyword(.defer),
                    body: CodeBlockSyntax(
                        leftBrace: .leftBraceToken(),
                        statements: CodeBlockItemListSyntax([
                            CodeBlockItemSyntax(
                                item: .expr(ExprSyntax(
                                    FunctionCallExprSyntax(
                                        calledExpression: DeclReferenceExprSyntax(baseName: .identifier(logger)),
                                        leftParen: .leftParenToken(),
                                        arguments: LabeledExprListSyntax([
                                            LabeledExprSyntax(
                                                expression: StringLiteralExprSyntax(content: "Exiting function: \(functionName)")
                                            )
                                        ]),
                                        rightParen: .rightParenToken()
                                    )
                                ))
                            )
                        ]),
                        rightBrace: .rightBraceToken()
                    )
                )
            ))
        )
    }
    
    /// Creates logging statements for each function parameter.
    /// - Parameters:
    ///   - funcDecl: The function declaration syntax.
    ///   - logger: Logger function or closure to use.
    /// - Returns: Array of code block items for parameter logging
    private static func createParameterPrintStatements(funcDecl: FunctionDeclSyntax, logger: String) -> [CodeBlockItemSyntax] {
        // Extract parameter names
        let params = funcDecl.signature.parameterClause.parameters
        var printStatements: [CodeBlockItemSyntax] = []
        var paramCounter = 1
        
        for param in params {
            let paramName = param.firstName.text
            let paramType = param.type.description.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create interpolated string expression for parameter value
            let interpolatedString = """
                "Parameter \(paramCounter) Name: \(paramName) = \\(\(paramName)) : of type : \(paramType)"
                """
            
            // Parse the interpolated string as an expression
            let printStmt = CodeBlockItemSyntax(
                item: .expr(ExprSyntax(
                    FunctionCallExprSyntax(
                        calledExpression: DeclReferenceExprSyntax(baseName: .identifier(logger)),
                        leftParen: .leftParenToken(),
                        arguments: LabeledExprListSyntax([
                            LabeledExprSyntax(
                                expression: ExprSyntax(stringLiteral: interpolatedString)
                            )
                        ]),
                        rightParen: .rightParenToken()
                    )
                ))
            )
            printStatements.append(printStmt)
            paramCounter += 1
        }
        return printStatements
    }
}

@main
struct SwiftLoggableMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LoggableMacro.self,
    ]
}
