import Foundation

struct AppConfiguration: Sendable {
    let apiBaseURL: URL
    let issuerURL: URL
    let clientID: String
    let callbackURL = URL(string: "stageflow://oauth/callback")!

    static func live(bundle: Bundle = .main) throws -> Self {
        func value(_ key: String) throws -> String {
            guard let value = bundle.object(forInfoDictionaryKey: key) as? String, !value.isEmpty else {
                throw ConfigurationError.missing(key)
            }
            return value
        }
        guard let apiURL = URL(string: try value("APIBaseURL")),
              let issuerURL = URL(string: try value("OIDCIssuer")) else {
            throw ConfigurationError.invalidURL
        }
        return Self(apiBaseURL: apiURL, issuerURL: issuerURL, clientID: try value("OIDCClientID"))
    }

    enum ConfigurationError: LocalizedError {
        case missing(String), invalidURL
        var errorDescription: String? {
            switch self { case .missing(let key): "Missing configuration: \(key)"; case .invalidURL: "A configured URL is invalid" }
        }
    }
}
