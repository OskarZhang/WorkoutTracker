//
//  AddWorkoutView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftUI
import SwiftData

struct AddWorkoutViewModel {
    var workoutName = ""
    var weight = ""
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
    @FocusState private var isWeightTextFieldFocused
    
    @Environment(\.colorScheme) var colorScheme

    
    var body: some View {
        NavigationView {
            List {
                TextField("Workout Name", text: $viewModel.workoutName)
                    .autocorrectionDisabled(true)
                    .focused($isNameFocused)
                    .onAppear(perform: {
                        isNameFocused = true
                    })
                    .onSubmit {
                        isWeightTextFieldFocused = true
                    }
                    
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Weight (lbs)", text: $viewModel.weight)
                    .keyboardType(.numberPad)
                    .focused($isWeightTextFieldFocused)
                    .onSubmit {
                        if (!viewModel.workoutName.isEmpty && !viewModel.weight.isEmpty) {
                            saveWorkout()
                        }
                    }
                Stepper("Reps: \(viewModel.repCount)", value: $viewModel.repCount, in: 1...100)
                Stepper("Sets: \(viewModel.setCount)", value: $viewModel.setCount, in: 1...10)
            
                DatePicker("Date", selection: $viewModel.workoutDate, displayedComponents: .date)
                
            }
            .listStyle(.plain)
            .keyboardToolbar {
                Group {
                    if (isWeightTextFieldFocused) {
                        HStack(alignment: .bottom, spacing: 16) {
                            Spacer()
                            Button {
                                addWeight(additionalWeight: 10)
                            } label: {
                                VStack(alignment: .center) {
                                    Spacer()
                                    Image(.barbell)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                    Text("10 lbs")
                                        .lineLimit(1)
                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            Button {
                                addWeight(additionalWeight: 25)
                            } label: {
                                VStack(alignment: .center) {
                                    Spacer()
                                    Image(.barbell)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                    Text("25 lbs")
                                        .lineLimit(1)
                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            Button {
                                addWeight(additionalWeight: 45)
                            } label: {
                                VStack(alignment: .center) {
                                    Spacer()
                                    Image(.barbell)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 45, height: 45)
                                    Text("45 lbs")
                                        .lineLimit(1)
                                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .shadow(radius: 0.3)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 16) {
                                ForEach(suggestWorkoutNames(text: viewModel.workoutName)) { workout in
                                    Button {
                                        switch workout.type {
                                        case .cardio(_):
                                            break
                                        case .strength(let weight, let repCount, let setCount):
                                            self.viewModel.weight = "\(weight)"
                                            self.viewModel.repCount = repCount
                                            self.viewModel.setCount = setCount
                                            self.viewModel.workoutName = workout.name
                                            self.isWeightTextFieldFocused = true
                                        }
                                    } label: {
                                        Text(workout.name)
                                            .lineLimit(1)
                                    }
                                    .fixedSize(horizontal: true, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                                }
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveWorkout() }
                        .disabled(viewModel.weight.isEmpty || viewModel.workoutName.isEmpty)
                }
            }
        }
    }
    
    private func saveWorkout() {
        let workoutType: WorkoutType
        let weightInt = Int(viewModel.weight) ?? 0
        let repCountInt = viewModel.repCount
        let setCountInt = viewModel.setCount
        workoutType = .strength(weight: weightInt, repCount: repCountInt, setCount: setCountInt)
        let newWorkout = Workout(name: viewModel.workoutName.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression), type: workoutType, date: viewModel.workoutDate)
        modelContext.insert(newWorkout)
        
        isPresented = false
    }
    
    private func addWeight(additionalWeight: Int) {
        var curWeight = Int(viewModel.weight) ?? 0
        curWeight += additionalWeight
        viewModel.weight = String(curWeight)
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
