//  Created by Axel Ancona Esselmann on 12/10/23.
//

import Foundation

public struct MarkdownService {

    public enum Error: Swift.Error {
        case invalidMarkdownText
    }

    public func fetch(_ url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let markdown = String(data: data, encoding: .utf8) else {
            throw Error.invalidMarkdownText
        }
        return markdown
    }
}
