import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Picker("", selection: $selectedTab) {
                    Text("Current").tag(0)
                    Text("Craft Routine").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if selectedTab == 0 {
                    CurrentRoutineView()
                } else {
                    CraftRoutineView()
                }
                Spacer(minLength: 0)
            }
            .navigationTitle("Today")
        }
    }
}



