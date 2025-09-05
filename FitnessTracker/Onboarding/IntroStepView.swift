import SwiftUI

struct IntroStepView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Welcome to FitnessTracker")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text("FitnessTracker is here to whip you in shape, powered by AI.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
        }
        .padding()
    }
}


