import Foundation

struct Session: Codable {
    let accessToken: String
    let userId: String
    let email: String?
}

protocol AuthBackend {
    func exchangeApple(idToken: String, nonce: String?) async throws -> Session
    func exchangeGoogle(idToken: String) async throws -> Session
}

final class AuthAPI: AuthBackend {
    static let shared = AuthAPI()

    private init() {}

    func exchangeApple(idToken: String, nonce: String?) async throws -> Session {
        // TODO: Implement network call to your backend
        // Placeholder session
        return Session(accessToken: idToken, userId: UUID().uuidString, email: nil)
    }

    func exchangeGoogle(idToken: String) async throws -> Session {
        // TODO: Implement network call to your backend
        return Session(accessToken: idToken, userId: UUID().uuidString, email: nil)
    }
}


