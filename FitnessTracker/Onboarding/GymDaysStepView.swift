import SwiftUI

struct GymDaysStepView: View {
    @Binding var gymDaysPerWeek: Int

    private let days = Array(1...7)

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("How many days per week?").font(.title2).bold()
            Picker("Gym Days", selection: $gymDaysPerWeek) {
                ForEach(days, id: \.self) { d in
                    Text("\(d) days").tag(d)
                }
            }
            .pickerStyle(.wheel)
            .frame(maxHeight: 150)
            Spacer()
        }
        .padding()
    }
}


