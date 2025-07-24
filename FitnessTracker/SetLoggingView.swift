import SwiftUI

struct SetLoggingView: View {
    @Binding var isPresented: Bool
    let exerciseName: String
    let onSave: ([StrengthSet]) -> Void

    @State private var sets: [StrengthSet] = [StrengthSet(weightInLbs: 0, reps: 0)]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text(exerciseName)
                    .padding()
                    .font(.largeTitle)
                    .fontWeight(.medium)


                List {
                    ForEach(sets.indices, id: \.self) { index in
                        HStack {
                            Text("Set \(index + 1)")
                            Spacer()
                            Button {
                                debugPrint("show picker")
                            } label: {
                                HStack {
                                    Text("\(Int(sets[index].weightInLbs))")
                                        .multilineTextAlignment(.trailing)
                                        .frame(maxHeight: .infinity)
                                    Text("lb")
                                }
                                .frame(width: 100)
                            }

                            Button {
                                debugPrint("show picker")
                            } label: {
                                HStack {
                                    Text("\(Int(sets[index].reps))")
                                        .multilineTextAlignment(.trailing)
                                    Text("reps")
                                }
                                .frame(width: 100)
                            }
                        }
                    }
                    .onDelete(perform: deleteSet)

                    Button(action: addSet) {
                        Label("Add Set", systemImage: "plus.circle.fill")
                    }
                }
                .listStyle(.plain)
                .selectionDisabled()
            }
        }
        .navigationBarItems(
            trailing: Button("Done") {
                onSave(sets)
                isPresented = false
            }
        )
    }

    private func addSet() {
        sets.append(StrengthSet(weightInLbs: 0, reps: 0))
    }

    private func deleteSet(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
    }
}
