//  Created by Axel Ancona Esselmann on 12/10/23.
//

import LoadableView
import SwiftUI
import Combine

public struct AsyncMarkdownView: IDedDefaultLoadableView {

    public var id: URL

    private let style: MarkdownStyle

    @StateObject
    public var vm = AsyncMarkdownViewModel()

    public init(style: MarkdownStyle = MarkdownStyle(), id: URL) {
        self.id = id
        self.style = style
    }

    public func loaded(_ markdown: String) -> some View {
        MarkdownView(style: style, markdown: markdown)
    }
}

@MainActor
public final class AsyncMarkdownViewModel: IDedLoadableViewModel {

    public var id: URL?

    @Published
    public var viewState: ViewState<String> = .notLoaded

    public var overlayState: OverlayState = .none

    private let service = MarkdownService()

    private var bag = Set<AnyCancellable>()

    public func load(id url: URL) async throws -> String {
        try await service.fetch(url)
    }
}
