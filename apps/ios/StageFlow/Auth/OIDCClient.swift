import AuthenticationServices
import CryptoKit
import Foundation
import Security
import UIKit

@MainActor
final class OIDCClient: NSObject, ASWebAuthenticationPresentationContextProviding {
    private let configuration: AppConfiguration
    private var webSession: ASWebAuthenticationSession?

    init(configuration: AppConfiguration) { self.configuration = configuration }

    func authenticate() async throws -> TokenResponse {
        let verifier = Self.randomURLSafeString(byteCount: 32)
        let challenge = Data(SHA256.hash(data: Data(verifier.utf8))).base64URLEncodedString()
        let state = Self.randomURLSafeString(byteCount: 24)
        var components = URLComponents(url: configuration.issuerURL.appending(path: "protocol/openid-connect/auth"), resolvingAgainstBaseURL: false)!
        components.queryItems = [
            .init(name: "client_id", value: configuration.clientID), .init(name: "redirect_uri", value: configuration.callbackURL.absoluteString),
            .init(name: "response_type", value: "code"), .init(name: "scope", value: "openid profile email offline_access"),
            .init(name: "state", value: state), .init(name: "code_challenge", value: challenge), .init(name: "code_challenge_method", value: "S256")
        ]
        let callback = try await authorize(url: components.url!)
        guard let callbackComponents = URLComponents(url: callback, resolvingAgainstBaseURL: false),
              callbackComponents.queryItems?.first(where: { $0.name == "state" })?.value == state,
              let code = callbackComponents.queryItems?.first(where: { $0.name == "code" })?.value else { throw OIDCError.invalidCallback }
        return try await exchange(code: code, verifier: verifier)
    }

    private func authorize(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(url: url, callbackURLScheme: configuration.callbackURL.scheme) { url, error in
                if let error { continuation.resume(throwing: error) }
                else if let url { continuation.resume(returning: url) }
                else { continuation.resume(throwing: OIDCError.invalidCallback) }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self.webSession = session
            guard session.start() else { continuation.resume(throwing: OIDCError.cannotStart) ; return }
        }
    }

    private func exchange(code: String, verifier: String) async throws -> TokenResponse {
        var request = URLRequest(url: configuration.issuerURL.appending(path: "protocol/openid-connect/token"))
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = ["grant_type": "authorization_code", "client_id": configuration.clientID, "code": code,
                            "redirect_uri": configuration.callbackURL.absoluteString, "code_verifier": verifier]
            .map { key, value in "\(key.urlEncoded)=\(value.urlEncoded)" }.joined(separator: "&").data(using: .utf8)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else { throw OIDCError.tokenExchangeFailed }
        return try JSONDecoder().decode(TokenResponse.self, from: data)
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap(\.windows).first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    private static func randomURLSafeString(byteCount: Int) -> String {
        var bytes = [UInt8](repeating: 0, count: byteCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, byteCount, &bytes)
        return Data(bytes).base64URLEncodedString()
    }

    enum OIDCError: Error { case invalidCallback, cannotStart, tokenExchangeFailed }
}

struct TokenResponse: Codable, Sendable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    enum CodingKeys: String, CodingKey { case accessToken = "access_token", refreshToken = "refresh_token", expiresIn = "expires_in" }
}

private extension Data {
    func base64URLEncodedString() -> String { base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "") }
}
private extension String { var urlEncoded: String { addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+&="))) ?? self } }
