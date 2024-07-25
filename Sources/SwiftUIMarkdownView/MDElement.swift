//  Created by Axel Ancona Esselmann on 12/14/23.
//

import SwiftUI

public protocol MDElement: Identifiable {
    var id: UUID { get }
}

public struct MDPlainText: MDElement {
    public let id = UUID()
    public let string: String

    public init(string: String) {
        self.string = string
    }
}

public struct MDInterpolatedText: MDElement {
    public let id = UUID()
    public let text: Text

    public init(text: Text) {
        self.text = text
    }
}

public struct MDHeader: MDElement {
    public enum Size: Int {
        case one = 1, two = 2, three = 3
    }

    public let id = UUID()
    public let size: Size
    public let text: Text

    public init(size: Size, text: Text) {
        self.size = size
        self.text = text
    }
}

public struct MDCodeMarker: MDElement {
    public let id = UUID()

    public init() {

    }
}

public struct MDRule: MDElement {
    public let id = UUID()
}

public struct MDLineBreak: MDElement {
    public let id = UUID()
    public var numberLines: Int = 1
}

public struct MDListRow: MDElement {
    public let id = UUID()
    public let text: Text

    public init(text: Text) {
        self.text = text
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
    public var codeString: String {
        elements
            .compactMap { $0 as? MDPlainText }
            .map { $0.string }
            .joined(separator: "\n")
    }

    public init(elements: [any MDElement] = []) {
        self.elements = elements
    }
}

public struct MDImageStyle {
    public enum Shape {
        case `default`
        case circle
    }

    public init(size: CGSize?, shape: Shape = .default) {
        self.size = size
        self.shape = shape
    }
    
    public let size: CGSize?
    public let shape: Shape
}

public struct MDImage: MDElement {
    public let id: UUID
    public let altText: String
    public let url: URL
    public let style: MDImageStyle?

    public init(altText: String, url: URL, style: MDImageStyle? = nil) {
        self.id = UUID()
        self.altText = altText
        self.url = url
        self.style = style
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
            case let text as MDPlainText:
                currentFrame.elements.append(lineToken)
            case let text as MDInterpolatedText:
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
            case let image as MDImage:
                currentFrame.elements.append(image)
            case let rule as MDRule:
                currentFrame.elements.append(rule)
            case let lineBreak as MDLineBreak:
                if var previousLineBreak = currentFrame.elements.last as? MDLineBreak {
                    previousLineBreak.numberLines += 1
                    currentFrame.elements[currentFrame.elements.count - 1] = previousLineBreak
                } else {
                    currentFrame.elements.append(lineBreak)
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

public struct MDTokenizer {
    private let markdown: String
    public let style: MarkdownStyle

    public init(markdown: String, style: MarkdownStyle) {
        self.markdown = markdown
        self.style = style
    }

    public func tokenize() -> [any MDElement] {
        var lines = markdown
            .replacing("\r\n", with: "\n")
            .replacing("\r", with: "\n")
            .split(separator: "\n")
        var links = [String: URL]()
        while true {
            guard !lines.isEmpty else {
                break
            }
            guard let last = lines.last else {
                break
            }
            if let (key, url) = String(last).readLink() {
                links[key] = url
                let _ = lines.popLast()
            } else {
                break
            }
        }
        return lines.map {
            lineToken(String($0), links: links)
        }
    }

    private func lineToken(_ line: String, links: [String: URL]) -> any MDElement {
        var string = line
        if let dataProvider = style.dataProvider {
            string.insertData(using: dataProvider)
        }
        string.expandSquareLink(using: links)
        string.mapLink(using: style.linkConversionRules)
        if let image = string.mdImage(using: style.imageConversionRules) {
            return image
        } else if let rule = string.mdRule() {
            return rule
        } else if let lineBreak = string.lineBreak() {
            return lineBreak
        } else if string.hasPrefix("### ") {
            let trimmed = string.deletingPrefix("### ")
            let text = trimmed.interpolatedText() ?? Text(LocalizedStringKey(trimmed))
            return MDHeader(
                size: .three,
                text: text
            )
        } else if string.hasPrefix("## ") {
            let trimmed = string.deletingPrefix("## ")
            let text = trimmed.interpolatedText() ?? Text(LocalizedStringKey(trimmed))
            return MDHeader(
                size: .two,
                text: text
            )
        } else if string.hasPrefix("# ") {
            let trimmed = string.deletingPrefix("# ")
            let text = trimmed.interpolatedText() ?? Text(LocalizedStringKey(trimmed))
            return MDHeader(
                size: .one,
                text: text
            )
        } else if string.hasPrefix("- ") {
            let trimmed = string.deletingPrefix("- ")
            let text = trimmed.interpolatedText() ?? Text(LocalizedStringKey(trimmed))
            return MDListRow(
                text: text
            )
        } else if string.hasPrefix("```") {
            return MDCodeMarker()
        } else if let interpolated = string.interpolatedText() {
            return MDInterpolatedText(text: interpolated)
        } else {
            return MDPlainText(string: string)
        }
    }
}
