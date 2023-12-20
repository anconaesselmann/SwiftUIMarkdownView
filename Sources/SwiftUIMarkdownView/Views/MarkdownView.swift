//  Created by Axel Ancona Esselmann on 12/10/23.
//

import SwiftUI

public struct MarkdownView: View {

    internal let style: MarkdownStyle
    internal let markdown: String

    public init(style: MarkdownStyle = MarkdownStyle(), markdown: String) {
        self.markdown = markdown
        self.style = style
    }

    private static func header(_ text: Text, for size: Int, elementStyles: [MDElementType: MDElementStyle]) -> some View {
        let elementStyle: MDElementStyle?
        let font: Font
        if size <= 1 {
            font = .title
            elementStyle = elementStyles[.header(1)]
        } else if size == 2 {
            font = .title2
            elementStyle = elementStyles[.header(2)]
        } else {
            font = .title3
            elementStyle = elementStyles[.header(3)]
        }
        let (leading, trailing, top, bottom) = Self.padding(from: elementStyle?.padding ?? [])
        return text
            .font(font)
            .padding(.leading, leading)
            .padding(.trailing, trailing)
            .padding(.top, top)
            .padding(.bottom, bottom)
    }

    private static func padding(from padding: Set<MDElementStyle.Padding>) -> (leading: Double, trailing: Double, top: Double, bottom: Double) {
        var leading: Double = 0
        var trailing: Double = 0
        var top: Double = 0
        var bottom: Double = 0
        for padding in padding {
            switch padding {
            case .leading(let value):
                leading += value
            case .trailing(let value):
                trailing += value
            case .top(let value):
                top += value
            case .bottom(let value):
                bottom += value
            case .vertical(let value):
                top += value
                bottom += value
            case .horizontal(let value):
                leading += value
                trailing += value
            }
        }
        return (leading: leading, trailing: trailing, top: top, bottom: bottom)
    }

    @ViewBuilder
    private static func view(for element: any MDElement, elementStyles: [MDElementType: MDElementStyle]) -> some View {
        switch element {
        case let text as MDInterpolatedText:
            let (leading, trailing, top, bottom) = Self.padding(from: elementStyles[.text]?.padding ?? [])
            text.text
                .padding(.leading, leading)
                .padding(.trailing, trailing)
                .padding(.top, top)
                .padding(.bottom, bottom)
        case let plainText as MDPlainText:
            let (leading, trailing, top, bottom) = Self.padding(from: elementStyles[.text]?.padding ?? [])
            Text(LocalizedStringKey(plainText.string))
                .padding(.leading, leading)
                .padding(.trailing, trailing)
                .padding(.top, top)
                .padding(.bottom, bottom)
        case let header as MDHeader:
            Self.header(header.text, for: header.size.rawValue, elementStyles: elementStyles)
        case let listRow as MDListRow:
            EmptyView()
        case let list as MDList:
            let (leading, trailing, top, bottom) = Self.padding(from: elementStyles[.listItem]?.padding ?? [])
            ForEach(list.listRows, id: \.id) { listRow in
                HStack {
                    VStack(alignment: .leading) {
                        Text("•")
                        Spacer()
                    }
                    listRow.text
                }
                .padding(.leading, leading)
                .padding(.trailing, trailing)
                .padding(.top, top)
                .padding(.bottom, bottom)
            }
        case let code as MDCode:
            CodeView(code: code.codeString)
        case let frame as MDFrame:
            VStack(alignment: .leading) {
                ForEach(frame.elements, id: \.id) { element in
                    AnyView(Self.view(for: element, elementStyles: elementStyles))
                }
            }
//            .background(SwiftUI.Color.random)
        case let document as MDDocument:
            VStack(alignment: .leading, spacing: 64) {
                ForEach(document.frames, id: \.id) { frame in
                    AnyView(Self.view(for: frame, elementStyles: elementStyles))
                }
            }
        default:
            EmptyView()
        }
    }

    public var body: some View {
        VStack(spacing: 4) {
            let decoder = MDDecoder(style: style)
            let lineTokens = markdown.split(separator: "\n").map {
                decoder.lineToken(String($0))
            }
            let document = MDDocument(lineTokens)
            Self.view(for: document, elementStyles: style.elementStyles)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


public extension SwiftUI.Color {
    static var random: SwiftUI.Color {
        SwiftUI.Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
