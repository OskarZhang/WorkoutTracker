//
//  AddWorkoutView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftUI
import SwiftData
import SwiftUIIntrospect

struct AddWorkoutViewModel {
    var workoutName = ""
    var weight = 0
    var repCount = 5
    var setCount = 5
    var workoutDate = Date()
}

struct AddWorkoutView: View {
    
    init(isPresented: Binding<Bool>, modelContext: ModelContext) {
        self._isPresented = isPresented
        self.modelContext = modelContext
    }
    
    @Binding var isPresented: Bool
    let modelContext: ModelContext
    
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    @State private var viewModel: AddWorkoutViewModel = .init()
    @FocusState private var isNameFocused
    
    @State private var hasSetInitialFocus = false
    
    @Environment(\.colorScheme) var colorScheme

    var isValidInput: Bool {
        return !viewModel.workoutName.isEmpty
    }
    
    var body: some View {
        NavigationView {
            List {

                TextField("Add workout", text: $viewModel.workoutName)
                    .autocorrectionDisabled(true)
                    .font(.largeTitle)
                    .focused($isNameFocused)
                    .listRowSeparator(.hidden)
                    .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18), customize: { textField in
                        if (!hasSetInitialFocus && isPresented) {
                            textField.becomeFirstResponder()
                            hasSetInitialFocus = true
                        }
                    })
                    .onAppear {
                        isNameFocused = true
                    }
                    .onSubmit {
                        if isValidInput {
                            saveWorkout()
                        }
                    }
                    
                    .submitLabel(.done)
                    .padding(.top, 16)

                Stepper("Reps \(viewModel.repCount)", value: $viewModel.repCount, in: 1...100)
                    .listRowSeparator(.hidden)
                Stepper("Sets \(viewModel.setCount)", value: $viewModel.setCount, in: 1...10)
                    .listRowSeparator(.hidden)

                DatePicker("Date", selection: $viewModel.workoutDate, displayedComponents: .date)
                    .listRowSeparator(.hidden)

                Text("Weight")
                SliderView.Representable(value: $viewModel.weight).frame(height: 120)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                
            }
            
            .listStyle(.plain)
            
            .keyboardToolbar {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom) {
                            ForEach(suggestWorkoutNames(text: viewModel.workoutName)) { workout in
                                Button(workout.name) {
                                    switch workout.type {
                                    case .cardio(_):
                                        break
                                    case .strength(let weight, let repCount, let setCount):
                                        self.viewModel.weight = weight
                                        self.viewModel.repCount = repCount
                                        self.viewModel.setCount = setCount
                                        self.viewModel.workoutName = workout.name
                                    }
                                }
                                .buttonStyle(.bordered)
                                .buttonBorderShape(.capsule)
                                .tint(colorScheme == .dark ? Color.white : Color(UIColor.darkGray))
                                .fixedSize(horizontal: true, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            }
                        }
                        .padding(EdgeInsets(top: 0.0, leading: 8.0, bottom: 8.0, trailing: 8.0))
                    }
                    .background(Color(UIColor.systemBackground))
            }
            .tint(colorScheme == .dark ? Color.white : Color(UIColor.black))
        }
    }
    
    private func dumbbellButton(weight: Int) -> some View {
        return Button {
            addWeight(additionalWeight: weight)
        } label: {
            VStack(alignment: .center) {
                Spacer()
                Image(.barbell)
                    .resizable()
                    .scaledToFit()
                    .frame(width: max(20.0, CGFloat(weight)), height: max(20.0, CGFloat(weight)))
                Text("\(weight) lbs")
                    .lineLimit(1)
                    .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
    }
    
    private func saveWorkout() {
        let workoutType: WorkoutType
        let weightInt = viewModel.weight
        let repCountInt = viewModel.repCount
        let setCountInt = viewModel.setCount
        workoutType = .strength(weight: weightInt, repCount: repCountInt, setCount: setCountInt)
        let newWorkout = Workout(name: viewModel.workoutName.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression), type: workoutType, date: viewModel.workoutDate)
        modelContext.insert(newWorkout)
        
        isPresented = false
    }
    
    private func addWeight(additionalWeight: Int) {
        var curWeight = viewModel.weight
        curWeight += additionalWeight
        viewModel.weight = curWeight
    }
    
    private func suggestWorkoutNames(text: String) -> [Workout] {
        let finalList = (text.isEmpty ? Array(workouts.prefix(10)) : workouts.filter { $0.name.lowercased().contains(text.lowercased())})
            .reduce((uniqueWorkoutNames: Set<String>(), list: [Workout]())) { partialResult, workout in
                if (partialResult.uniqueWorkoutNames.contains(workout.name)) {
                    return partialResult
                }
                var uniqueNames = partialResult.uniqueWorkoutNames
                var list = partialResult.list
                list.append(workout)
                uniqueNames.insert(workout.name)
                return (uniqueNames, list)
            }
            .list
        if (finalList.count == 1 && text == finalList.first?.name) {
            // no need to provide suggestions for the exact match
            return []
        }
        return finalList
    }
}
