import SwiftUI

struct SetLoggingView: View {
    @Binding var isPresented: Bool
    let exerciseName: String
    let onSave: ([StrengthSet]) -> Void

    @State private var sets: [StrengthSet] = [StrengthSet(weightInLbs: 0, reps: 0)]

    var body: some View {
        NavigationView {
            VStack {
                Text(exerciseName)
                    .font(.largeTitle)
                    .padding()

                List {
                    ForEach(sets.indices, id: \.self) { index in
                        HStack {
                            Text("Set \(index + 1)")
                            Spacer()
                            TextField("Weight", value: $sets[index].weightInLbs, formatter: NumberFormatter())
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                            TextField("Reps", value: $sets[index].reps, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .frame(width: 80)
                        }
                    }
                    .onDelete(perform: deleteSet)

                    Button(action: addSet) {
                        Label("Add Set", systemImage: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("Log Sets")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Done") {
                    onSave(sets)
                    isPresented = false
                }
            )
        }
    }

    private func addSet() {
        sets.append(StrengthSet(weightInLbs: 0, reps: 0))
    }

    private func deleteSet(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
    }
}
