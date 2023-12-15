//  Created by Axel Ancona Esselmann on 12/14/23.
//

import SwiftUI

public protocol MDElement: Identifiable {
    var id: UUID { get }
}

public struct MDText: MDElement {
    public let id = UUID()
    public let string: String

    public init(string: String) {
        self.string = string
    }
}

public struct MDHeader: MDElement {
    public enum Size: Int {
        case one = 1, two = 2, three = 3
    }

    public let id = UUID()
    public let size: Size
    public let string: String

    public init(size: Size, string: String) {
        self.size = size
        self.string = string
    }
}

public struct MDCodeMarker: MDElement {
    public let id = UUID()

    public init() {

    }
}

public struct MDListRow: MDElement {
    public let id = UUID()
    public let string: String

    public init(string: String) {
        self.string = string
    }
}

public struct MDList: MDElement, MDGroup {
    public let id = UUID()
    public var elements: [any MDElement]

    public var listRows: [MDListRow] {
        elements.compactMap { $0 as? MDListRow }
    }

    public init(elements: [any MDElement] = []) {
        self.elements = elements
    }
}

public struct MDCode: MDElement, MDGroup {
    public let id = UUID()
    public var elements: [any MDElement]
    public var code: String {
        return elements
            .compactMap { $0 as? MDText }
            .map { $0.string }
            .joined(separator: "\n")
    }

    public init(elements: [any MDElement] = []) {
        self.elements = elements
    }
}

public struct MDFrame: MDElement, MDGroup {
    public let id = UUID()
    public var elements: [any MDElement]

    public init(elements: [any MDElement] = []) {
        self.elements = elements
    }
}

public protocol MDGroup: MDElement {
    var elements: [any MDElement] { get set }
}

public struct MDDocument: MDElement {
    public let id = UUID()
    public var frames: [any MDGroup] = []

    public init(_ lineTokens: [any MDElement]) {
        var stack: [any MDGroup] = []
        var currentFrame: any MDGroup = MDFrame()
        for lineToken in lineTokens {
            if let frame = currentFrame as? MDList, !(lineToken is MDListRow) {
                currentFrame = stack.removeLast()
                currentFrame.elements.append(frame)
            }
            switch lineToken {
            case let header as MDHeader:
                if !currentFrame.elements.isEmpty {
                    frames.append(currentFrame)
                    currentFrame = MDFrame()
                }
                currentFrame.elements.append(lineToken)
            case let text as MDText:
                currentFrame.elements.append(lineToken)
            case let listRow as MDListRow:
                if var frame = currentFrame as? MDList {
                    frame.elements.append(listRow)
                    currentFrame = frame
                } else {
                    stack.append(currentFrame)
                    var frame = MDList()
                    frame.elements.append(listRow)
                    currentFrame = frame
                }
            case is MDCodeMarker:
                if let frame = currentFrame as? MDCode {
                    currentFrame = stack.removeLast()
                    currentFrame.elements.append(frame)
                } else {
                    stack.append(currentFrame)
                    currentFrame = MDCode()
                }
            default:
                ()
            }
        }
        if let frame = currentFrame as? MDList {
            currentFrame = stack.removeLast()
            currentFrame.elements.append(frame)
        }
        if !currentFrame.elements.isEmpty {
            frames.append(currentFrame)
        }
    }
}

public struct MDDecoder {
    public let style: MarkdownStyle

    public func lineToken(_ line: String) -> any MDElement {
        var string = line
        if let dataProvider = style.dataProvider {
            string.insertData(using: dataProvider)
        }
        string.mapLink(using: style.linkConversionRules)
        if string.hasPrefix("### ") {
            return MDHeader(
                size: .three,
                string: String(string.deletingPrefix("### "))
            )
        } else if string.hasPrefix("## ") {
            return MDHeader(
                size: .two,
                string: String(string.deletingPrefix("## "))
            )
        } else if string.hasPrefix("# ") {
            return MDHeader(
                size: .one,
                string: String(string.deletingPrefix("# "))
            )
        } else if string.hasPrefix("- ") {
            return MDListRow(
                string: String(string.deletingPrefix("- "))
            )
        } else if string.hasPrefix("```") {
            return MDCodeMarker()
        } else {
            return MDText(string: string)
        }
    }
}
