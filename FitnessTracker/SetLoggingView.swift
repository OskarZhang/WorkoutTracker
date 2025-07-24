import SwiftUI

struct SetLoggingView: View {

    private struct FocusIndex: Equatable, Hashable {
        enum RecordType {
            case weight, rep
        }
        var setNum: Int
        var type: RecordType

        static let initial = FocusIndex(setNum: 0, type: .weight)

        func next() -> FocusIndex {
            var nextSetNum = setNum
            var nextType = type
            if type == .rep {
                nextSetNum += 1
                nextType = .weight
            } else {
                nextType = .rep
            }
            return Self.init(setNum: nextSetNum, type: nextType)
        }
    }

    @Binding var isPresented: Bool
    @State private var currentFocusIndexStateVar: FocusIndex? = .initial
    @State private var hasEdited: [FocusIndex : Bool] = [:]
    @State private var valueMatrix: [[String]]

    @FocusState private var currentFocusIndex: FocusIndex?
    @State var weight: Int = 0
    @State var reps: Int = 0
    let exerciseName: String
    let onSave: ([StrengthSet]) -> Void

    @State private var sets: [StrengthSet] = [StrengthSet(weightInLbs: 0, reps: 0)]

    init(sets: [StrengthSet]? = nil, isPresented: Binding<Bool>, exerciseName: String, onSave: @escaping ([StrengthSet]) -> Void) {
        self._isPresented = isPresented
        var lastSet = sets ?? [StrengthSet(weightInLbs: 0, reps: 0)]
        if lastSet.count == 0 {
            lastSet = [StrengthSet(weightInLbs: 0, reps: 0)]
        }
        self.sets = lastSet
        self.exerciseName = exerciseName
        self.onSave = onSave
        self.valueMatrix = lastSet.map { _ in ["", ""] }
    }

    var body: some View {
        NavigationView {
            addSetView()
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()

                        Button("Next") {

                            let nextFocus = currentFocusIndexStateVar?.next()
                            currentFocusIndexStateVar = nextFocus
                            if let currentFocusIndexStateVar,
                               currentFocusIndexStateVar.setNum + 1 > sets.count
                            {
                                addSet()
                            }
                        }
                    }
            }
                .onChange(of: currentFocusIndexStateVar) { newValue in
                    currentFocusIndex = newValue
                }
//                .onChange(of: currentFocusIndex, { oldValue, newValue in
//                    guard let currentFocusIndex else {
//                        return
//                    }
//                    if currentFocusIndex.type == .rep {
//                        valueMatrix[currentFocusIndex.setNum][1] = ""
//                    } else {
//                        valueMatrix[currentFocusIndex.setNum][0] = ""
//                    }
//                })

        }
        .navigationBarItems(
            trailing: Button("Done") {
                onSave(sets)
                isPresented = false
            }
        )
    }

//    // Helper to create a binding to a specific cell
//    private func bindingFor(_ focusIndex: FocusIndex) -> Binding<String> {
//        Binding(
//            get: {
//                if hasEdited[focusIndex] == nil {
//                    return ""
//                }
//
//
//                if focusIndex.type == .rep {
//                    return self.valueMatrix[focusIndex.setNum][1]
//                } else {
//                    return self.valueMatrix[focusIndex.setNum][0]
//                }
//
//            },
//            set: { newValue in
//                hasEdited[focusIndex] = true
//                if focusIndex.type == .rep {
//                    self.valueMatrix[focusIndex.setNum][1] = newValue
////                    sets[focusIndex.setNum].reps = Int(newValue) ?? 0
//                } else {
//                    self.valueMatrix[focusIndex.setNum][0] = newValue
////                    sets[focusIndex.setNum].weightInLbs = Double(newValue) ?? 0.0
//                }
//
//            }
//        )
//    }


    @ViewBuilder
    func addSetView() -> some View {
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
                        HStack {
                            TextField("\(Int(sets[index].weightInLbs))", text: Binding(
                                    get: { valueMatrix[index][0] },
                                    set: { (newValue, transaction) in

                                        var copy = valueMatrix
                                        copy[index][0] = newValue
                                        valueMatrix = copy // This triggers the update
                                        sets[index].weightInLbs = Double(newValue) ?? 0.0
                                    }
                                ))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($currentFocusIndex, equals: FocusIndex(setNum: index, type: .weight))
                                .textFieldStyle(.plain)
                                .listRowSeparator(.hidden)

                            Text("lb")
                        }
                        .onTapGesture {
                            currentFocusIndex = FocusIndex(setNum: index, type: .weight)
                        }

                        .frame(width: 100)


                        HStack {
                            TextField("\(sets[index].reps)", text: Binding(
                                get: { valueMatrix[index][1] },
                                set: { (newValue, transaction) in

                                    var copy = valueMatrix
                                    copy[index][1] = newValue
                                    valueMatrix = copy // This triggers the update
                                    sets[index].reps = Int(newValue) ?? 0
                                }
                            ))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                                .focused($currentFocusIndex, equals: FocusIndex(setNum: index, type: .rep))
                                .textFieldStyle(.plain)
                                .listRowSeparator(.hidden)
                            Text("reps")
                        }
                        .onTapGesture {
                            currentFocusIndex = FocusIndex(setNum: index, type: .rep)
                        }

                        .frame(width: 100)
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


    private func addSet() {
        sets.append(StrengthSet(weightInLbs: 0, reps: 0))
        valueMatrix.append(["", ""])
    }

    private func deleteSet(at offsets: IndexSet) {
        sets.remove(atOffsets: offsets)
        valueMatrix.remove(atOffsets: offsets)
    }
}
