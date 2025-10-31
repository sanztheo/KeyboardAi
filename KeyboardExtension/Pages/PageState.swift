//
//  PageState.swift
//  KeyboardExtension
//
//  Page navigation system
//

import Foundation

enum PageState {
    case home
    case askAIInput
    case response(type: ResponseType)
}

enum ResponseType {
    case improve
    case shorten
    case lengthen
    case askAI

    var title: String {
        switch self {
        case .improve: return "Improved Text"
        case .shorten: return "Shortened Text"
        case .lengthen: return "Lengthened Text"
        case .askAI: return "AI Response"
        }
    }
}
