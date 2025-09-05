import Foundation
import AuthenticationServices
import Combine

final class AuthService: NSObject, ObservableObject {
    static let shared = AuthService()

    @Published private(set) var isAuthenticated: Bool = false
    @Published private(set) var userId: String?
    @Published private(set) var email: String?

    private var cancellables = Set<AnyCancellable>()
    private let backend: AuthBackend = AuthAPI.shared

    private override init() { }

    // MARK: - Apple Sign In

    func signInWithApple(nonce: String? = nil) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        // If using a backend or Firebase, supply a nonce here
        // request.nonce = nonce

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func handleAppleCredential(_ credential: ASAuthorizationAppleIDCredential) {
        // Extract token for backend verification
        guard let tokenData = credential.identityToken, let token = String(data: tokenData, encoding: .utf8) else {
            return
        }
        Task { @MainActor in
            do {
                let session = try await backend.exchangeApple(idToken: token, nonce: nil)
                self.isAuthenticated = true
                self.userId = session.userId
                self.email = session.email ?? self.email
            } catch {
                print("Auth backend error: \(error)")
            }
        }
    }
}

extension AuthService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            handleAppleCredential(appleIDCredential)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle errors (user cancellation, network, etc.)
        print("Apple Sign-In error: \(error.localizedDescription)")
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Best-effort obtain a key window
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}


