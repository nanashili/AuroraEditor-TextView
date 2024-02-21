//
//  IndentOption.swift
//
//
//  Created by Nanashi Li on 29/12/23.
//

/// An enumeration to specify indentation options.
public enum IndentOption: Equatable {
    /// Indentation with a specific number of spaces.
    case spaces(count: Int)
    /// Indentation with a tab.
    case tab

    /// A string representation of the indentation option.
    var stringValue: String {
        switch self {
        case .spaces(let count):
            return String(repeating: " ", count: count)
        case .tab:
            return "\t"
        }
    }
}
