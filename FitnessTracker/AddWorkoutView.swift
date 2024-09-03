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
    
    @State private var workoutName = ""
    @State private var workoutType = 0 // 0 for cardio, 1 for strength
    @State private var durationMinutes = 30
    @State private var weight = ""
    @State private var repCount = 5
    @State private var setCount = 5
    @State private var workoutDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Workout Name", text: $workoutName)
                
                Picker("Workout Type", selection: $workoutType) {
                    Text("Cardio").tag(0)
                    Text("Strength").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if workoutType == 0 {
                    Stepper("Duration: \(durationMinutes) minutes", value: $durationMinutes, in: 1...180)
                } else {
                    TextField("Weight (lbs)", text: $weight)
                        .keyboardType(.numberPad)
                    Stepper("Reps: \(repCount)", value: $repCount, in: 1...100)
                    Stepper("Sets: \(setCount)", value: $setCount, in: 1...10)

                }
                
                DatePicker("Date", selection: $workoutDate, displayedComponents: .date)
            }
            .navigationTitle("Add Workout")
            .navigationBarItems(
                leading: Button("Cancel") { isPresented = false },
                trailing: Button("Save") { saveWorkout() }
            )
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
