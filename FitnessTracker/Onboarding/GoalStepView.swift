import SwiftUI

struct GoalStepView: View {
    @Binding var goal: UserGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your goal").font(.title2).bold()
            HStack(spacing: 16) {
                GoalCard(title: "Gain", isSelected: goal == .gain) { goal = .gain }
                GoalCard(title: "Lose", isSelected: goal == .lose) { goal = .lose }
                GoalCard(title: "Recomp", isSelected: goal == .recomp) { goal = .recomp }
            }
            Spacer()
        }
        .padding()
    }
}

private struct GoalCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 28, weight: .medium))
                Text(title)
                    .font(.body)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).strokeBorder(isSelected ? Color.accentColor : Color.secondary, lineWidth: isSelected ? 2 : 1))
        }
        .buttonStyle(.plain)
    }

    private var iconName: String {
        switch title.lowercased() {
        case "gain": return "arrow.up.circle"
        case "lose": return "arrow.down.circle"
        default: return "arrow.left.and.right.circle"
        }
    }
}


