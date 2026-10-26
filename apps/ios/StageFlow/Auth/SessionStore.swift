import Foundation
import Observation

@MainActor @Observable
final class SessionStore {
    enum State { case signedOut, signingIn, signedIn, failed(String) }
    private(set) var state: State = .signedOut
    private(set) var accessToken: String?
    private let keychain = KeychainStore()

    init() {
        accessToken = keychain.read(account: "access-token")
        state = accessToken == nil ? .signedOut : .signedIn
    }

    func signIn() async {
        state = .signingIn
        do {
            let configuration = try AppConfiguration.live()
            let tokens = try await OIDCClient(configuration: configuration).authenticate()
            try keychain.save(tokens.accessToken, account: "access-token")
            if let refresh = tokens.refreshToken { try keychain.save(refresh, account: "refresh-token") }
            accessToken = tokens.accessToken
            state = .signedIn
        } catch { state = .failed(error.localizedDescription) }
    }

    func signOut() { keychain.clear(); accessToken = nil; state = .signedOut }
}
