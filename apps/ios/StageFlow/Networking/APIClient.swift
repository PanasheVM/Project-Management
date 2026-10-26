import Foundation

actor APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func companies(accessToken: String) async throws -> [Company] {
        var request = URLRequest(url: baseURL.appending(path: "api/v1/companies"))
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw APIError.http(http.statusCode) }
        return try JSONDecoder().decode([Company].self, from: data)
    }

    enum APIError: LocalizedError {
        case invalidResponse, http(Int)
        var errorDescription: String? {
            switch self { case .invalidResponse: "The server response was invalid"; case .http(let status): "The server returned HTTP \(status)" }
        }
    }
}
