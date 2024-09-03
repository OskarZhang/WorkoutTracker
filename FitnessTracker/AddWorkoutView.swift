//
//  AddWorkoutView.swift
//  FitnessTracker
//
//  Created by Oskar Zhang on 9/2/24.
//

import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @Binding var isPresented: Bool
    let modelContext: ModelContext
    
    @Query private var workouts: [Workout]
    @State private var workoutName = ""
    @State private var workoutType = 1 // 0 for cardio, 1 for strength
    @State private var durationMinutes = 30
    @State private var weight = ""
    @State private var repCount = 5
    @State private var setCount = 5
    @State private var workoutDate = Date()
    @FocusState private var isWeightTextFieldFocused
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Workout Name", text: $workoutName)
                    .autocorrectionDisabled(true)
                
                Picker("Workout Type", selection: $workoutType) {
                    Text("Strength").tag(1)
                    Text("Cardio").tag(0)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if workoutType == 0 {
                    Stepper("Duration: \(durationMinutes) minutes", value: $durationMinutes, in: 1...180)
                } else {
                    TextField("Weight (lbs)", text: $weight)
                        .keyboardType(.numberPad)
                        .focused($isWeightTextFieldFocused)
                    Stepper("Reps: \(repCount)", value: $repCount, in: 1...100)
                    Stepper("Sets: \(setCount)", value: $setCount, in: 1...10)

                }
                
                DatePicker("Date", selection: $workoutDate, displayedComponents: .date)
                
                
                Button{ saveWorkout() } label: {
                    Text("Save").padding()
                }
                    .foregroundStyle(.white)
                    .background(.tint)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                    
            }
            .keyboardToolbar {
                Group {
                    if (isWeightTextFieldFocused) {
                        HStack {
                            Button("+10 lbs") {
                                addWeight(additionalWeight: 10)
                            }
                            Button("+25 lbs") {
                                addWeight(additionalWeight: 25)
                            }
                            Button("+45 lbs") {
                                addWeight(additionalWeight: 45)
                            }
                            Button(LocalizedStringKey(""), systemImage: "clear") {
                                weight = ""
                            }
                        }
                    } else {
                        HStack {
                            ForEach(matchWorkout(text: workoutName)) { workout in
                                Button(workout.name) {
                                    switch workout.type {
                                    case .cardio(let durationMinutes):
                                        self.durationMinutes = durationMinutes
                                    case .strength(let weight, let repCount, let setCount):
                                        self.weight = "\(weight)"
                                        self.repCount = repCount
                                        self.setCount = setCount
                                        self.workoutName = workout.name
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func saveWorkout() {
        let workoutType: WorkoutType
        if self.workoutType == 0 {
            workoutType = .cardio(durationMinutes: durationMinutes)
        } else {
            let weightInt = Int(weight) ?? 0
            let repCountInt = repCount
            let setCountInt = setCount
            workoutType = .strength(weight: weightInt, repCount: repCountInt, setCount: setCountInt)
        }
        
        let newWorkout = Workout(name: workoutName, type: workoutType, date: workoutDate)
        modelContext.insert(newWorkout)
        
        isPresented = false
    }
    
    private func addWeight(additionalWeight: Int) {
        var curWeight = Int(weight) ?? 0
        curWeight += additionalWeight
        weight = String(curWeight)
    }
    
    private func matchWorkout(text: String) -> [Workout] {
        return workouts.filter { $0.name.lowercased().contains(text.lowercased())}
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
    }
}


struct WorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.name)
                .font(.headline)
            
            switch workout.type {
            case .strength(let weight, let repCount, let setCount):
                Text("Strength: \(weight)lbs, \(repCount) reps, \(setCount) sets")
                    .font(.subheadline)
            case .cardio(let durationMinutes):
                Text("Cardio: \(durationMinutes) minutes")
                    .font(.subheadline)
            }
            
            Text(workout.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
