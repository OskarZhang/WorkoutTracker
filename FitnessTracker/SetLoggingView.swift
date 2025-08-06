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

    let lightImpact = UIImpactFeedbackGenerator(style: .light)
    let confirmationImpact = UIImpactFeedbackGenerator(style: .heavy)
    @Environment(\.colorScheme) var colorScheme


    @Binding var isPresented: Bool
    @State private var currentFocusIndexState: FocusIndex? = .initial
    @State private var hasEdited: [FocusIndex : Bool] = [:]
    @State private var valueMatrix: [[String]]

    @State var weight: Int = 0
    @State var reps: Int = 0
    let exerciseName: String
    let onSave: ([StrengthSet]) -> Void
    @State var showingNumberPad: Bool = true

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
                ZStack {
                    addSetView()
                    VStack {
                        Spacer()
                        timerButton
                    }

                }


                if showingNumberPad {
                    VStack(spacing: 16) {
                        Divider()
                        numberPad(currentFocusIndexState?.type ?? .weight)
                    }
                    .transition(.move(edge: .bottom))
                }

            }
        }
        .navigationBarItems(
            trailing: Button("Done") {
                confirmationImpact.impactOccurred()
                onSave(sets)
                isPresented = false
            }
        )
    }

    @ViewBuilder
    private var timerButton: some View {
        HStack(alignment: .bottom) {
            Spacer()
            Button(action: {}, label: {
                VStack(alignment: .center) {
                    Image(systemName: "gauge.with.needle")
                    Text("rest timer")
                }
                .frame(width: 100, height: 100)
                .background(colorScheme == .dark ? Color.white : Color.black)
                .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
                .clipShape(Circle())
                .shadow(radius: 4)

            })

        }

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
                .foregroundStyle(.primary)

                .fontWeight(.semibold)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.leading, 8)
            Text(type.label)
                .padding(.trailing, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
        }
        .onTapGesture {
            lightImpact.impactOccurred()

            withAnimation {
                if showingNumberPad && currentFocusIndexState == FocusIndex(setNum: index, type: type) {
                    // only disappear keyboard in this instance
                    showingNumberPad = false
                    currentFocusIndexState = nil
                } else {
                    showingNumberPad = true
                    currentFocusIndexState = FocusIndex(setNum: index, type: type)
                }
            }
        }
        .background {
            if currentFocusIndexState == FocusIndex(setNum: index, type: type) {
                RoundedRectangle(cornerRadius: 8, style: .circular)
                    .foregroundStyle(.secondary.opacity(0.1))
                    .transition(.opacity)
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
        guard let currentFocusIndexState = currentFocusIndexState else {
            return
        }
        if currentFocusIndexState.type == .rep {
            sets[currentFocusIndexState.setNum].reps = sets[currentFocusIndexState.setNum].reps * 10 + numberTapped
        } else {
            sets[currentFocusIndexState.setNum].weightInLbs = sets[currentFocusIndexState.setNum].weightInLbs * 10 + Double(numberTapped)
        }
    }

    private func quickAddWeight(weightAddition: Int) {
        guard let currentFocusIndexState = currentFocusIndexState else {
            return
        }
        guard currentFocusIndexState.type == .weight else {
            assert(false, "Something seriously is wrong")
            return
        }
        sets[currentFocusIndexState.setNum].weightInLbs = sets[currentFocusIndexState.setNum].weightInLbs + Double(weightAddition)

    }

    private func quickSetReps(reps: Int) {
        guard let currentFocusIndexState = currentFocusIndexState else {
            return
        }
        guard currentFocusIndexState.type == .rep else {
            assert(false, "Something seriously is wrong")
            return
        }
        sets[currentFocusIndexState.setNum].reps = reps

    }

    private func backspaceTapped() {
        guard let currentFocusIndexState = currentFocusIndexState else {
            return
        }
        if currentFocusIndexState.type == .rep {
            sets[currentFocusIndexState.setNum].reps = sets[currentFocusIndexState.setNum].reps / 10
        } else {
            sets[currentFocusIndexState.setNum].weightInLbs = floor(sets[currentFocusIndexState.setNum].weightInLbs / 10)
        }
    }

    private func nextButtonTapped() {
        let nextFocus = currentFocusIndexState?.next()
        withAnimation {
            currentFocusIndexState = nextFocus
        }

        if let currentFocusIndexState,
           currentFocusIndexState.setNum + 1 > sets.count
        {
            addSet()
        }
    }

    @ViewBuilder
    private func quickAddWeightButton(_ weight: Int) -> some View {
        Button {
            lightImpact.impactOccurred()
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
            lightImpact.impactOccurred()
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
            lightImpact.impactOccurred()
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
            lightImpact.impactOccurred()
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
            lightImpact.impactOccurred()
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
