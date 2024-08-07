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
            let (leading, trailing, top, bottom) = Self.padding(from: elementStyles[.codeBlock]?.padding ?? [])
            CodeView(code: code.codeString)
                .padding(.leading, leading)
                .padding(.trailing, trailing)
                .padding(.top, top)
                .padding(.bottom, bottom)
        case let mdImage as MDImage:
            let (leading, trailing, top, bottom) = Self.padding(from: elementStyles[.image]?.padding ?? [])
            let size: CGSize? = {
                if let style = mdImage.style {
                    return style.size
                } else {
                    return nil
                }
            }()
            AsyncImage(url: mdImage.url) { image in
                if let size = size {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width, height: size.height)
                } else {
                    image
                }
            } placeholder: {
                if let size = size {
                    ProgressView()
                        .frame(width: size.width, height: size.height)
                } else {
                    ProgressView()
                }
            }
            .if(mdImage.style?.shape == .circle) {
                $0.clipShape(Circle())
            }
            .padding(.leading, leading)
            .padding(.trailing, trailing)
            .padding(.top, top)
            .padding(.bottom, bottom)
        case let rule as MDRule:
            let (leading, trailing, top, bottom) = Self.padding(from: elementStyles[.rule]?.padding ?? [])
            Divider()
                .padding(.leading, leading)
                .padding(.trailing, trailing)
                .padding(.top, top)
                .padding(.bottom, bottom)
        case let lineBreak as MDLineBreak:
            let (_, _, top, bottom) = Self.padding(from: elementStyles[.lineBreak]?.padding ?? [])
            Spacer()
                .frame(height: 0)
                .padding(.top, top)
                .padding(.bottom, bottom)
        case let frame as MDFrame:
            VStack(alignment: .leading) {
                ForEach(frame.elements, id: \.id) { element in
                    AnyView(Self.view(for: element, elementStyles: elementStyles))
                }
            }
        case let document as MDDocument:
            let (_, _, top, bottom) = Self.padding(from: elementStyles[.frame]?.padding ?? [.top(64)])
            VStack(alignment: .leading, spacing: top + bottom) {
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
            let tokenizer = MDTokenizer(
                markdown: markdown,
                style: style
            )
            let document = MDDocument(tokenizer.tokenize())
            Self.view(for: document, elementStyles: style.elementStyles)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
