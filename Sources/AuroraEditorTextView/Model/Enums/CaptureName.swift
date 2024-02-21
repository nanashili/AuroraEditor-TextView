//
//  CaptureNames.swift
//  CodeEditTextView
//
//  Created by Nanashi Li on 29/12/23.
//

/// A collection of possible capture names for `tree-sitter` with their respected raw values.
/// Enumeration representing different capture names or token types in programming.
///
/// Capture names are used to classify and identify various elements within a programming code or script.
/// This enumeration provides a set of predefined capture names commonly used in code syntax highlighting and parsing.
///
/// - Note: Depending on the context and programming language, different capture names may be used.
///  The main types of nodes which are spell checked are:
///  Comments
///  Strings; where it makes sense. Strings that have interpolation or are typically used for non text
///  purposes are not spell checked (e.g. bash).
///
/// - SeeAlso: `HighlightProvider`
///
/// - Tag: CaptureName
public enum CaptureName: String, CaseIterable {
    /// Represents include directives or imports for external libraries/modules.
    case include
    /// Typically used to identify constructor functions or methods for creating objects.
    case constructor
    /// Denotes reserved keywords or language-specific keywords.
    case keyword
    /// Represents boolean values (`true` or `false`).
    case boolean
    /// May indicate loops or repetition constructs.
    case `repeat`
    /// Used for conditional statements (e.g., `if`, `else`, `switch`, etc.).
    case conditional
    /// Often associated with HTML or XML tags.
    case tag
    /// Identifies comments or annotations in the code.
    case comment
    /// Denotes variable names or identifiers.
    case variable
    /// Represents object properties or attributes.
    case property
    /// Indicates function or method names.
    case function
    /// Often used to identify class methods or object methods.
    case method
    /// Represents numeric values (e.g., integers or floating-point numbers).
    case number
    /// Specifically identifies floating-point numbers.
    case float
    /// Denotes string literals or character sequences.
    case string
    /// Used for data types or type names.
    case type
    /// Represents function or method parameters.
    case parameter
    /// An alternate or custom type identifier.
    case typeAlternate = "type_alternate"
    /// Identifies built-in or predefined variables.
    case variableBuiltin = "variable.builtin"
    /// Specifically represents the `return` keyword.
    case keywordReturn = "keyword.return"
    /// Specifically represents the `function` keyword (in some languages).
    case keywordFunction = "keyword.function"
    /// Used to identify a variable, function, class, module, or any other user-defined entity.
    case identifier
    /// Represents operators used in expressions.
    case `operator`
    /// Denotes constants or constant values.
    case constant
    /// Represents attributes associated with code elements.
    case attribute
    /// Denotes embedded content or code within another context.
    case embedded
    /// Syntax/Parser Errors
    case error
    /// Completely disable the highlight.
    case none
    /// Various preprocessor directives & shebangs.
    case prepoc
    /// Preprocessor definition directives.
    case define
    /// Keywords related to debugging.
    case debug
    /// Keywords related to exceptions (e.g. `throw` / `catch`).
    case exception
    /// GOTO and other labels (e.g. `label:` in C).
    case label
    /// Object and struct fields.
    case field
    /// Modifiers that affect storage in memory or lifetime.
    case storageclass
    /// Symbols or atoms.
    case symbol
    /// Modules or namespaces.
    case namespace
    /// For captures that are only used for concealing.
    case conceal
    /// For defining regions to be spellchecked.
    case spell
    /// For defining regions that should NOT be spellchecked.
    case nospell
    case fold

    /// Returns a specific capture name case from a given string.
    /// - Parameter string: A string to get the capture name from
    /// - Returns: A `CaptureNames` case
    static func fromString(_ string: String?) -> CaptureName? {
        CaptureName(rawValue: string ?? "")
    }

    var alternate: CaptureName {
        switch self {
        case .type:
            return .typeAlternate
        default:
            return self
        }
    }
}
