import SwiftUI
import AuthenticationServices

struct WelcomeStepView: View {
    @EnvironmentObject private var authService: AuthService
    var onContinueGuest: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Welcome to FitnessTracker")
                .font(.largeTitle).bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text("Sign in to sync and save your data")
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                SignInWithAppleButton(.signIn, onRequest: { _ in
                    authService.signInWithApple()
                }, onCompletion: { _ in })
                .signInWithAppleButtonStyle(.black)
                .frame(height: 44)

                // Placeholder for Google until added
                Button(action: {}) { Text("Sign in with Google").frame(maxWidth: .infinity) }
                    .buttonStyle(.bordered)
                    .frame(height: 44)
            }
            .padding(.horizontal)

            Spacer()

            Button(action: onContinueGuest) {
                Text("Continue as Guest")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom)
        }
        .padding()
        .onReceive(authService.$isAuthenticated) { authed in
            if authed {
                onContinueGuest() // proceed to main upon auth success
            }
        }
    }
}


