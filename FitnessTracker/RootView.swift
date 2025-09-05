import SwiftUI

struct RootView: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding: Bool = false
    @StateObject private var authService = AuthService.shared

    var body: some View {
        Group {
            if didCompleteOnboarding {
                ContentView()
            } else {
                OnboardingFlowView()
            }
        }
        .environmentObject(authService)
    }
}


