//  Created by Axel Ancona Esselmann on 12/15/23.
//

import SwiftUI
import Splash

struct CodeView: View {

    let code: String

    var attributedString: AttributedString {
        let highlighter = SyntaxHighlighter(
            format: AttributedStringOutputFormat(
                theme: Theme.xcodeColors(
                    withFont: Font(size: 14)
                )
            )
        )
        return AttributedString(highlighter.highlight(code))
    }

    var body: some View {
        ZStack {
            GroupBox {
                Text(attributedString)
                    .fontWeight(.medium)
                    .padding()
                    .lineSpacing(4)
                    .monospaced()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .groupBoxStyle(CardGroupBoxStyle())
            VStack {
                HStack {
                    Spacer()
                    #if os(macOS)
                    Button {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(code, forType: .string)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }.padding()
                    #endif
                }
                Spacer()
            }
        }
    }
}

struct CardGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(SwiftUI.Color.black.opacity(0.4), lineWidth: 1)
        )
    }
}
