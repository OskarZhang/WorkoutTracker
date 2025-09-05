import SwiftUI
import SwiftData
import UIKit

struct OnboardingFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding: Bool = false
    @State private var didSaveProfile: Bool = false

    @State private var heightCm: Int = 170
    @State private var weightKg: Int = 70
    @State private var age: Int = 25
    @State private var goal: UserGoal = .recomp
    @State private var gymDaysPerWeek: Int = 3

    @State private var selection: Int = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $selection) {
                    IntroStepView()
                        .tag(0)
                    VitalsStepView(heightCm: $heightCm, weightKg: $weightKg, age: $age)
                        .tag(1)
                    GoalStepView(goal: $goal)
                        .tag(2)
                    GymDaysStepView(gymDaysPerWeek: $gymDaysPerWeek)
                        .tag(3)
                    WelcomeStepView(onContinueGuest: completeOnboarding)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                // Bottom Next button
                if selection < 4 {
                    Button(action: {
                        dismissKeyboard()
                        selection += 1
                        if selection == 4 { saveProfileIfNeeded() }
                    }) {
                        Text(selection == 0 ? "Let’s get started" : "Next")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if selection > 0 {
                        Button(action: {
                            dismissKeyboard()
                            selection -= 1
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
            }
            .navigationTitle("")
            .padding()
            .onChange(of: selection) { newValue in
                if newValue > 1 { dismissKeyboard() }
            }
        }
    }

    private func completeOnboarding() {
        saveProfileIfNeeded()
        didCompleteOnboarding = true
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func saveProfileIfNeeded() {
        guard !didSaveProfile else { return }
        let profile = UserProfile(heightCm: heightCm, weightKg: weightKg, age: age, goal: goal, gymDaysPerWeek: gymDaysPerWeek)
        modelContext.insert(profile)
        try? modelContext.save()
        didSaveProfile = true
    }
}


