import SwiftUI

struct SetLoggingView: View {

    private struct FocusIndex: Equatable, Hashable {
        enum RecordType {
            case weight, rep
            var label: String {
                switch self {
                case .weight:
                    return "lb"
                case .rep:
                    return "rep"
                }
            }
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

    let impactMed = UIImpactFeedbackGenerator(style: .light)


    @Binding var isPresented: Bool
    @State private var currentFocusIndexStateVar: FocusIndex? = nil
    @State private var hasEdited: [FocusIndex : Bool] = [:]
    @State private var valueMatrix: [[String]]

//    @FocusState private var currentFocusIndex: FocusIndex?
    @State var weight: Int = 0
    @State var reps: Int = 0
    let exerciseName: String
    let onSave: ([StrengthSet]) -> Void
    @State var showingNumberPad: Bool = false

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
            VStack() {
                addSetView()

                if showingNumberPad {
                    VStack(spacing: 16) {
                        Divider()
                        numberPad(currentFocusIndexStateVar?.type ?? .weight)
                    }
                    .transition(.move(edge: .bottom))
                }

            }

//                .toolbar {
//                    ToolbarItemGroup(placement: .keyboard) {
//                        Spacer()
//
//                        Button("Next") {
//
//                            let nextFocus = currentFocusIndexStateVar?.next()
//                            currentFocusIndexStateVar = nextFocus
//                            if let currentFocusIndexStateVar,
//                               currentFocusIndexStateVar.setNum + 1 > sets.count
//                            {
//                                addSet()
//                            }
//                        }
//                    }
//            }
//                .onChange(of: currentFocusIndexStateVar) { newValue in
//                    currentFocusIndex = newValue
//                }
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
                        numberPadField(index, .weight)
                        numberPadField(index, .rep)
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


    @ViewBuilder
    private func numberPadField(_ index: Int, _ type: FocusIndex.RecordType) -> some View {
        HStack {
            Text("\(type == .weight ? Int(sets[index].weightInLbs) : sets[index].reps)")
                .foregroundStyle(currentFocusIndexStateVar == FocusIndex(setNum: index, type: type) ? .primary : .secondary)
            Text(type.label)
        }
        .onTapGesture {
            withAnimation {
                if showingNumberPad && currentFocusIndexStateVar == FocusIndex(setNum: index, type: type) {
                    // only disappear keyboard in this instance
                    showingNumberPad = false
                    currentFocusIndexStateVar = nil
                } else {
                    showingNumberPad = true
                    currentFocusIndexStateVar = FocusIndex(setNum: index, type: type)
                }
            }
        }
        .frame(width: 100)
    }
    @ViewBuilder
    private func numberPad(_ type: FocusIndex.RecordType) -> some View {
        VStack {
            HStack {
                if type == .weight {
                    quickAddWeightButton(5)
                    quickAddWeightButton(10)
                    quickAddWeightButton(15)
                    quickAddWeightButton(20)
                } else {
                    quickSetReps(5)
                    quickSetReps(8)
                    quickSetReps(12)
                    quickSetReps(15)
                }
            }
            HStack {
                numberButton(1)
                numberButton(2)
                numberButton(3)
            }

            HStack {
                numberButton(4)
                numberButton(5)
                numberButton(6)
            }

            HStack {
                numberButton(7)
                numberButton(8)
                numberButton(9)
            }
            HStack {
                backspaceButton
                numberButton(0)
                nextButton
            }
        }
        .padding(.leading, 8)
        .padding(.trailing, 8)

    }

    private func updateCurrentFocusedField(numberTapped: Int) {
        guard let currentFocusIndexState = currentFocusIndexStateVar else {
            return
        }
        if currentFocusIndexState.type == .rep {
            sets[currentFocusIndexState.setNum].reps = sets[currentFocusIndexState.setNum].reps * 10 + numberTapped
        } else {
            sets[currentFocusIndexState.setNum].weightInLbs = sets[currentFocusIndexState.setNum].weightInLbs * 10 + Double(numberTapped)
        }
    }

    private func quickAddWeight(weightAddition: Int) {
        guard let currentFocusIndexState = currentFocusIndexStateVar else {
            return
        }
        guard currentFocusIndexState.type == .weight else {
            assert(false, "Something seriously is wrong")
            return
        }
        sets[currentFocusIndexState.setNum].weightInLbs = sets[currentFocusIndexState.setNum].weightInLbs + Double(weightAddition)

    }

    private func quickSetReps(reps: Int) {
        guard let currentFocusIndexState = currentFocusIndexStateVar else {
            return
        }
        guard currentFocusIndexState.type == .rep else {
            assert(false, "Something seriously is wrong")
            return
        }
        sets[currentFocusIndexState.setNum].reps = reps

    }

    private func backspaceTapped() {
        guard let currentFocusIndexState = currentFocusIndexStateVar else {
            return
        }
        if currentFocusIndexState.type == .rep {
            sets[currentFocusIndexState.setNum].reps = sets[currentFocusIndexState.setNum].reps / 10
        } else {
            sets[currentFocusIndexState.setNum].weightInLbs = floor(sets[currentFocusIndexState.setNum].weightInLbs / 10)
        }
    }

    private func nextButtonTapped() {
        let nextFocus = currentFocusIndexStateVar?.next()
        currentFocusIndexStateVar = nextFocus
        if let currentFocusIndexStateVar,
           currentFocusIndexStateVar.setNum + 1 > sets.count
        {
            addSet()
        }
    }

    @ViewBuilder
    private func quickAddWeightButton(_ weight: Int) -> some View {
        Button {
            impactMed.impactOccurred()
            quickAddWeight(weightAddition: weight)
        } label: {
            Text("+\(weight) lb")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.systemGray5))
                )
                .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func quickSetReps(_ reps: Int) -> some View {
        Button {
            impactMed.impactOccurred()
            quickSetReps(reps: reps)
        } label: {
            Text("\(reps) reps")
                .font(.system(size: 24, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.systemGray5))
                )
                .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private func numberButton(_ number: Int) -> some View {
        Button {
            impactMed.impactOccurred()
            updateCurrentFocusedField(numberTapped: number)
        } label: {
            Text("\(number)")
                .font(.system(size: 36, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.systemGray5))
                )
                .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var nextButton: some View {
        Button {
            impactMed.impactOccurred()
            nextButtonTapped()
        } label: {
            Text("Next")
                .font(.system(size: 30, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.systemGray5))
                )
                .foregroundColor(.primary)

        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var backspaceButton: some View {
        Button {
            impactMed.impactOccurred()
            backspaceTapped()
        } label: {
            Image(systemName: "delete.backward")
                .font(.system(size: 30, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray5))
                )
                .foregroundColor(.primary)

        }
        .buttonStyle(PlainButtonStyle())
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
